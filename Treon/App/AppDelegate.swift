//
//  AppDelegate.swift
//  Treon
//
//  Created by Vivek Krishnan on 03/10/2025.
//

import Cocoa
import SwiftUI
import OSLog

enum CLIError: Error { case usage }

@discardableResult
func runCLI() throws -> Int32 {
    var args = CommandLine.arguments.dropFirst()
    guard let cmd = args.first else { throw CLIError.usage }
    args = args.dropFirst()
    switch cmd {
    case "format":
        let data = try FileHandle.standardInput.readToEnd() ?? Data()
        let pretty = try JSONFormatter().prettyPrinted(from: data)
        FileHandle.standardOutput.write(pretty)
        return 0
    case "minify":
        let data = try FileHandle.standardInput.readToEnd() ?? Data()
        let min = try JSONFormatter().minified(from: data)
        FileHandle.standardOutput.write(min)
        return 0
    default:
        fputs("Usage: treon <format|minify>\n", stderr)
        return 2
    }
}

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    private let logger = Logger(subsystem: "club.cycleruncode.Treon", category: "AppDelegate")
    var window: NSWindow?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        logger.info("AppDelegate: applicationDidFinishLaunching called")
        if handleIfRunningUnderTests() { return }
        if handleIfCLI() { return }
        logger.info("AppDelegate: Running in GUI mode")
        setupMenuActions()
    }

    private func setupMenuActions() {
        // Use a delayed approach to ensure the menu is fully loaded
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.connectPreferencesMenuItem()
            self.connectFileMenuActions()
            self.connectEditMenuActions()
        }
    }

    private func connectPreferencesMenuItem() {
        // Connect the Preferences menu item to show settings
        guard let mainMenu = NSApp.mainMenu else {
            logger.error("AppDelegate: Could not find main menu")
            return
        }

        guard let appMenu = mainMenu.item(at: 0)?.submenu else {
            logger.error("AppDelegate: Could not find app menu")
            return
        }

        // Find the Preferences menu item by iterating through all items
        var preferencesItem: NSMenuItem?
        for i in 0..<appMenu.numberOfItems {
            if let item = appMenu.item(at: i) {
                logger.info("AppDelegate: Menu item \(i): '\(item.title)'")
                if item.title == "Settings…" {
                    preferencesItem = item
                    break
                }
            }
        }

        if let preferencesItem = preferencesItem {
            preferencesItem.target = self
            preferencesItem.action = #selector(showPreferences)
            logger.info("AppDelegate: Successfully connected Settings menu item")
        } else {
            logger.error("AppDelegate: Could not find Settings menu item")
        }
    }

    @IBAction func showPreferences(_ sender: Any?) {
        logger.info("AppDelegate: showPreferences called")
        SettingsWindowController.shared.showWindow()
        logger.info("AppDelegate: showWindow called")
    }

    // Alternative method to show preferences via keyboard shortcut
    @objc func showPreferencesViaShortcut() {
        logger.info("AppDelegate: showPreferencesViaShortcut called")
        SettingsWindowController.shared.showWindow()
    }
    
    private func connectFileMenuActions() {
        guard let mainMenu = NSApp.mainMenu else {
            logger.error("AppDelegate: Could not find main menu")
            return
        }
        
        // Find the File menu (usually at index 1)
        guard let fileMenu = mainMenu.item(at: 1)?.submenu else {
            logger.error("AppDelegate: Could not find File menu")
            return
        }
        
        // Connect Open menu item (CMD+O)
        if let openItem = fileMenu.item(withTitle: "Open…") {
            openItem.target = self
            openItem.action = #selector(openDocument(_:))
            logger.info("AppDelegate: Connected Open menu item")
        }
        
        // Connect New menu item (CMD+N)
        if let newItem = fileMenu.item(withTitle: "New") {
            newItem.target = self
            newItem.action = #selector(newDocument(_:))
            logger.info("AppDelegate: Connected New menu item")
        }
        
        // Connect Save menu item (CMD+S)
        if let saveItem = fileMenu.item(withTitle: "Save…") {
            saveItem.target = self
            saveItem.action = #selector(saveDocument(_:))
            logger.info("AppDelegate: Connected Save menu item")
        }
    }
    
    private func connectEditMenuActions() {
        guard let mainMenu = NSApp.mainMenu else {
            logger.error("AppDelegate: Could not find main menu")
            return
        }
        
        // Find the Edit menu (usually at index 2)
        guard let editMenu = mainMenu.item(at: 2)?.submenu else {
            logger.error("AppDelegate: Could not find Edit menu")
            return
        }
        
        // Connect Copy menu item (CMD+C)
        if let copyItem = editMenu.item(withTitle: "Copy") {
            copyItem.target = self
            copyItem.action = #selector(copy(_:))
            logger.info("AppDelegate: Connected Copy menu item")
        }
        
        // Connect Paste menu item (CMD+V)
        if let pasteItem = editMenu.item(withTitle: "Paste") {
            pasteItem.target = self
            pasteItem.action = #selector(paste(_:))
            logger.info("AppDelegate: Connected Paste menu item")
        }
        
        // Connect Cut menu item (CMD+X)
        if let cutItem = editMenu.item(withTitle: "Cut") {
            cutItem.target = self
            cutItem.action = #selector(cut(_:))
            logger.info("AppDelegate: Connected Cut menu item")
        }
        
        // Connect Select All menu item (CMD+A)
        if let selectAllItem = editMenu.item(withTitle: "Select All") {
            selectAllItem.target = self
            selectAllItem.action = #selector(selectAll(_:))
            logger.info("AppDelegate: Connected Select All menu item")
        }
    }
    
    // MARK: - File Menu Actions
    
    @IBAction func openDocument(_ sender: Any?) {
        logger.info("AppDelegate: openDocument called")
        // Post notification to trigger file open in SwiftUI
        NotificationCenter.default.post(name: NotificationNames.openFileRequested, object: nil)
    }
    
    @IBAction func newDocument(_ sender: Any?) {
        logger.info("AppDelegate: newDocument called")
        // Post notification to trigger new file creation in SwiftUI
        NotificationCenter.default.post(name: NotificationNames.newFileRequested, object: nil)
    }
    
    @IBAction func saveDocument(_ sender: Any?) {
        logger.info("AppDelegate: saveDocument called")
        // Post notification to trigger file save in SwiftUI
        NotificationCenter.default.post(name: NotificationNames.saveFileRequested, object: nil)
    }
    
    // MARK: - Edit Menu Actions
    
    @IBAction func copy(_ sender: Any?) {
        logger.info("AppDelegate: copy called")
        // Forward to first responder for proper text handling
        NSApp.sendAction(#selector(NSText.copy(_:)), to: nil, from: sender)
    }
    
    @IBAction func paste(_ sender: Any?) {
        logger.info("AppDelegate: paste called")
        // Forward to first responder for proper text handling
        NSApp.sendAction(#selector(NSText.paste(_:)), to: nil, from: sender)
    }
    
    @IBAction func cut(_ sender: Any?) {
        logger.info("AppDelegate: cut called")
        // Forward to first responder for proper text handling
        NSApp.sendAction(#selector(NSText.cut(_:)), to: nil, from: sender)
    }
    
    @IBAction func selectAll(_ sender: Any?) {
        logger.info("AppDelegate: selectAll called")
        // Forward to first responder for proper text handling
        NSApp.sendAction(#selector(NSText.selectAll(_:)), to: nil, from: sender)
    }

    private func handleIfRunningUnderTests() -> Bool {
        if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil || NSClassFromString("XCTest") != nil {
            logger.info("AppDelegate: Detected test environment - skipping GUI setup")
            NSApp.setActivationPolicy(.prohibited)
            return true
        }
        return false
    }

    private func handleIfCLI() -> Bool {
        let args = CommandLine.arguments
        let hasCLICommand = args.count > 1 && (args[1] == "format" || args[1] == "minify")
        guard hasCLICommand else { return false }
        do {
            let exitCode = try runCLI()
            NSApp.terminate(nil)
            exit(exitCode)
        } catch {
            print("CLI Error: \(error)")
            NSApp.terminate(nil)
            exit(1)
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }

    // Handle app termination when all windows are closed
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}
