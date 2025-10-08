//
//  AppDelegate.swift
//  Treon
//
//  Created by Vivek Krishnan on 03/10/2025.
//

import Cocoa
import SwiftUI

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
    var window: NSWindow?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        print("AppDelegate: applicationDidFinishLaunching called")
        if handleIfRunningUnderTests() { return }
        if handleIfCLI() { return }
        print("AppDelegate: Running in GUI mode")
        setupMenuActions()
    }
    
    private func setupMenuActions() {
        // Connect the Preferences menu item to show settings
        if let mainMenu = NSApp.mainMenu,
           let appMenu = mainMenu.item(at: 0)?.submenu,
           let preferencesItem = appMenu.item(withTitle: "Preferences…") {
            preferencesItem.target = self
            preferencesItem.action = #selector(showPreferences)
        }
    }
    
    @objc private func showPreferences() {
        SettingsWindowController.shared.showWindow()
    }

    private func handleIfRunningUnderTests() -> Bool {
        if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil || NSClassFromString("XCTest") != nil {
            print("AppDelegate: Detected test environment - skipping GUI setup")
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
