import Foundation
import OSLog

public struct JSONFormatter {
    public init() {}

    public func prettyPrinted(from data: Data, indent: Int = 2) throws -> Data {
        // Loggers.format.debug("Pretty print start, size=\(data.count)")
        let object = try JSONSerialization.jsonObject(with: data, options: [])
        let opts: JSONSerialization.WritingOptions = [.prettyPrinted, .sortedKeys]
        guard JSONSerialization.isValidJSONObject(object) else {
            throw NSError(domain: "club.cycleruncode.treon", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON object"])
        }
        let formatted = try JSONSerialization.data(withJSONObject: object, options: opts)
        // Loggers.format.debug("Pretty print done, size=\(formatted.count)")
        return formatted
    }

    public func minified(from data: Data) throws -> Data {
        // Loggers.format.debug("Minify start, size=\(data.count)")
        let object = try JSONSerialization.jsonObject(with: data, options: [])
        guard JSONSerialization.isValidJSONObject(object) else {
            throw NSError(domain: "club.cycleruncode.treon", code: 2, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON object"])
        }
        let formatted = try JSONSerialization.data(withJSONObject: object, options: [])
        // Loggers.format.debug("Minify done, size=\(formatted.count)")
        return formatted
    }
}


