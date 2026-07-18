import Foundation
import Observation

@MainActor
@Observable
final class RewriteEngine {
    enum Phase: Equatable {
        case idle
        case streaming
        case error(String)
    }

    var text = ""
    var phase: Phase = .idle
    private(set) var previousText: String?

    @ObservationIgnored private var task: Task<Void, Never>?

    var isStreaming: Bool { phase == .streaming }

    var errorMessage: String? {
        if case .error(let message) = phase { return message }
        return nil
    }

    func rewrite(style: Style, tone: Tone) {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        cancel()
        let source = text
        previousText = source
        phase = .streaming
        task = Task { await run(source: source, style: style, tone: tone) }
    }

    func cancel() {
        task?.cancel()
        task = nil
        if phase == .streaming { phase = .idle }
    }

    /// Swaps the current text with the pre-rewrite text, so Revert also acts as redo.
    func revert() {
        guard let previous = previousText else { return }
        previousText = text
        text = previous
        phase = .idle
    }

    private func run(source: String, style: Style, tone: Tone) async {
        let defaults = UserDefaults.standard
        let serverURL = defaults.string(forKey: Defaults.Key.serverURL) ?? Defaults.serverURL
        let model = defaults.string(forKey: Defaults.Key.model) ?? Defaults.model
        let temperature = defaults.object(forKey: Defaults.Key.temperature) == nil
            ? Defaults.temperature
            : defaults.double(forKey: Defaults.Key.temperature)
        let customPrompt = defaults.string(forKey: Defaults.Key.customPrompt) ?? ""

        do {
            let client = try OllamaClient(
                baseURLString: serverURL.isEmpty ? Defaults.serverURL : serverURL,
                model: model.isEmpty ? Defaults.model : model,
                temperature: temperature
            )
            let system = PromptBuilder.systemPrompt(style: style, tone: tone, customTemplate: customPrompt)

            var raw = ""
            for try await delta in client.streamChat(system: system, user: source) {
                try Task.checkCancellation()
                raw += delta
                let visible = PromptBuilder.visibleText(raw)
                if !visible.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    text = visible.trimmingCharacters(in: .newlines)
                }
            }

            let final = PromptBuilder.visibleText(raw).trimmingCharacters(in: .whitespacesAndNewlines)
            if final.isEmpty {
                text = source
                phase = .error("The model returned no text.")
            } else {
                text = final
                phase = .idle
            }
        } catch is CancellationError {
            text = source
            phase = .idle
        } catch {
            text = source
            phase = .error(error.localizedDescription)
        }
    }
}
