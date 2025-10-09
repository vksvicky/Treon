import Cocoa
import SwiftUI
import OSLog

class SettingsWindowController: NSWindowController {
    static let shared = SettingsWindowController()
    private let logger = Logger(subsystem: "club.cycleruncode.Treon", category: "SettingsWindowController")



    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private init() {
        // Create the settings view
        let settingsView = SettingsView()
        let hostingController = NSHostingController(rootView: settingsView)

        // Create window
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 600, height: 500),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )

        window.title = "Settings"
        window.contentViewController = hostingController
        window.isReleasedWhenClosed = false
        window.setFrameAutosaveName("SettingsWindow")

        super.init(window: window)

        // DON'T call center() here - move it to showWindow
    }

    func showWindow() {
        logger.info("SettingsWindowController: showWindow called")

        guard let window = window else {
            logger.error("Window is nil")
            return
        }

        // Center the window BEFORE showing it (but after it's been initialized)
        window.setFrame(NSRect(x: 0, y: 0, width: 600, height: 500), display: false)
        window.center()

        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)

        logger.info("SettingsWindowController: window shown, isVisible: \(window.isVisible)")
    }
}