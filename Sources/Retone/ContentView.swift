import AppKit
import SwiftUI

struct ContentView: View {
    @Bindable var engine: RewriteEngine

    @AppStorage(Defaults.Key.style) private var styleRaw = Style.professional.rawValue
    @AppStorage(Defaults.Key.tone) private var toneRaw = Tone.neutral.rawValue

    @Environment(\.openSettings) private var openSettings

    private var style: Style { Style(rawValue: styleRaw) ?? .professional }
    private var tone: Tone { Tone(rawValue: toneRaw) ?? .neutral }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack(alignment: .topLeading) {
                TextEditor(text: $engine.text)
                    .font(.body)
                    .frame(minHeight: 200)
                    .scrollContentBackground(.hidden)
                    .padding(6)
                    .background(.quaternary.opacity(0.5), in: RoundedRectangle(cornerRadius: 8))
                if engine.text.isEmpty {
                    Text("Paste or type text to rewrite…")
                        .foregroundStyle(.secondary)
                        .padding(.top, 10)
                        .padding(.leading, 12)
                        .allowsHitTesting(false)
                }
            }

            HStack(spacing: 12) {
                Picker("Style", selection: $styleRaw) {
                    ForEach(Style.allCases) { style in
                        Text(style.displayName).tag(style.rawValue)
                    }
                }
                Picker("Tone", selection: $toneRaw) {
                    ForEach(Tone.allCases) { tone in
                        Text(tone.displayName).tag(tone.rawValue)
                    }
                }
            }
            .pickerStyle(.menu)

            if let message = engine.errorMessage {
                Text(message)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .lineLimit(3)
            }

            HStack(spacing: 8) {
                if engine.isStreaming {
                    Button {
                        engine.cancel()
                    } label: {
                        HStack(spacing: 6) {
                            ProgressView().controlSize(.small)
                            Text("Stop")
                        }
                    }
                } else {
                    Button("Rewrite") {
                        engine.rewrite(style: style, tone: tone)
                    }
                    .buttonStyle(.borderedProminent)
                    .keyboardShortcut(.return, modifiers: .command)
                    .disabled(engine.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }

                Button("Revert") {
                    engine.revert()
                }
                .disabled(!engine.canRevert || engine.isStreaming)

                Button {
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(engine.text, forType: .string)
                } label: {
                    Image(systemName: "doc.on.doc")
                }
                .help("Copy text")
                .disabled(engine.text.isEmpty)

                Button {
                    engine.clear()
                } label: {
                    Image(systemName: "xmark.circle")
                }
                .help("Clear text and start fresh")
                .keyboardShortcut(.delete, modifiers: .command)
                .disabled(engine.text.isEmpty && engine.originalText == nil)

                Spacer()

                Button {
                    NSApp.activate(ignoringOtherApps: true)
                    openSettings()
                } label: {
                    Image(systemName: "gearshape")
                }
                .help("Settings")
            }
        }
        .padding(12)
        .frame(width: 360)
    }
}
