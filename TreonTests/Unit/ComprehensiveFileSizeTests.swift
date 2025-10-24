import XCTest
import Foundation
@testable import Treon

@MainActor
final class ComprehensiveFileSizeTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Initialize Rust backend for testing
        RustBackend.initialize()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    // MARK: - File Size Test Matrix
    
    private let testSizes: [(Int, String)] = [
        (1 * 1024, "1KB"),           // 1KB
        (1 * 1024 * 1024, "1MB"),    // 1MB
        (5 * 1024 * 1024, "5MB"),    // 5MB
        (10 * 1024 * 1024, "10MB"),  // 10MB
        (25 * 1024 * 1024, "25MB"),  // 25MB
        (50 * 1024 * 1024, "50MB"),  // 50MB
        (100 * 1024 * 1024, "100MB"), // 100MB
        (250 * 1024 * 1024, "250MB"), // 250MB
        (500 * 1024 * 1024, "500MB"), // 500MB
        (1 * 1024 * 1024 * 1024, "1GB") // 1GB
    ]
    
    // MARK: - Rust Backend Integration Tests
    
    func testRustBackendAllFileSizes() async throws {
        print("\n🧪 TESTING RUST BACKEND INTEGRATION ACROSS ALL FILE SIZES")
        print(String(repeating: "=", count: 60))
        
        var results: [(String, Bool, Double, String)] = []
        
        for (size, description) in testSizes {
            print("\n📊 Testing \(description) (\(size) bytes)...")
            
            let testData = createValidJSONData(size: size)
            let startTime = CFAbsoluteTimeGetCurrent()
            
            do {
                let result = try RustBackend.processData(testData, maxDepth: 0)
                let processingTime = CFAbsoluteTimeGetCurrent() - startTime
                
                // Verify basic structure
                XCTAssertEqual(result.root.key, "", "Root key should be empty")
                XCTAssertEqual(result.root.path, "$", "Root path should be $")
                XCTAssertEqual(result.root.value, .object, "Root should be an object")
                XCTAssertGreaterThan(result.root.children.count, 0, "Root should have children")
                XCTAssertGreaterThan(result.totalNodes, 0, "Should have nodes")
                
                results.append((description, true, processingTime, "✅ SUCCESS"))
                print("✅ \(description): SUCCESS - \(String(format: "%.3f", processingTime))s, \(result.totalNodes) nodes")
                
            } catch {
                let processingTime = CFAbsoluteTimeGetCurrent() - startTime
                results.append((description, false, processingTime, "❌ FAILED: \(error)"))
                print("❌ \(description): FAILED - \(String(format: "%.3f", processingTime))s - \(error)")
            }
        }
        
        // Print summary
        print("\n📋 RUST BACKEND INTEGRATION SUMMARY")
        print(String(repeating: "=", count: 60))
        let successCount = results.filter { $0.1 }.count
        let totalCount = results.count
        print("Success Rate: \(successCount)/\(totalCount) (\(String(format: "%.1f", Double(successCount)/Double(totalCount)*100))%)")
        
        for (description, _, time, message) in results {
            print("\(description.padding(toLength: 8, withPad: " ", startingAt: 0)): \(message) (\(String(format: "%.3f", time))s)")
        }
        
        // Identify failure threshold
        let firstFailure = results.firstIndex { !$0.1 }
        if let failureIndex = firstFailure {
            let failureSize = testSizes[failureIndex].1
            print("\n🚨 FIRST FAILURE AT: \(failureSize)")
            print("This indicates the threshold where Rust backend integration breaks")
        }
    }
    
    // MARK: - HybridJSONProcessor Integration Tests
    
    func testHybridJSONProcessorAllFileSizes() async throws {
        print("\n🧪 TESTING HYBRIDJSONPROCESSOR INTEGRATION ACROSS ALL FILE SIZES")
        print(String(repeating: "=", count: 60))
        
        var results: [(String, Bool, Double, String)] = []
        
        for (size, description) in testSizes {
            print("\n📊 Testing \(description) (\(size) bytes)...")
            
            let testData = createValidJSONData(size: size)
            let startTime = CFAbsoluteTimeGetCurrent()
            
            do {
                let result = try await HybridJSONProcessor.processData(testData)
                let processingTime = CFAbsoluteTimeGetCurrent() - startTime
                
                // Verify basic structure
                XCTAssertEqual(result.path, "$", "Root path should be $")
                XCTAssertEqual(result.value, .object, "Root should be an object")
                XCTAssertGreaterThan(result.children.count, 0, "Root should have children")
                
                results.append((description, true, processingTime, "✅ SUCCESS"))
                print("✅ \(description): SUCCESS - \(String(format: "%.3f", processingTime))s, \(result.children.count) children")
                
            } catch {
                let processingTime = CFAbsoluteTimeGetCurrent() - startTime
                results.append((description, false, processingTime, "❌ FAILED: \(error)"))
                print("❌ \(description): FAILED - \(String(format: "%.3f", processingTime))s - \(error)")
            }
        }
        
        // Print summary
        print("\n📋 HYBRIDJSONPROCESSOR INTEGRATION SUMMARY")
        print(String(repeating: "=", count: 60))
        let successCount = results.filter { $0.1 }.count
        let totalCount = results.count
        print("Success Rate: \(successCount)/\(totalCount) (\(String(format: "%.1f", Double(successCount)/Double(totalCount)*100))%)")
        
        for (description, _, time, message) in results {
            print("\(description.padding(toLength: 8, withPad: " ", startingAt: 0)): \(message) (\(String(format: "%.3f", time))s)")
        }
    }
    
    // MARK: - Performance Benchmark Tests
    
    func testPerformanceBenchmarks() async throws {
        print("\n🏃‍♂️ PERFORMANCE BENCHMARKS")
        print(String(repeating: "=", count: 60))
        
        var benchmarks: [(String, Double, Double, Double)] = [] // (size, rust_time, hybrid_time, speedup)
        
        for (size, description) in testSizes {
            print("\n📊 Benchmarking \(description)...")
            
            let testData = createValidJSONData(size: size)
            
            // Test Rust Backend
            let rustStartTime = CFAbsoluteTimeGetCurrent()
            var rustSuccess = false
            do {
                _ = try RustBackend.processData(testData, maxDepth: 0)
                rustSuccess = true
            } catch {
                print("  ⚠️  Rust backend failed for \(description)")
            }
            let rustTime = CFAbsoluteTimeGetCurrent() - rustStartTime
            
            // Test HybridJSONProcessor
            let hybridStartTime = CFAbsoluteTimeGetCurrent()
            var hybridSuccess = false
            do {
                _ = try await HybridJSONProcessor.processData(testData)
                hybridSuccess = true
            } catch {
                print("  ⚠️  HybridJSONProcessor failed for \(description)")
            }
            let hybridTime = CFAbsoluteTimeGetCurrent() - hybridStartTime
            
            if rustSuccess && hybridSuccess {
                let speedup = hybridTime / rustTime
                benchmarks.append((description, rustTime, hybridTime, speedup))
                print("  ✅ Rust: \(String(format: "%.3f", rustTime))s, Hybrid: \(String(format: "%.3f", hybridTime))s, Speedup: \(String(format: "%.2fx", speedup))")
            } else {
                print("  ❌ Cannot compare - one or both failed")
            }
        }
        
        // Print performance summary
        print("\n📊 PERFORMANCE SUMMARY")
        print(String(repeating: "=", count: 60))
        print("Size".padding(toLength: 8, withPad: " ", startingAt: 0) + " | Rust(s) | Hybrid(s) | Speedup")
        print(String(repeating: "-", count: 50))
        
        for (description, rustTime, hybridTime, speedup) in benchmarks {
            let rustStr = String(format: "%.3f", rustTime).padding(toLength: 7, withPad: " ", startingAt: 0)
            let hybridStr = String(format: "%.3f", hybridTime).padding(toLength: 8, withPad: " ", startingAt: 0)
            let speedupStr = String(format: "%.2fx", speedup)
            print("\(description.padding(toLength: 8, withPad: " ", startingAt: 0)) | \(rustStr) | \(hybridStr) | \(speedupStr)")
        }
    }
    
    // MARK: - Threshold Identification Tests
    
    func testIdentifyFailureThreshold() async throws {
        print("\n🔍 IDENTIFYING FAILURE THRESHOLD")
        print(String(repeating: "=", count: 60))
        
        // Test around the suspected threshold (15MB)
        let thresholdSizes: [(Int, String)] = [
            (10 * 1024 * 1024, "10MB"),
            (15 * 1024 * 1024, "15MB"),
            (20 * 1024 * 1024, "20MB"),
            (30 * 1024 * 1024, "30MB"),
            (40 * 1024 * 1024, "40MB"),
            (50 * 1024 * 1024, "50MB"),
            (75 * 1024 * 1024, "75MB"),
            (90 * 1024 * 1024, "90MB"),
            (100 * 1024 * 1024, "100MB")
        ]
        
        var lastSuccessSize = ""
        var firstFailureSize = ""
        
        for (size, description) in thresholdSizes {
            print("\n📊 Testing threshold at \(description)...")
            
            let testData = createValidJSONData(size: size)
            
            do {
                _ = try RustBackend.processData(testData, maxDepth: 0)
                lastSuccessSize = description
                print("✅ \(description): SUCCESS")
            } catch {
                if firstFailureSize.isEmpty {
                    firstFailureSize = description
                }
                print("❌ \(description): FAILED - \(error)")
            }
        }
        
        print("\n🎯 THRESHOLD ANALYSIS")
        print(String(repeating: "=", count: 60))
        print("Last Success: \(lastSuccessSize)")
        print("First Failure: \(firstFailureSize)")
        
        if !lastSuccessSize.isEmpty && !firstFailureSize.isEmpty {
            print("🚨 FAILURE THRESHOLD IDENTIFIED: Between \(lastSuccessSize) and \(firstFailureSize)")
        }
    }
    
    // MARK: - Memory Usage Tests
    
    func testMemoryUsagePatterns() async throws {
        print("\n💾 MEMORY USAGE PATTERNS")
        print(String(repeating: "=", count: 60))
        
        // Test memory usage for different file sizes
        let memoryTestSizes: [(Int, String)] = [
            (1 * 1024 * 1024, "1MB"),
            (10 * 1024 * 1024, "10MB"),
            (50 * 1024 * 1024, "50MB"),
            (100 * 1024 * 1024, "100MB")
        ]
        
        for (size, description) in memoryTestSizes {
            print("\n📊 Testing memory usage for \(description)...")
            
            let testData = createValidJSONData(size: size)
            
            // Get initial memory usage
            let initialMemory = getMemoryUsage()
            
            do {
                _ = try RustBackend.processData(testData, maxDepth: 0)
                let finalMemory = getMemoryUsage()
                let memoryIncrease = finalMemory - initialMemory
                
                print("  📈 Memory increase: \(String(format: "%.2f", Double(memoryIncrease) / 1024 / 1024)) MB")
                print("  📊 Memory efficiency: \(String(format: "%.2f", Double(memoryIncrease) / Double(size) * 100))% of file size")
                
            } catch {
                print("  ❌ Failed to process - cannot measure memory usage")
            }
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
    
    private func getMemoryUsage() -> UInt64 {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
        
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_,
                         task_flavor_t(MACH_TASK_BASIC_INFO),
                         $0,
                         &count)
            }
        }
        
        if kerr == KERN_SUCCESS {
            return info.resident_size
        } else {
            return 0
        }
    }
}
