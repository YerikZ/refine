// Draws the Retone app icon (1024x1024 PNG) with CoreGraphics.
// Usage: swift scripts/generate-icon.swift <output.png>
import AppKit

let outputPath = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "icon_1024.png"

let size = 1024
guard let rep = NSBitmapImageRep(
    bitmapDataPlanes: nil, pixelsWide: size, pixelsHigh: size,
    bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
    colorSpaceName: .calibratedRGB, bytesPerRow: 0, bitsPerPixel: 0
) else { fatalError("Could not create bitmap") }

NSGraphicsContext.saveGraphicsState()
let context = NSGraphicsContext(bitmapImageRep: rep)!
NSGraphicsContext.current = context

// macOS icon grid: 824pt content square centered in the 1024 canvas.
let bgRect = NSRect(x: 100, y: 100, width: 824, height: 824)
let bgPath = NSBezierPath(roundedRect: bgRect, xRadius: 185, yRadius: 185)

// Soft drop shadow behind the squircle.
context.cgContext.saveGState()
let shadow = NSShadow()
shadow.shadowOffset = NSSize(width: 0, height: -12)
shadow.shadowBlurRadius = 24
shadow.shadowColor = NSColor.black.withAlphaComponent(0.3)
shadow.set()
NSColor.black.set()
bgPath.fill()
context.cgContext.restoreGState()

// Indigo-violet diagonal gradient, light at top-left.
let light = NSColor(calibratedRed: 0.58, green: 0.51, blue: 0.98, alpha: 1)   // #9482FA
let dark = NSColor(calibratedRed: 0.27, green: 0.22, blue: 0.82, alpha: 1)    // #4538D1
NSGradient(colors: [light, dark])!.draw(in: bgPath, angle: -65)

// Glyph: two text lines, third line "re-toned" into a wave. White, y-up coords.
NSColor.white.set()
let glyphLeft = 320.0, glyphRight = 704.0
let barHeight = 58.0

NSBezierPath(
    roundedRect: NSRect(x: glyphLeft, y: 642 - barHeight / 2, width: glyphRight - glyphLeft, height: barHeight),
    xRadius: barHeight / 2, yRadius: barHeight / 2
).fill()
NSBezierPath(
    roundedRect: NSRect(x: glyphLeft, y: 512 - barHeight / 2, width: 250, height: barHeight),
    xRadius: barHeight / 2, yRadius: barHeight / 2
).fill()

let wave = NSBezierPath()
wave.lineWidth = barHeight
wave.lineCapStyle = .round
wave.lineJoinStyle = .round
let waveCenterY = 382.0, amplitude = 34.0, periods = 1.5
for step in 0...120 {
    let t = Double(step) / 120
    let x = glyphLeft + t * (glyphRight - glyphLeft)
    let y = waveCenterY + amplitude * sin(2 * .pi * periods * t)
    if step == 0 { wave.move(to: NSPoint(x: x, y: y)) } else { wave.line(to: NSPoint(x: x, y: y)) }
}
wave.stroke()

NSGraphicsContext.current?.flushGraphics()
NSGraphicsContext.restoreGraphicsState()

guard let png = rep.representation(using: .png, properties: [:]) else { fatalError("PNG encode failed") }
try png.write(to: URL(fileURLWithPath: outputPath))
print("Wrote \(outputPath)")
