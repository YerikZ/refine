import Foundation

enum Mode: String, CaseIterable, Identifiable {
    case proofread, rewrite, summarise, polish

    var id: String { rawValue }
    var displayName: String { rawValue.capitalized }
}

enum Style: String, CaseIterable, Identifiable {
    case professional, casual, persuasive

    var id: String { rawValue }
    var displayName: String { rawValue.capitalized }
}

enum Tone: String, CaseIterable, Identifiable {
    case neutral, friendly, confident, direct

    var id: String { rawValue }
    var displayName: String { rawValue.capitalized }
}

/// Independent of Style/Tone so it can stack with any register choice
/// (e.g. "professional and concise", "casual and concise").
enum Length: String, CaseIterable, Identifiable {
    case normal, concise

    var id: String { rawValue }
    var displayName: String { rawValue.capitalized }
}
