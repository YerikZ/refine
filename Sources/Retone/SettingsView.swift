import SwiftUI

struct SettingsView: View {
    @AppStorage(Defaults.Key.serverURL) private var serverURL = Defaults.serverURL
    @AppStorage(Defaults.Key.model) private var model = Defaults.model
    @AppStorage(Defaults.Key.temperature) private var temperature = Defaults.temperature
    @AppStorage(Defaults.Key.customPrompt) private var customPrompt = ""

    @State private var availableModels: [String] = []
    @State private var connectionStatus: String?
    @State private var connectionOK = false

    var body: some View {
        Form {
            Section("Server") {
                TextField("Server URL", text: $serverURL, prompt: Text(Defaults.serverURL))
                HStack {
                    Button("Test Connection") {
                        Task { await refreshModels(reportStatus: true) }
                    }
                    if let status = connectionStatus {
                        Text(status)
                            .font(.caption)
                            .foregroundStyle(connectionOK ? .green : .red)
                    }
                }
            }

            Section("Model") {
                HStack {
                    Picker("Model", selection: $model) {
                        // Keep the stored model selectable even if the server list is unavailable.
                        if !availableModels.contains(model) {
                            Text(model).tag(model)
                        }
                        ForEach(availableModels, id: \.self) { name in
                            Text(name).tag(name)
                        }
                    }
                    Button {
                        Task { await refreshModels(reportStatus: false) }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    .help("Refresh model list")
                }
            }

            Section("Generation") {
                HStack {
                    Slider(value: $temperature, in: 0...1.5, step: 0.05) {
                        Text("Temperature")
                    }
                    Text(temperature, format: .number.precision(.fractionLength(2)))
                        .monospacedDigit()
                        .frame(width: 40, alignment: .trailing)
                }
            }

            Section {
                TextEditor(text: $customPrompt)
                    .font(.system(.caption, design: .monospaced))
                    .frame(height: 100)
                Button("Reset to Default") {
                    customPrompt = ""
                }
                .disabled(customPrompt.isEmpty)
            } header: {
                Text("System Prompt")
            } footer: {
                Text("Leave empty to use the built-in prompt. {style} and {tone} are replaced with the current selections.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
        .frame(width: 440)
        .task { await refreshModels(reportStatus: false) }
    }

    private func refreshModels(reportStatus: Bool) async {
        do {
            let models = try await OllamaClient.listModels(baseURLString: serverURL)
            availableModels = models
            connectionOK = true
            if reportStatus {
                connectionStatus = "Connected — \(models.count) model(s) found"
            }
        } catch {
            connectionOK = false
            if reportStatus {
                connectionStatus = error.localizedDescription
            }
        }
    }
}
