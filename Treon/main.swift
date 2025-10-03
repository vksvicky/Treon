import Foundation
import Cocoa

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

@MainActor
func runGUI() {
    print("Main: Starting GUI mode")
    let app = NSApplication.shared
    print("Main: NSApplication created")
    let delegate = AppDelegate()
    print("Main: AppDelegate created")
    app.delegate = delegate
    print("Main: Delegate set, starting app.run()")
    app.run()
    print("Main: app.run() finished")
}

// Check if we should run in CLI mode
if CommandLine.arguments.count > 1 {
    exit(try runCLI())
} else {
    // Run as GUI app
    MainActor.assumeIsolated {
        runGUI()
    }
}
