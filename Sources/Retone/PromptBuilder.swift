import Foundation

enum PromptBuilder {
    static let defaultTemplate = """
    You are a writing assistant. Rewrite the user's text in a {style} style with a {tone} tone. \
    Preserve the original meaning, language, formatting (line breaks, lists), and approximate length. \
    Output ONLY the rewritten text — no preamble, no quotes, no explanations.
    """

    static let summariseTemplate = """
    You are a writing assistant. Summarise the user's text, keeping the key points and the \
    original language. Make it significantly shorter than the original. \
    Output ONLY the summary — no preamble, no quotes, no explanations.
    """

    static let polishTemplate = """
    You are a writing assistant. Edit the user's text to correct ALL errors in grammar, \
    spelling, punctuation, and word choice, and smooth awkward phrasing. Beyond corrections, \
    preserve the author's voice, meaning, language, formatting (line breaks, lists), and length. \
    Output ONLY the edited text — no preamble, no quotes, no explanations.
    """

    /// The custom template override applies to Rewrite mode only.
    static func systemPrompt(mode: Mode, style: Style, tone: Tone, customTemplate: String) -> String {
        switch mode {
        case .summarise:
            return summariseTemplate
        case .polish:
            return polishTemplate
        case .rewrite:
            let trimmed = customTemplate.trimmingCharacters(in: .whitespacesAndNewlines)
            let template = trimmed.isEmpty ? defaultTemplate : trimmed
            return template
                .replacingOccurrences(of: "{style}", with: style.rawValue)
                .replacingOccurrences(of: "{tone}", with: tone.rawValue)
        }
    }

    /// Removes reasoning blocks (e.g. deepseek-r1's `<think>…</think>`) from raw model
    /// output. Safe to call on partial streams: an unclosed `<think>` hides the remainder.
    static func visibleText(_ raw: String) -> String {
        raw
            .replacingOccurrences(of: "(?s)<think>.*?</think>", with: "", options: .regularExpression)
            .replacingOccurrences(of: "(?s)<think>.*", with: "", options: .regularExpression)
    }
}
