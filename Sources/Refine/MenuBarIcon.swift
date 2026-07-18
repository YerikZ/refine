import AppKit

/// Monochrome template version of the app icon glyph (text lines + tone wave),
/// drawn at runtime so no bundled asset is needed.
enum MenuBarIcon {
    static let image: NSImage = {
        let image = NSImage(size: NSSize(width: 18, height: 18), flipped: false) { _ in
            NSColor.black.set()

            NSBezierPath(
                roundedRect: NSRect(x: 1, y: 13.4, width: 16, height: 2.4),
                xRadius: 1.2, yRadius: 1.2
            ).fill()
            NSBezierPath(
                roundedRect: NSRect(x: 1, y: 8.3, width: 10.5, height: 2.4),
                xRadius: 1.2, yRadius: 1.2
            ).fill()

            let wave = NSBezierPath()
            wave.lineWidth = 2.4
            wave.lineCapStyle = .round
            wave.lineJoinStyle = .round
            for step in 0...48 {
                let t = Double(step) / 48
                let x = 2.2 + t * 13.6
                let y = 3.6 + 1.6 * sin(2 * .pi * 1.5 * t)
                if step == 0 { wave.move(to: NSPoint(x: x, y: y)) } else { wave.line(to: NSPoint(x: x, y: y)) }
            }
            wave.stroke()
            return true
        }
        image.isTemplate = true
        return image
    }()
}
