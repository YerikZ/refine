import AppKit
import SwiftUI

struct ContentView: View {
    @Bindable var engine: RewriteEngine

    @AppStorage(Defaults.Key.mode) private var modeRaw = Mode.rewrite.rawValue
    @AppStorage(Defaults.Key.style) private var styleRaw = Style.professional.rawValue
    @AppStorage(Defaults.Key.tone) private var toneRaw = Tone.neutral.rawValue
    @AppStorage(Defaults.Key.length) private var lengthRaw = Length.normal.rawValue

    @State private var showHistory = false
    @State private var hoveredMode: Mode?
    @State private var hoveredEntry: UUID?

    @Environment(\.openSettings) private var openSettings

    private var mode: Mode { Mode(rawValue: modeRaw) ?? .rewrite }
    private var style: Style { Style(rawValue: styleRaw) ?? .professional }
    private var tone: Tone { Tone(rawValue: toneRaw) ?? .neutral }
    private var length: Length { Length(rawValue: lengthRaw) ?? .normal }
    private var canRun: Bool { !engine.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            editor
            if let output = engine.output {
                resultCard(output)
            }
            if let message = engine.errorMessage {
                Text(message)
                    .font(.system(size: 12))
                    .foregroundStyle(.red)
                    .lineLimit(3)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)
            }
            segmentedControl
            selects
            Rectangle()
                .fill(Theme.divider)
                .frame(height: 1)
                .padding(.horizontal, 16)
            actionRow
            if showHistory {
                historyDrawer
            }
        }
        .frame(width: Theme.panelWidth)
        .background(Theme.panelSurface)
        .animation(.easeOut(duration: 0.25), value: engine.hasOutput)
        .animation(.easeOut(duration: 0.2), value: showHistory)
        .onChange(of: engine.text) { _, newText in
            engine.textDidChange(newText)
        }
    }

    // MARK: - Textarea

    private var editor: some View {
        ZStack(alignment: .topLeading) {
            TextEditor(text: $engine.text)
                .font(.system(size: 15))
                .lineSpacing(4)
                .foregroundStyle(Theme.textDark)
                .scrollContentBackground(.hidden)
                .frame(height: 96)
            if engine.text.isEmpty {
                // 5pt matches NSTextView's default line-fragment padding.
                Text("Paste or type text to rewrite…")
                    .font(.system(size: 15))
                    .foregroundStyle(Theme.muted50)
                    .padding(.leading, 5)
                    .allowsHitTesting(false)
            }
        }
        .padding(.top, 14)
        .padding(.horizontal, 16)
        .padding(.bottom, 10)
    }

    // MARK: - Result card

    private func resultCard(_ output: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("RESULT")
                .font(.system(size: 11, weight: .semibold))
                .kerning(0.44)
                .foregroundStyle(Theme.accent)
            ScrollView {
                Text(output)
                    .font(.system(size: 14))
                    .lineSpacing(3.5)
                    .foregroundStyle(Theme.textBody)
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(height: 130)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 14)
        .background(Theme.cardBg, in: RoundedRectangle(cornerRadius: 10))
        .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(Theme.cardBorder, lineWidth: 1))
        .padding(.horizontal, 16)
        .padding(.bottom, 12)
        .transition(.opacity.combined(with: .offset(y: 4)))
    }

    // MARK: - Segmented control

    private var segmentedControl: some View {
        HStack(spacing: 4) {
            ForEach(Mode.allCases) { tab in
                let active = tab == mode
                Text(tab.displayName)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(active ? Theme.textDark : Theme.muted50)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 7)
                    .background(
                        active ? Theme.pillWhite : (hoveredMode == tab ? Theme.hoverBg : .clear),
                        in: RoundedRectangle(cornerRadius: 8)
                    )
                    .shadow(color: active ? Theme.shadowBase.opacity(0.15) : .clear, radius: 1.5, y: 1)
                    .contentShape(Rectangle())
                    .onHover { hovering in
                        hoveredMode = hovering ? tab : (hoveredMode == tab ? nil : hoveredMode)
                    }
                    .onTapGesture {
                        guard tab != mode else { return }
                        modeRaw = tab.rawValue
                        engine.invalidateOutput()
                    }
            }
        }
        .padding(3)
        .background(Theme.track, in: RoundedRectangle(cornerRadius: 10))
        .padding(.horizontal, 16)
        .padding(.bottom, 14)
    }

    // MARK: - Style / Tone selects

    private var selects: some View {
        HStack(spacing: 10) {
            labeledSelect("Style", selection: $styleRaw, options: Style.allCases.map { ($0.rawValue, $0.displayName) })
            labeledSelect("Tone", selection: $toneRaw, options: Tone.allCases.map { ($0.rawValue, $0.displayName) })
            labeledSelect("Length", selection: $lengthRaw, options: Length.allCases.map { ($0.rawValue, $0.displayName) })
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 14)
    }

    private func labeledSelect(_ label: String, selection: Binding<String>, options: [(raw: String, name: String)]) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Theme.muted50)
            Menu {
                ForEach(options, id: \.raw) { option in
                    Button(option.name) { selection.wrappedValue = option.raw }
                }
            } label: {
                HStack {
                    Text(options.first { $0.raw == selection.wrappedValue }?.name ?? selection.wrappedValue)
                        .font(.system(size: 14))
                        .foregroundStyle(Theme.textDark)
                    Spacer()
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundStyle(Theme.muted50)
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 10)
                .background(.white, in: RoundedRectangle(cornerRadius: 8))
                .overlay(RoundedRectangle(cornerRadius: 8).strokeBorder(Theme.border, lineWidth: 1))
                .contentShape(Rectangle())
            }
            .menuStyle(.button)
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Action row

    private var actionRow: some View {
        HStack(spacing: 8) {
            primaryButton
            Button {
                engine.revert()
            } label: {
                Text("Revert")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(engine.hasOutput ? Theme.textRevert : Theme.muted65)
                    .padding(.vertical, 9)
                    .padding(.horizontal, 16)
                    .background(Theme.buttonGray, in: RoundedRectangle(cornerRadius: 9))
            }
            .buttonStyle(.plain)
            iconButton("doc.on.doc", help: "Copy result") {
                guard let output = engine.output else { return }
                NSPasteboard.general.clearContents()
                NSPasteboard.general.setString(output, forType: .string)
            }
            iconButton("xmark", help: "Clear text and result") {
                engine.clear()
            }
            .keyboardShortcut(.delete, modifiers: .command)
            iconButton("clock.arrow.circlepath", help: "History", active: showHistory) {
                showHistory.toggle()
            }
            iconButton("gearshape", help: "Settings") {
                NSApp.activate(ignoringOtherApps: true)
                openSettings()
            }
            iconButton("power", help: "Quit Refine") {
                NSApp.terminate(nil)
            }
            .keyboardShortcut("q", modifiers: .command)
        }
        .padding(.top, 12)
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
    }

    private var primaryButton: some View {
        Button {
            if engine.isStreaming {
                engine.cancel()
            } else {
                engine.perform(mode, style: style, tone: tone, length: length)
            }
        } label: {
            HStack(spacing: 8) {
                if engine.isStreaming {
                    ProgressView()
                        .controlSize(.small)
                        .tint(.white)
                }
                Text(engine.isStreaming ? "Working…" : mode.displayName)
                    .font(.system(size: 14, weight: .semibold))
            }
            .foregroundStyle(canRun || engine.isStreaming ? .white : Theme.muted60)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 9)
            .background(
                canRun || engine.isStreaming ? Theme.accent : Theme.disabledBg,
                in: RoundedRectangle(cornerRadius: 9)
            )
        }
        .buttonStyle(.plain)
        .keyboardShortcut(.return, modifiers: .command)
        .disabled(!canRun && !engine.isStreaming)
    }

    private func iconButton(_ symbol: String, help: String, active: Bool = false, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Theme.gray40)
                .frame(width: 34, height: 34)
                .background(active ? Theme.hoverBg : Theme.buttonGray, in: RoundedRectangle(cornerRadius: 9))
        }
        .buttonStyle(.plain)
        .help(help)
    }

    // MARK: - History drawer

    private var historyDrawer: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("HISTORY")
                .font(.system(size: 12, weight: .semibold))
                .kerning(0.48)
                .foregroundStyle(Theme.gray40)
            if engine.history.isEmpty {
                Text("No runs yet")
                    .font(.system(size: 12))
                    .foregroundStyle(Theme.muted55)
            }
            ForEach(Array(engine.history.enumerated()), id: \.element.id) { index, entry in
                HStack(spacing: 8) {
                    Circle()
                        .fill(index == 0 ? Theme.accent : Theme.dotGray)
                        .frame(width: 6, height: 6)
                    Text(entry.label)
                        .font(.system(size: 13))
                        .foregroundStyle(Theme.textRevert)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(entry.relativeTime)
                        .font(.system(size: 12))
                        .foregroundStyle(Theme.muted55)
                }
                .padding(.vertical, 6)
                .padding(.horizontal, 8)
                .background(
                    hoveredEntry == entry.id ? Theme.buttonGray : .clear,
                    in: RoundedRectangle(cornerRadius: 7)
                )
                .contentShape(Rectangle())
                .onHover { hovering in
                    hoveredEntry = hovering ? entry.id : (hoveredEntry == entry.id ? nil : hoveredEntry)
                }
                .onTapGesture {
                    modeRaw = entry.mode
                    styleRaw = entry.style
                    toneRaw = entry.tone
                    lengthRaw = entry.length
                    engine.restore(entry)
                }
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.drawerBg, in: RoundedRectangle(cornerRadius: 10))
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
        .transition(.opacity.combined(with: .offset(y: 4)))
    }
}
