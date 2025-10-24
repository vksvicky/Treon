//
//  FileManager+Networking.swift
//  Treon
//
//  Created by Vivek on 2025-10-19.
//  Copyright © 2025 Treon. All rights reserved.
//

import Foundation
import OSLog

extension TreonFileManager {
    func loadFromURL(_ url: URL) async throws -> FileInfo {
        logger.info("Loading content from URL: \(url.absoluteString)")

        do {
            let (data, response) = try await URLSession.shared.data(from: url)

            if let httpResponse = response as? HTTPURLResponse {
                guard 200...299 ~= httpResponse.statusCode else {
                    logger.error("HTTP error: \(httpResponse.statusCode)")
                    throw FileManagerError.networkError("HTTP \(httpResponse.statusCode)")
                }
            }

            guard data.count <= maxFileSize else {
                logger.error("Content size exceeds limit: \(data.count) bytes")
                throw FileManagerError.fileTooLarge(Int64(data.count), maxFileSize)
            }

            guard let content = String(data: data, encoding: .utf8) else {
                logger.error("Unable to decode content as UTF-8")
                throw FileManagerError.invalidJSON("Unable to decode content as UTF-8")
            }

            do {
                _ = try JSONSerialization.jsonObject(with: data, options: [])
            } catch {
                throw FileManagerError.invalidJSON("Invalid JSON format: \(error.localizedDescription)")
            }

            let fileName = url.lastPathComponent.isEmpty ? "URL Content" : url.lastPathComponent
            let fileInfo = FileInfo(
                url: url,
                name: fileName,
                size: Int64(data.count),
                modifiedDate: Date(),
                isValidJSON: true,
                errorMessage: nil,
                content: content
            )

            return fileInfo
        } catch let error as FileManagerError {
            throw error
        } catch {
            throw FileManagerError.networkError(error.localizedDescription)
        }
    }
}


