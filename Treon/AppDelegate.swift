//
//  AppDelegate.swift
//  Treon
//
//  Created by Vivek Krishnan on 03/10/2025.
//

import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        print("AppDelegate: applicationDidFinishLaunching called")
        
        // Create a simple test view first
        let contentView = VStack {
            Text("Treon - JSON Formatter")
                .font(.largeTitle)
                .padding()
            
            Text("Welcome to Treon!")
                .font(.headline)
                .padding()
            
            Text("This is a simple test to see if the app loads correctly.")
                .padding()
            
            Button("Test Button") {
                print("Button clicked!")
            }
            .padding()
        }
        .frame(minWidth: 400, minHeight: 300)

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 1000, height: 700),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.title = "Treon"
        window.center()
        window.contentViewController = NSHostingController(rootView: contentView)
        window.makeKeyAndOrderFront(nil)
        self.window = window

        print("AppDelegate: Window created and shown")
        NSApp.activate(ignoringOtherApps: true)
        print("AppDelegate: App activated")
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
}
