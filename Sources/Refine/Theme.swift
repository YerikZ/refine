import SwiftUI

/// Design tokens from the UI redesign handoff. sRGB values converted from the
/// spec's OKLCH tokens (neutral hue 260, accent hue 258).
enum Theme {
    // oklch(0.55 0.18 258)
    static let accent = Color(red: 0.1216, green: 0.4274, blue: 0.8462)
    // oklch(0.22 0.006 260)
    static let textDark = Color(red: 0.0978, green: 0.1046, blue: 0.1154)
    // oklch(0.25 0.006 260)
    static let textBody = Color(red: 0.1252, green: 0.1321, blue: 0.1433)
    // oklch(0.3 0.006 260)
    static let textRevert = Color(red: 0.1726, green: 0.1799, blue: 0.1917)
    // oklch(0.4 0.006 260) — icon strokes, history header
    static let gray40 = Color(red: 0.2735, green: 0.2814, blue: 0.294)
    // oklch(0.5 0.006 260) — field labels, inactive tabs
    static let muted50 = Color(red: 0.3811, green: 0.3894, blue: 0.4027)
    // oklch(0.55 0.006 260) — history timestamps
    static let muted55 = Color(red: 0.437, green: 0.4455, blue: 0.4592)
    // oklch(0.6 0.006 260) — disabled button text
    static let muted60 = Color(red: 0.4943, green: 0.503, blue: 0.517)
    // oklch(0.65 0.006 260) — revert text without result
    static let muted65 = Color(red: 0.5528, green: 0.5616, blue: 0.5759)
    // oklch(0.75 0.006 260) — history dot (non-newest)
    static let dotGray = Color(red: 0.6731, green: 0.6823, blue: 0.697)
    // oklch(0.85 0.006 260) — disabled primary button
    static let disabledBg = Color(red: 0.7975, green: 0.807, blue: 0.8223)
    // oklch(0.88 0.006 260) — tab hover, select borders, active icon button
    static let hoverBg = Color(red: 0.8356, green: 0.8452, blue: 0.8606)
    static let border = Color(red: 0.8356, green: 0.8452, blue: 0.8606)
    // oklch(0.9 0.006 260)
    static let cardBorder = Color(red: 0.8612, green: 0.8708, blue: 0.8863)
    // oklch(0.9 0.005 260)
    static let divider = Color(red: 0.8626, green: 0.8706, blue: 0.8835)
    // oklch(0.92 0.005 260) — segmented track
    static let track = Color(red: 0.8883, green: 0.8964, blue: 0.9094)
    // oklch(0.94 0.005 260) — secondary buttons
    static let buttonGray = Color(red: 0.9142, green: 0.9223, blue: 0.9353)
    // oklch(0.97 0.01 260) — result card
    static let cardBg = Color(red: 0.9459, green: 0.9622, blue: 0.9885)
    // oklch(0.97 0.005 260) — history drawer
    static let drawerBg = Color(red: 0.9533, green: 0.9614, blue: 0.9746)
    // oklch(0.99 0 0) — active tab pill
    static let pillWhite = Color(red: 0.9868, green: 0.9868, blue: 0.9868)
    // oklch(0.2 0.02 260) — shadow base
    static let shadowBase = Color(red: 0.0656, green: 0.0872, blue: 0.1224)
    // oklch(0.99 0.003 260 / 0.86) — panel surface over the window's blur material
    static let panelSurface = Color(red: 0.9824, green: 0.9873, blue: 0.9953).opacity(0.86)

    static let panelWidth: CGFloat = 440
}
