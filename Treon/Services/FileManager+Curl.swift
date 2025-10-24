//
//  FileManager+Curl.swift
//  Treon
//
//  Created by Vivek on 2025-10-19.
//  Copyright © 2025 Treon. All rights reserved.
//

import Foundation

extension TreonFileManager {
    struct ParsedCurlCommand {
        let url: URL
        let method: String
        let headers: [String: String]
        let body: String?
    }

    func executeCurlCommand(_ command: String) async throws -> FileInfo {
        let parsedCommand = try parseCurlCommand(command)

        let request = buildURLRequest(from: parsedCommand)

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            try validateHTTPResponse(response)
            try validateContentSize(data)
            let content = try decodeUTF8(data)
            try validateJSON(data)
            return buildFileInfo(from: parsedCommand.url, data: data, content: content)
        } catch let error as FileManagerError {
            throw error
        } catch {
            throw FileManagerError.networkError(error.localizedDescription)
        }
    }

    private func buildURLRequest(from parsed: ParsedCurlCommand) -> URLRequest {
        var request = URLRequest(url: parsed.url)
        request.httpMethod = parsed.method
        request.allHTTPHeaderFields = parsed.headers
        if let body = parsed.body { request.httpBody = body.data(using: .utf8) }
        return request
    }

    private func validateHTTPResponse(_ response: URLResponse) throws {
        if let httpResponse = response as? HTTPURLResponse, !(200...299 ~= httpResponse.statusCode) {
            throw FileManagerError.networkError("HTTP \(httpResponse.statusCode)")
        }
    }

    private func validateContentSize(_ data: Data) throws {
        guard data.count <= maxFileSize else {
            throw FileManagerError.fileTooLarge(Int64(data.count), maxFileSize)
        }
    }

    private func decodeUTF8(_ data: Data) throws -> String {
        guard let content = String(data: data, encoding: .utf8) else {
            throw FileManagerError.invalidJSON("Unable to decode response as UTF-8")
        }
        return content
    }

    private func validateJSON(_ data: Data) throws {
        do { _ = try JSONSerialization.jsonObject(with: data, options: []) } catch {
            throw FileManagerError.invalidJSON("Response is not valid JSON: \(error.localizedDescription)")
        }
    }

    private func buildFileInfo(from url: URL, data: Data, content: String) -> FileInfo {
        return FileInfo(
            url: url,
            name: "cURL Response",
            size: Int64(data.count),
            modifiedDate: Date(),
            isValidJSON: true,
            errorMessage: nil,
            content: content
        )
    }

    func parseCurlCommand(_ command: String) throws -> ParsedCurlCommand {
        let components = tokenize(command)
        guard components.first?.lowercased() == "curl" else {
            throw FileManagerError.invalidJSON("Command must start with 'curl'")
        }
        var method = "GET"
        var headers: [String: String] = [:]
        var body: String?
        var url: URL?
        var index = 1
        while index < components.count {
            (method, headers, body, url, index) = try processComponent(
                components: components,
                index: index,
                method: method,
                headers: headers,
                body: body,
                url: url
            )
        }
        guard let finalURL = url else {
            throw FileManagerError.invalidJSON("No valid URL found in cURL command")
        }
        return ParsedCurlCommand(url: finalURL, method: method, headers: headers, body: body)
    }

    private func tokenize(_ command: String) -> [String] {
        command.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }
    }

    private func processComponent(components: [String], index: Int, method: String, headers: [String: String], body: String?, url: URL?) throws -> (String, [String: String], String?, URL?, Int) {
        var i = index
        var m = method
        var h = headers
        var b = body
        var u = url
        let component = components[i]
        switch component {
        case "-X", "--request":
            if i + 1 < components.count { m = components[i + 1].uppercased(); i += 1 }
        case "-H", "--header":
            if i + 1 < components.count { h = setHeader(h, header: components[i + 1]); i += 1 }
        case "-d", "--data", "--data-raw":
            if i + 1 < components.count { b = components[i + 1]; i += 1 }
        default:
            if component.hasPrefix("http://") || component.hasPrefix("https://") {
                u = URL(string: component)
            }
        }
        return (m, h, b, u, i + 1)
    }

    private func setHeader(_ headers: [String: String], header: String) -> [String: String] {
        var out = headers
        if let colonIndex = header.firstIndex(of: ":") {
            let key = String(header[..<colonIndex]).trimmingCharacters(in: .whitespaces)
            let value = String(header[header.index(after: colonIndex)...]).trimmingCharacters(in: .whitespaces)
            out[key] = value
        }
        return out
    }
}


