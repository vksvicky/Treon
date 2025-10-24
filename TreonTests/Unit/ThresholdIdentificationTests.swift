import XCTest
import Foundation
@testable import Treon

@MainActor
final class RustBackendValidationTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Initialize Rust backend for testing
        RustBackend.initialize()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    // MARK: - Rust Backend Validation Tests
    
    func testRustBackendHandlesAllFileSizes() async throws {
        print("\n🔍 VALIDATING RUST BACKEND FOR ALL FILE SIZES")
        print(String(repeating: "=", count: 60))
        
        // Test around the suspected threshold (15MB)
        let thresholdSizes: [(Int, String)] = [
            (10 * 1024 * 1024, "10MB"),
            (12 * 1024 * 1024, "12MB"),
            (14 * 1024 * 1024, "14MB"),
            (15 * 1024 * 1024, "15MB"),
            (16 * 1024 * 1024, "16MB"),
            (18 * 1024 * 1024, "18MB"),
            (20 * 1024 * 1024, "20MB"),
            (25 * 1024 * 1024, "25MB"),
            (30 * 1024 * 1024, "30MB"),
            (40 * 1024 * 1024, "40MB"),
            (50 * 1024 * 1024, "50MB"),
            (75 * 1024 * 1024, "75MB"),
            (90 * 1024 * 1024, "90MB"),
            (100 * 1024 * 1024, "100MB")
        ]
        
        var lastSuccessSize = ""
        var firstFailureSize = ""
        var successTimes: [Double] = []
        var failureSizes: [String] = []
        
        for (size, description) in thresholdSizes {
            print("\n📊 Testing threshold at \(description)...")
            
            let testData = createValidJSONData(size: size)
            let startTime = CFAbsoluteTimeGetCurrent()
            
            do {
                let result = try RustBackend.processData(testData, maxDepth: 0)
                let processingTime = CFAbsoluteTimeGetCurrent() - startTime
                
                lastSuccessSize = description
                successTimes.append(processingTime)
                print("  ✅ \(description): SUCCESS - \(String(format: "%.3f", processingTime))s, \(result.totalNodes) nodes")
                
            } catch {
                if firstFailureSize.isEmpty {
                    firstFailureSize = description
                }
                failureSizes.append(description)
                print("  ❌ \(description): FAILED - \(error)")
            }
        }
        
        print("\n🎯 THRESHOLD ANALYSIS")
        print(String(repeating: "=", count: 60))
        print("Last Success: \(lastSuccessSize)")
        print("First Failure: \(firstFailureSize)")
        print("Failed Sizes: \(failureSizes.joined(separator: ", "))")
        
        if !successTimes.isEmpty {
            let avgSuccessTime = successTimes.reduce(0, +) / Double(successTimes.count)
            print("Average success time: \(String(format: "%.3f", avgSuccessTime))s")
        }
        
        if !lastSuccessSize.isEmpty && !firstFailureSize.isEmpty {
            print("🚨 FAILURE THRESHOLD IDENTIFIED: Between \(lastSuccessSize) and \(firstFailureSize)")
        }
        
        // Assert that all tests should succeed - Rust backend should handle all tested sizes
        XCTAssertFalse(lastSuccessSize.isEmpty, "Should have at least one successful test")
        XCTAssertTrue(firstFailureSize.isEmpty, "Rust backend should handle all file sizes up to 100MB without failures")
        
        if firstFailureSize.isEmpty {
            print("🎉 EXCELLENT: Rust backend working for all tested sizes up to 100MB!")
            print("✅ All file sizes from 10MB to 100MB are processing successfully")
        } else {
            print("🚨 UNEXPECTED FAILURE: Rust backend failed at \(firstFailureSize)")
            print("This indicates a regression in the Rust backend that needs to be fixed")
        }
    }
    
    // MARK: - Binary Search Validation
    
    func testRustBackendBinarySearchValidation() async throws {
        print("\n🔍 BINARY SEARCH VALIDATION OF RUST BACKEND")
        print(String(repeating: "=", count: 60))
        
        // Binary search between 10MB and 100MB
        var low = 10 * 1024 * 1024  // 10MB
        var high = 100 * 1024 * 1024 // 100MB
        var lastSuccess = 0
        var firstFailure = 0
        
        while low <= high {
            let mid = (low + high) / 2
            let midMB = mid / (1024 * 1024)
            
            print("\n📊 Testing \(midMB)MB...")
            
            let testData = createValidJSONData(size: mid)
            let startTime = CFAbsoluteTimeGetCurrent()
            
            do {
                let result = try RustBackend.processData(testData, maxDepth: 0)
                let processingTime = CFAbsoluteTimeGetCurrent() - startTime
                
                lastSuccess = mid
                low = mid + 1
                print("  ✅ \(midMB)MB: SUCCESS - \(String(format: "%.3f", processingTime))s, \(result.totalNodes) nodes")
                
            } catch {
                firstFailure = mid
                high = mid - 1
                print("  ❌ \(midMB)MB: FAILED - \(error)")
            }
        }
        
        print("\n🎯 BINARY SEARCH RESULTS")
        print(String(repeating: "=", count: 60))
        print("Last Success: \(lastSuccess / (1024 * 1024))MB")
        print("First Failure: \(firstFailure / (1024 * 1024))MB")
        
        if lastSuccess > 0 && firstFailure > 0 {
            let threshold = (lastSuccess + firstFailure) / 2
            print("Estimated Threshold: \(threshold / (1024 * 1024))MB")
        }
        
        // Assert that all tests should succeed - Rust backend should handle all tested sizes
        XCTAssertTrue(lastSuccess > 0, "Should have found at least one successful test")
        XCTAssertEqual(firstFailure, 0, "Rust backend should handle all file sizes up to 100MB without failures")
        
        if firstFailure > 0 {
            let threshold = (lastSuccess + firstFailure) / 2
            print("🚨 UNEXPECTED FAILURE: Rust backend failed at \(firstFailure / (1024 * 1024))MB")
            print("Estimated Threshold: \(threshold / (1024 * 1024))MB")
            print("This indicates a regression in the Rust backend that needs to be fixed")
        } else {
            print("🎉 EXCELLENT: Binary search found no failures - Rust backend working for all tested sizes!")
            print("✅ All file sizes from 10MB to 100MB are processing successfully")
        }
    }
    
    // MARK: - Performance Analysis at Threshold
    
    func testPerformanceAnalysisAtThreshold() async throws {
        print("\n📊 PERFORMANCE ANALYSIS AT THRESHOLD")
        print(String(repeating: "=", count: 60))
        
        // Test sizes around the suspected threshold
        let testSizes: [(Int, String)] = [
            (10 * 1024 * 1024, "10MB"),
            (15 * 1024 * 1024, "15MB"),
            (20 * 1024 * 1024, "20MB"),
            (25 * 1024 * 1024, "25MB"),
            (30 * 1024 * 1024, "30MB")
        ]
        
        var results: [(String, Bool, Double, String)] = []
        
        for (size, description) in testSizes {
            print("\n📊 Testing \(description)...")
            
            let testData = createValidJSONData(size: size)
            let startTime = CFAbsoluteTimeGetCurrent()
            
            do {
                let result = try RustBackend.processData(testData, maxDepth: 0)
                let processingTime = CFAbsoluteTimeGetCurrent() - startTime
                
                results.append((description, true, processingTime, "✅ SUCCESS"))
                print("  ✅ \(description): SUCCESS - \(String(format: "%.3f", processingTime))s, \(result.totalNodes) nodes")
                
            } catch {
                let processingTime = CFAbsoluteTimeGetCurrent() - startTime
                results.append((description, false, processingTime, "❌ FAILED: \(error)"))
                print("  ❌ \(description): FAILED - \(String(format: "%.3f", processingTime))s - \(error)")
            }
        }
        
        // Print performance summary
        print("\n📊 PERFORMANCE SUMMARY")
        print(String(repeating: "=", count: 60))
        print("Size".padding(toLength: 8, withPad: " ", startingAt: 0) + " | Status    | Time(s)")
        print(String(repeating: "-", count: 30))
        
        for (description, success, time, message) in results {
            let status = success ? "SUCCESS" : "FAILED"
            let timeStr = String(format: "%.3f", time).padding(toLength: 7, withPad: " ", startingAt: 0)
            print("\(description.padding(toLength: 8, withPad: " ", startingAt: 0)) | \(status.padding(toLength: 8, withPad: " ", startingAt: 0)) | \(timeStr)")
        }
    }
    
    // MARK: - Helper Functions
    
    private func createValidJSONData(size: Int) -> Data {
        var json = "{\n"
        var current = 2
        var index = 0
        var isFirstEntry = true
        
        while current < size {
            let key = "key_\(index)"
            let remaining = max(0, size - current - 100)
            let value = String(repeating: "x", count: min(1024, remaining))
            
            if !isFirstEntry {
                json += ",\n"
                current += 2
            }
            
            json += "  \"\(key)\": \"\(value)\""
            current += key.count + value.count + 8
            
            isFirstEntry = false
            index += 1
        }
        
        json += "\n}"
        return json.data(using: .utf8)!
    }
}
