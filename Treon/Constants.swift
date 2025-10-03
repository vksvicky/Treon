import Foundation
import OSLog

public enum AppConstants {
    public static let bundleIdentifierRoot = "club.cycleruncode"
    public static let appName = "Treon"
    public static let websiteURL = URL(string: "https://cycleruncode.club")!
    public static let supportEmail = "support@cycleruncode.club"
}

public enum Loggers {
    public static let subsystem = "club.cycleruncode.treon"
    public static let ui = Logger(subsystem: subsystem, category: "ui")
    public static let parsing = Logger(subsystem: subsystem, category: "parsing")
    public static let format = Logger(subsystem: subsystem, category: "format")
    public static let query = Logger(subsystem: subsystem, category: "query")
    public static let history = Logger(subsystem: subsystem, category: "history")
    public static let scripts = Logger(subsystem: subsystem, category: "scripts")
    public static let integrations = Logger(subsystem: subsystem, category: "integrations")
    public static let perf = Logger(subsystem: subsystem, category: "perf")
}

public enum LocalizationKeys {
    public enum General {
        public static let ok = "general.ok"
        public static let cancel = "general.cancel"
    }
    public enum Errors {
        public static let parseFailed = "errors.parse_failed"
    }
}


