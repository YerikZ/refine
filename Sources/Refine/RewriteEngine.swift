import Foundation
import Observation

struct HistoryEntry: Codable, Identifiable, Equatable {
    let id: UUID
    let mode: String
    let style: String
    let tone: String
    let input: String
    let output: String
    let date: Date

    var label: String {
        let mode = Mode(rawValue: mode)?.displayName ?? mode
        let style = Style(rawValue: style)?.displayName ?? style
        return "\(mode) · \(style)"
    }

    var relativeTime: String {
        let seconds = -date.timeIntervalSinceNow
        switch seconds {
        case ..<60: return "now"
        case ..<3600: return "\(Int(seconds / 60))m"
        case ..<86400: return "\(Int(seconds / 3600))h"
        default: return "\(Int(seconds / 86400))d"
        }
    }
}

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
    /// Model output shown in the result card; the input `text` is never overwritten.
    private(set) var output: String?
    private(set) var history: [HistoryEntry] = []

    @ObservationIgnored private var task: Task<Void, Never>?
    /// Text set by restore()/clear(), so the view's text-change observer can tell
    /// programmatic changes from user edits (only the latter invalidate the output).
    @ObservationIgnored private var programmaticText: String?

    var isStreaming: Bool { phase == .streaming }
    var hasOutput: Bool { output != nil }

    var errorMessage: String? {
        if case .error(let message) = phase { return message }
        return nil
    }

    init() {
        if let data = UserDefaults.standard.data(forKey: Defaults.Key.history),
           let saved = try? JSONDecoder().decode([HistoryEntry].self, from: data) {
            history = saved
        }
    }

    func perform(_ mode: Mode, style: Style, tone: Tone) {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        cancel()
        output = nil
        phase = .streaming
        task = Task { await run(source: text, mode: mode, style: style, tone: tone) }
    }

    func cancel() {
        task?.cancel()
        task = nil
        if phase == .streaming { phase = .idle }
    }

    /// Hides the result card; the input text is untouched.
    func revert() {
        cancel()
        output = nil
        phase = .idle
    }

    func textDidChange(_ newText: String) {
        if newText == programmaticText { return }
        programmaticText = nil
        invalidateOutput()
    }

    /// Called when the user edits the input or switches mode — the shown result no longer matches.
    func invalidateOutput() {
        guard !isStreaming else { return }
        if output != nil { output = nil }
        if case .error = phase { phase = .idle }
    }

    func clear() {
        cancel()
        programmaticText = ""
        text = ""
        output = nil
        phase = .idle
    }

    func restore(_ entry: HistoryEntry) {
        cancel()
        programmaticText = entry.input
        text = entry.input
        output = entry.output
        phase = .idle
    }

    private func addHistory(mode: Mode, style: Style, tone: Tone, input: String, output: String) {
        let entry = HistoryEntry(
            id: UUID(), mode: mode.rawValue, style: style.rawValue, tone: tone.rawValue,
            input: input, output: output, date: Date()
        )
        history = Array(([entry] + history).prefix(5))
        if let data = try? JSONEncoder().encode(history) {
            UserDefaults.standard.set(data, forKey: Defaults.Key.history)
        }
    }

    private func run(source: String, mode: Mode, style: Style, tone: Tone) async {
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
            let system = PromptBuilder.systemPrompt(mode: mode, style: style, tone: tone, customTemplate: customPrompt)

            var raw = ""
            for try await delta in client.streamChat(system: system, user: source) {
                try Task.checkCancellation()
                raw += delta
                let visible = PromptBuilder.visibleText(raw)
                if !visible.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    output = visible.trimmingCharacters(in: .newlines)
                }
            }

            let final = PromptBuilder.visibleText(raw).trimmingCharacters(in: .whitespacesAndNewlines)
            if final.isEmpty {
                output = nil
                phase = .error("The model returned no text.")
            } else {
                output = final
                phase = .idle
                addHistory(mode: mode, style: style, tone: tone, input: source, output: final)
            }
        } catch is CancellationError {
            phase = .idle
        } catch {
            output = nil
            phase = .error(error.localizedDescription)
        }
    }
}
