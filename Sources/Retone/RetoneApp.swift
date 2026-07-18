import AppKit
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Menu-bar-only: no Dock icon, even when run as a bare executable (`swift run`).
        NSApp.setActivationPolicy(.accessory)
    }
}

@main
struct RetoneApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @State private var engine = RewriteEngine()

    var body: some Scene {
        MenuBarExtra {
            ContentView(engine: engine)
        } label: {
            Image(nsImage: MenuBarIcon.image)
        }
        .menuBarExtraStyle(.window)

        Settings {
            SettingsView()
        }
    }
}
