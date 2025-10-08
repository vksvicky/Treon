import Cocoa
import SwiftUI
import OSLog

class SettingsWindowController: NSWindowController {
    static let shared = SettingsWindowController()
    private let logger = Logger(subsystem: "club.cycleruncode.Treon", category: "SettingsWindowController")
    
    private init() {
        let settingsView = SettingsView()
        let hostingController = NSHostingController(rootView: settingsView)
        
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 500, height: 400),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        
        window.title = "Settings"
        window.contentViewController = hostingController
        window.center()
        window.setFrameAutosaveName("SettingsWindow")
        
        super.init(window: window)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func showWindow() {
        logger.info("SettingsWindowController: showWindow called")
        logger.info("SettingsWindowController: window = \(String(describing: self.window))")
        
        guard let window = window else {
            logger.error("SettingsWindowController: window is nil")
            return
        }
        
        // Show and bring to front
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        
        logger.info("SettingsWindowController: window should now be visible")
    }
}
