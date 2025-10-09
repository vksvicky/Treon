import Foundation
import OSLog

public struct JSONFormatter {
    public init() {}

    // Static convenience methods
    public static func prettyPrint(_ jsonString: String) throws -> String {
        let data = Data(jsonString.utf8)
        let formatter = JSONFormatter()
        let formattedData = try formatter.prettyPrinted(from: data)
        return String(data: formattedData, encoding: .utf8) ?? jsonString
    }

    public static func minify(_ jsonString: String) throws -> String {
        let data = Data(jsonString.utf8)
        let formatter = JSONFormatter()
        let minifiedData = try formatter.minified(from: data)
        return String(data: minifiedData, encoding: .utf8) ?? jsonString
    }

    public func prettyPrinted(from data: Data, indent: Int = 2) throws -> Data {
        // Loggers.format.debug("Pretty print start, size=\(data.count)")
        let object = try JSONSerialization.jsonObject(with: data, options: [])
        let opts: JSONSerialization.WritingOptions = [.prettyPrinted, .sortedKeys]
        // Note: JSONSerialization.isValidJSONObject only validates objects, not arrays
        // But if we can parse it without error, it's valid JSON
        let formatted = try JSONSerialization.data(withJSONObject: object, options: opts)
        // Loggers.format.debug("Pretty print done, size=\(formatted.count)")
        return formatted
    }

    public func minified(from data: Data) throws -> Data {
        // Loggers.format.debug("Minify start, size=\(data.count)")
        let object = try JSONSerialization.jsonObject(with: data, options: [])
        // Note: JSONSerialization.isValidJSONObject only validates objects, not arrays
        // But if we can parse it without error, it's valid JSON
        let formatted = try JSONSerialization.data(withJSONObject: object, options: [])
        // Loggers.format.debug("Minify done, size=\(formatted.count)")
        return formatted
    }
}


