import Foundation

enum Style: String, CaseIterable, Identifiable {
    case formal, casual, professional, academic, creative, concise

    var id: String { rawValue }
    var displayName: String { rawValue.capitalized }
}

enum Tone: String, CaseIterable, Identifiable {
    case neutral, friendly, confident, persuasive, empathetic, direct

    var id: String { rawValue }
    var displayName: String { rawValue.capitalized }
}
