import Foundation

enum PromptBuilder {
    /// Shared instruction so generated (not merely preserved) content that is naturally a
    /// list renders as clean bullets in the result's plain-text view, not markdown syntax.
    static let bulletFormattingInstruction = """
    If the content includes a list or several distinct items, format it as bullet points — \
    one item per line, each starting with "• " — instead of a run-on sentence or paragraph. \
    Do not use markdown syntax (no *, -, #, or **bold**).
    """

    static let defaultTemplate = """
    You are a writing assistant. Rewrite the user's text in a {style} style with a {tone} tone. \
    Preserve the original meaning and language.{length} \
    \(bulletFormattingInstruction) \
    Output ONLY the rewritten text — no preamble, no quotes, no explanations.
    """

    static let summariseTemplate = """
    You are a writing assistant. Summarise the user's text, keeping the key points and the \
    original language. Make it significantly shorter than the original. \
    \(bulletFormattingInstruction) \
    Output ONLY the summary — no preamble, no quotes, no explanations.
    """

    static let polishTemplate = """
    You are a writing assistant. Edit the user's text to correct ALL errors in grammar, \
    spelling, punctuation, and word choice, and smooth awkward phrasing. Beyond corrections, \
    preserve the author's voice, meaning, language, formatting (line breaks, lists), and length. \
    Output ONLY the edited text — no preamble, no quotes, no explanations.
    """

    static let proofreadTemplate = """
    You are a proofreading assistant. Fix only clear errors in grammar, spelling, punctuation, \
    and typos in the user's text. Make the minimum change necessary to correct each error — do \
    NOT rephrase, restructure, reorder, or improve style or word choice beyond fixing outright \
    mistakes. Preserve the author's exact wording, tone, length, and formatting (line breaks, \
    lists) wherever it is not actually wrong. \
    Output ONLY the corrected text — no preamble, no quotes, no explanations.
    """

    /// The custom template override applies to Rewrite mode only.
    static func systemPrompt(mode: Mode, style: Style, tone: Tone, length: Length, customTemplate: String) -> String {
        switch mode {
        case .summarise:
            return summariseTemplate
        case .polish:
            return polishTemplate
        case .proofread:
            return proofreadTemplate
        case .rewrite:
            let trimmed = customTemplate.trimmingCharacters(in: .whitespacesAndNewlines)
            let template = trimmed.isEmpty ? defaultTemplate : trimmed
            let lengthClause = length == .concise
                ? " Make it noticeably shorter and more concise than the original, trimming unnecessary words while preserving the key meaning."
                : " Keep it about the same length as the original."
            return template
                .replacingOccurrences(of: "{style}", with: style.rawValue)
                .replacingOccurrences(of: "{tone}", with: tone.rawValue)
                .replacingOccurrences(of: "{length}", with: lengthClause)
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
