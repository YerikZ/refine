import Foundation

enum Mode: String, CaseIterable, Identifiable {
    case rewrite, summarise, polish

    var id: String { rawValue }
    var displayName: String { rawValue.capitalized }
}

enum Style: String, CaseIterable, Identifiable {
    case professional, casual, formal, concise

    var id: String { rawValue }
    var displayName: String { rawValue.capitalized }
}

enum Tone: String, CaseIterable, Identifiable {
    case neutral, friendly, confident, direct

    var id: String { rawValue }
    var displayName: String { rawValue.capitalized }
}
