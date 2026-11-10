import AppKit

/// Entry point of the standalone MenuPulse app. Everything else lives in
/// Sources/MenuPulse/Monitor, which other apps can embed as-is.
@main
@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var controller: MonitorStatusController?

    static func main() {
        let app = NSApplication.shared
        let delegate = AppDelegate()
        app.delegate = delegate
        // Menu bar only: no Dock icon, no main window.
        app.setActivationPolicy(.accessory)
        app.run()
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        controller = MonitorStatusController(mode: .standalone)
    }
}
