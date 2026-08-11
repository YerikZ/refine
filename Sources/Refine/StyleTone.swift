import Foundation

enum Mode: String, CaseIterable, Identifiable {
    case rewrite, summarise, polish, proofread

    var id: String { rawValue }
    var displayName: String { rawValue.capitalized }
}

enum Style: String, CaseIterable, Identifiable {
    case professional, casual, concise, persuasive

    var id: String { rawValue }
    var displayName: String { rawValue.capitalized }
}

enum Tone: String, CaseIterable, Identifiable {
    case neutral, friendly, confident, formal

    var id: String { rawValue }
    var displayName: String { rawValue.capitalized }
}
