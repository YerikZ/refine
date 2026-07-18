import Foundation

enum OllamaError: LocalizedError {
    case invalidURL(String)
    case unreachable(String)
    case server(Int, String)
    case api(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL(let url):
            return "Invalid server URL: \(url)"
        case .unreachable(let url):
            return "Can't reach Ollama at \(url). Is it running?"
        case .server(let status, let message):
            return "Server error (\(status)): \(message)"
        case .api(let message):
            return "Ollama error: \(message)"
        }
    }
}

struct OllamaClient: Sendable {
    let baseURL: URL
    let model: String
    let temperature: Double

    init(baseURLString: String, model: String, temperature: Double) throws {
        let cleaned = baseURLString
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        guard let url = URL(string: cleaned), url.scheme != nil else {
            throw OllamaError.invalidURL(baseURLString)
        }
        self.baseURL = url
        self.model = model
        self.temperature = temperature
    }

    private struct ChatRequest: Encodable {
        struct Message: Encodable {
            let role: String
            let content: String
        }
        struct Options: Encodable {
            let temperature: Double
        }
        let model: String
        let messages: [Message]
        let stream: Bool
        let options: Options
    }

    private struct ChatChunk: Decodable {
        struct Message: Decodable {
            let content: String?
        }
        let message: Message?
        let done: Bool?
        let error: String?
    }

    func streamChat(system: String, user: String) -> AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    var request = URLRequest(url: baseURL.appendingPathComponent("api/chat"))
                    request.httpMethod = "POST"
                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    request.timeoutInterval = 300
                    request.httpBody = try JSONEncoder().encode(ChatRequest(
                        model: model,
                        messages: [
                            .init(role: "system", content: system),
                            .init(role: "user", content: user),
                        ],
                        stream: true,
                        options: .init(temperature: temperature)
                    ))

                    let (bytes, response) = try await URLSession.shared.bytes(for: request)
                    guard let http = response as? HTTPURLResponse else {
                        throw OllamaError.unreachable(baseURL.absoluteString)
                    }
                    if http.statusCode != 200 {
                        var body = ""
                        for try await line in bytes.lines where body.count < 2000 {
                            body += line
                        }
                        let message = Self.errorMessage(fromBody: body) ?? body
                        throw OllamaError.server(http.statusCode, message)
                    }

                    for try await line in bytes.lines {
                        guard let data = line.data(using: .utf8) else { continue }
                        let chunk = try JSONDecoder().decode(ChatChunk.self, from: data)
                        if let error = chunk.error {
                            throw OllamaError.api(error)
                        }
                        if let content = chunk.message?.content, !content.isEmpty {
                            continuation.yield(content)
                        }
                        if chunk.done == true { break }
                    }
                    continuation.finish()
                } catch let error as URLError {
                    continuation.finish(throwing: OllamaError.unreachable(baseURL.absoluteString + " (\(error.localizedDescription))"))
                } catch {
                    continuation.finish(throwing: error)
                }
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }

    static func listModels(baseURLString: String) async throws -> [String] {
        struct TagsResponse: Decodable {
            struct Model: Decodable {
                let name: String
            }
            let models: [Model]
        }
        let client = try OllamaClient(baseURLString: baseURLString, model: "", temperature: 0)
        var request = URLRequest(url: client.baseURL.appendingPathComponent("api/tags"))
        request.timeoutInterval = 5
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
                let status = (response as? HTTPURLResponse)?.statusCode ?? 0
                throw OllamaError.server(status, String(data: data, encoding: .utf8) ?? "")
            }
            return try JSONDecoder().decode(TagsResponse.self, from: data).models.map(\.name).sorted()
        } catch let error as URLError {
            throw OllamaError.unreachable(client.baseURL.absoluteString + " (\(error.localizedDescription))")
        }
    }

    private static func errorMessage(fromBody body: String) -> String? {
        guard let data = body.data(using: .utf8),
              let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        else { return nil }
        return object["error"] as? String
    }
}
