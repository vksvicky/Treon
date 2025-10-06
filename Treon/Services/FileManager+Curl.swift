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
        
        var request = URLRequest(url: parsedCommand.url)
        request.httpMethod = parsedCommand.method
        request.allHTTPHeaderFields = parsedCommand.headers
        
        if let body = parsedCommand.body {
            request.httpBody = body.data(using: .utf8)
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                guard 200...299 ~= httpResponse.statusCode else {
                    throw FileManagerError.networkError("HTTP \(httpResponse.statusCode)")
                }
            }
            
            guard data.count <= maxFileSize else {
                throw FileManagerError.fileTooLarge(Int64(data.count), maxFileSize)
            }
            
            guard let content = String(data: data, encoding: .utf8) else {
                throw FileManagerError.invalidJSON("Unable to decode response as UTF-8")
            }
            
            do { _ = try JSONSerialization.jsonObject(with: data, options: []) } catch {
                throw FileManagerError.invalidJSON("Response is not valid JSON: \(error.localizedDescription)")
            }
            
            return FileInfo(
                url: parsedCommand.url,
                name: "cURL Response",
                size: Int64(data.count),
                modifiedDate: Date(),
                isValidJSON: true,
                errorMessage: nil,
                content: content
            )
        } catch let error as FileManagerError {
            throw error
        } catch {
            throw FileManagerError.networkError(error.localizedDescription)
        }
    }
    
    func parseCurlCommand(_ command: String) throws -> ParsedCurlCommand {
        let components = command.components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
        
        guard components.first?.lowercased() == "curl" else {
            throw FileManagerError.invalidJSON("Command must start with 'curl'")
        }
        
        var url: URL?
        var method = "GET"
        var headers: [String: String] = [:]
        var body: String?
        
        var i = 1
        while i < components.count {
            let component = components[i]
            
            switch component {
            case "-X", "--request":
                if i + 1 < components.count {
                    method = components[i + 1].uppercased()
                    i += 1
                }
            case "-H", "--header":
                if i + 1 < components.count {
                    let header = components[i + 1]
                    if let colonIndex = header.firstIndex(of: ":") {
                        let key = String(header[..<colonIndex]).trimmingCharacters(in: .whitespaces)
                        let value = String(header[header.index(after: colonIndex)...]).trimmingCharacters(in: .whitespaces)
                        headers[key] = value
                    }
                    i += 1
                }
            case "-d", "--data", "--data-raw":
                if i + 1 < components.count {
                    body = components[i + 1]
                    i += 1
                }
            default:
                if component.hasPrefix("http://") || component.hasPrefix("https://") {
                    url = URL(string: component)
                }
            }
            i += 1
        }
        
        guard let finalURL = url else {
            throw FileManagerError.invalidJSON("No valid URL found in cURL command")
        }
        
        return ParsedCurlCommand(url: finalURL, method: method, headers: headers, body: body)
    }
}


