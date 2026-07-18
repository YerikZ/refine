import Foundation

enum Defaults {
    static let serverURL = "http://localhost:11434"
    static let model = "qwen2.5:7b"
    static let temperature = 0.3

    enum Key {
        static let serverURL = "serverURL"
        static let model = "model"
        static let temperature = "temperature"
        static let customPrompt = "customPrompt"
        static let mode = "mode"
        static let style = "style"
        static let tone = "tone"
        static let history = "history"
    }
}
