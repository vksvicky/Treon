import XCTest
import Foundation
@testable import Treon

@MainActor
final class RustBackendPerformanceTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Initialize Rust backend for testing
        RustBackend.initialize()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    // MARK: - Performance Test Sizes
    
    private let performanceSizes: [(Int, String)] = [
        (1 * 1024, "1KB"),
        (10 * 1024, "10KB"),
        (100 * 1024, "100KB"),
        (1 * 1024 * 1024, "1MB"),
        (5 * 1024 * 1024, "5MB"),
        (10 * 1024 * 1024, "10MB"),
        (25 * 1024 * 1024, "25MB"),
        (50 * 1024 * 1024, "50MB"),
        (100 * 1024 * 1024, "100MB"),
        (250 * 1024 * 1024, "250MB"),
        (500 * 1024 * 1024, "500MB"),
        (1 * 1024 * 1024 * 1024, "1GB")
    ]
    
    // MARK: - Rust Backend Performance Tests
    
    func testRustBackendProcessingSpeed() async throws {
        print("\n🏃‍♂️ RUST BACKEND PROCESSING SPEED BENCHMARKS")
        print(String(repeating: "=", count: 60))
        
        var results: [(String, Double, Int, Double)] = [] // (size, time, nodes, mbps)
        
        for (size, description) in performanceSizes {
            print("\n📊 Benchmarking \(description)...")
            
            let testData = createPerformanceTestData(size: size)
            let startTime = CFAbsoluteTimeGetCurrent()
            
            do {
                let result = try RustBackend.processData(testData, maxDepth: 0)
                let processingTime = CFAbsoluteTimeGetCurrent() - startTime
                
                let mbps = Double(size) / (1024 * 1024) / processingTime
                results.append((description, processingTime, result.totalNodes, mbps))
                
                print("  ✅ \(description): \(String(format: "%.3f", processingTime))s, \(result.totalNodes) nodes, \(String(format: "%.2f", mbps)) MB/s")
                
            } catch {
                print("  ❌ \(description): FAILED - \(error)")
            }
        }
        
        // Print performance summary
        print("\n📊 RUST BACKEND PERFORMANCE SUMMARY")
        print(String(repeating: "=", count: 60))
        print("Size".padding(toLength: 8, withPad: " ", startingAt: 0) + " | Time(s) | Nodes   | MB/s")
        print(String(repeating: "-", count: 50))
        
        for (description, time, nodes, mbps) in results {
            let timeStr = String(format: "%.3f", time).padding(toLength: 7, withPad: " ", startingAt: 0)
            let nodesStr = "\(nodes)".padding(toLength: 7, withPad: " ", startingAt: 0)
            let mbpsStr = String(format: "%.2f", mbps)
            print("\(description.padding(toLength: 8, withPad: " ", startingAt: 0)) | \(timeStr) | \(nodesStr) | \(mbpsStr)")
        }
        
        // Performance analysis
        if results.count >= 2 {
            let firstResult = results[0]
            let lastResult = results[results.count - 1]
            let timeRatio = lastResult.1 / firstResult.1
            let sizeRatio = Double(performanceSizes[results.count - 1].0) / Double(performanceSizes[0].0)
            
            print("\n📈 PERFORMANCE ANALYSIS")
            print(String(repeating: "=", count: 60))
            print("Size increase: \(String(format: "%.1fx", sizeRatio))")
            print("Time increase: \(String(format: "%.1fx", timeRatio))")
            print("Efficiency: \(String(format: "%.1fx", sizeRatio / timeRatio))")
        }
    }
    
    func testRustBackendMemoryEfficiency() async throws {
        print("\n💾 RUST BACKEND MEMORY EFFICIENCY TESTS")
        print(String(repeating: "=", count: 60))
        
        let memoryTestSizes: [(Int, String)] = [
            (1 * 1024 * 1024, "1MB"),
            (10 * 1024 * 1024, "10MB"),
            (50 * 1024 * 1024, "50MB"),
            (100 * 1024 * 1024, "100MB")
        ]
        
        for (size, description) in memoryTestSizes {
            print("\n📊 Testing memory efficiency for \(description)...")
            
            let testData = createPerformanceTestData(size: size)
            let initialMemory = getMemoryUsage()
            
            do {
                let result = try RustBackend.processData(testData, maxDepth: 0)
                let finalMemory = getMemoryUsage()
                let memoryIncrease = finalMemory - initialMemory
                
                let memoryEfficiency = Double(memoryIncrease) / Double(size) * 100
                let nodesPerMB = Double(result.totalNodes) / (Double(size) / (1024 * 1024))
                
                print("  📈 Memory increase: \(String(format: "%.2f", Double(memoryIncrease) / 1024 / 1024)) MB")
                print("  📊 Memory efficiency: \(String(format: "%.2f", memoryEfficiency))% of file size")
                print("  🎯 Nodes per MB: \(String(format: "%.0f", nodesPerMB))")
                
            } catch {
                print("  ❌ Failed to process - cannot measure memory usage")
            }
        }
    }
    
    func testRustBackendDepthLimitingPerformance() async throws {
        print("\n🎯 RUST BACKEND DEPTH LIMITING PERFORMANCE")
        print(String(repeating: "=", count: 60))
        
        let testSize = 50 * 1024 * 1024 // 50MB
        let testData = createDeepNestedJSONData(size: testSize)
        
        let depthLimits = [0, 3, 5, 10, 20]
        
        for maxDepth in depthLimits {
            print("\n📊 Testing with maxDepth: \(maxDepth)...")
            
            let startTime = CFAbsoluteTimeGetCurrent()
            
            do {
                let result = try RustBackend.processData(testData, maxDepth: Int32(maxDepth))
                let processingTime = CFAbsoluteTimeGetCurrent() - startTime
                
                print("  ✅ MaxDepth \(maxDepth): \(String(format: "%.3f", processingTime))s, \(result.totalNodes) nodes")
                
            } catch {
                print("  ❌ MaxDepth \(maxDepth): FAILED - \(error)")
            }
        }
    }
    
    func testRustBackendConsistencyAcrossRuns() async throws {
        print("\n🔄 RUST BACKEND CONSISTENCY ACROSS RUNS")
        print(String(repeating: "=", count: 60))
        
        let testSize = 10 * 1024 * 1024 // 10MB
        let testData = createPerformanceTestData(size: testSize)
        let numberOfRuns = 5
        
        var times: [Double] = []
        var nodeCounts: [Int] = []
        
        for run in 1...numberOfRuns {
            print("\n📊 Run \(run)/\(numberOfRuns)...")
            
            let startTime = CFAbsoluteTimeGetCurrent()
            
            do {
                let result = try RustBackend.processData(testData, maxDepth: 0)
                let processingTime = CFAbsoluteTimeGetCurrent() - startTime
                
                times.append(processingTime)
                nodeCounts.append(result.totalNodes)
                
                print("  ✅ Run \(run): \(String(format: "%.3f", processingTime))s, \(result.totalNodes) nodes")
                
            } catch {
                print("  ❌ Run \(run): FAILED - \(error)")
            }
        }
        
        if times.count == numberOfRuns {
            let avgTime = times.reduce(0, +) / Double(times.count)
            let minTime = times.min()!
            let maxTime = times.max()!
            let stdDev = sqrt(times.map { pow($0 - avgTime, 2) }.reduce(0, +) / Double(times.count))
            let cv = (stdDev / avgTime) * 100
            
            let avgNodes = nodeCounts.reduce(0, +) / nodeCounts.count
            let allNodesEqual = nodeCounts.allSatisfy { $0 == nodeCounts[0] }
            
            print("\n📊 CONSISTENCY ANALYSIS")
            print(String(repeating: "=", count: 60))
            print("Average time: \(String(format: "%.3f", avgTime))s")
            print("Time range: \(String(format: "%.3f", minTime))s - \(String(format: "%.3f", maxTime))s")
            print("Standard deviation: \(String(format: "%.3f", stdDev))s")
            print("Coefficient of variation: \(String(format: "%.1f", cv))%")
            print("Average nodes: \(avgNodes)")
            print("Node consistency: \(allNodesEqual ? "✅ CONSISTENT" : "❌ INCONSISTENT")")
            
            // Consistency threshold: CV should be < 20%
            if cv < 20.0 {
                print("✅ PERFORMANCE IS CONSISTENT (CV < 20%)")
            } else {
                print("⚠️  PERFORMANCE IS INCONSISTENT (CV ≥ 20%)")
            }
        }
    }
    
    func testRustBackendLargeFileThreshold() async throws {
        print("\n🚨 RUST BACKEND LARGE FILE THRESHOLD TEST")
        print(String(repeating: "=", count: 60))
        
        // Test around the suspected threshold
        let thresholdSizes: [(Int, String)] = [
            (10 * 1024 * 1024, "10MB"),
            (15 * 1024 * 1024, "15MB"),
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
            
            let testData = createPerformanceTestData(size: size)
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
    }
    
    // MARK: - Helper Functions
    
    private func createPerformanceTestData(size: Int) -> Data {
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
    
    private func createDeepNestedJSONData(size: Int) -> Data {
        var json = "{\n"
        var current = 2
        var depth = 0
        let maxDepth = 20
        
        while current < size && depth < maxDepth {
            let key = "level_\(depth)"
            json += "  \"\(key)\": {\n"
            current += key.count + 8
            depth += 1
            
            if depth < maxDepth && current < size - 100 {
                json += "    \"data\": \"\(String(repeating: "x", count: min(1000, size - current - 50)))\",\n"
                current += 1000
            }
        }
        
        // Close all the nested objects
        for _ in 0..<depth {
            json += "  }"
            if depth > 1 {
                json += ","
            }
            json += "\n"
        }
        
        json += "}"
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
