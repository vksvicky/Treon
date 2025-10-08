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
