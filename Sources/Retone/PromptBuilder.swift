import Foundation

enum PromptBuilder {
    static let defaultTemplate = """
    You are a writing assistant. Rewrite the user's text in a {style} style with a {tone} tone. \
    Preserve the original meaning, language, formatting (line breaks, lists), and approximate length. \
    Output ONLY the rewritten text — no preamble, no quotes, no explanations.
    """

    static func systemPrompt(style: Style, tone: Tone, customTemplate: String) -> String {
        let trimmed = customTemplate.trimmingCharacters(in: .whitespacesAndNewlines)
        let template = trimmed.isEmpty ? defaultTemplate : trimmed
        return template
            .replacingOccurrences(of: "{style}", with: style.rawValue)
            .replacingOccurrences(of: "{tone}", with: tone.rawValue)
    }

    /// Removes reasoning blocks (e.g. deepseek-r1's `<think>…</think>`) from raw model
    /// output. Safe to call on partial streams: an unclosed `<think>` hides the remainder.
    static func visibleText(_ raw: String) -> String {
        raw
            .replacingOccurrences(of: "(?s)<think>.*?</think>", with: "", options: .regularExpression)
            .replacingOccurrences(of: "(?s)<think>.*", with: "", options: .regularExpression)
    }
}
