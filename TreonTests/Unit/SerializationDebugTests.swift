import XCTest
import Foundation
@testable import Treon

@MainActor
final class SerializationDebugTests: XCTestCase {
    
    // MARK: - Serialization Debug Tests
    
    func testDebugSerializationForLargeFiles() async throws {
        print("\n🔍 DEBUGGING SERIALIZATION FOR LARGE FILES")
        print(String(repeating: "=", count: 60))
        
        // Test sizes to find the actual failure threshold
        let testSizes: [(Int, String)] = [
            (10 * 1024 * 1024, "10MB"),   // Should work
            (25 * 1024 * 1024, "25MB"),   // Should work
            (50 * 1024 * 1024, "50MB"),   // Test larger
            (75 * 1024 * 1024, "75MB"),   // Test larger
            (100 * 1024 * 1024, "100MB")  // Test largest
        ]
        
        for (size, description) in testSizes {
            print("\n📊 Testing \(description)...")
            
            let testData = createValidJSONData(size: size)
            let startTime = CFAbsoluteTimeGetCurrent()
            
            do {
                let result = try RustBackend.processData(testData, maxDepth: 0)
                let processingTime = CFAbsoluteTimeGetCurrent() - startTime
                
                print("  ✅ \(description): SUCCESS - \(String(format: "%.3f", processingTime))s")
                print("  📊 Root key: '\(result.root.key)'")
                print("  📊 Root path: '\(result.root.path)'")
                print("  📊 Root value: \(result.root.value)")
                print("  📊 Children count: \(result.root.children.count)")
                print("  📊 Total nodes: \(result.totalNodes)")
                
                // Print first few children for debugging
                if result.root.children.count > 0 {
                    print("  📊 First child: key='\(result.root.children[0].key)', value=\(result.root.children[0].value)")
                    if result.root.children.count > 1 {
                        print("  📊 Second child: key='\(result.root.children[1].key)', value=\(result.root.children[1].value)")
                    }
                }
                
            } catch {
                let processingTime = CFAbsoluteTimeGetCurrent() - startTime
                print("  ❌ \(description): FAILED - \(String(format: "%.3f", processingTime))s")
                print("  🚨 Error: \(error)")
                
                // Try to get more details about the error
                if let decodingError = error as? DecodingError {
                    print("  🔍 Decoding Error Details:")
                    switch decodingError {
                    case .typeMismatch(let type, let context):
                        print("    Type mismatch: expected \(type), context: \(context)")
                    case .valueNotFound(let type, let context):
                        print("    Value not found: \(type), context: \(context)")
                    case .keyNotFound(let key, let context):
                        print("    Key not found: \(key), context: \(context)")
                    case .dataCorrupted(let context):
                        print("    Data corrupted: \(context)")
                    @unknown default:
                        print("    Unknown decoding error")
                    }
                }
            }
        }
    }
    
    func testDebugRawRustOutput() async throws {
        print("\n🔍 DEBUGGING RAW RUST OUTPUT")
        print(String(repeating: "=", count: 60))
        
        // Test with a medium-sized file that should work
        let testData = createValidJSONData(size: 10 * 1024 * 1024) // 10MB
        
        do {
            // Try to get the raw JSON string from Rust
            let result = try RustBackend.processData(testData, maxDepth: 0)
            
            // Try to serialize it back to see what we get
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let encodedData = try encoder.encode(result)
            
            if let jsonString = String(data: encodedData, encoding: .utf8) {
                print("📊 Encoded JSON (first 1000 chars):")
                print(String(jsonString.prefix(1000)))
                print("\n📊 Total JSON length: \(jsonString.count) characters")
            }
            
        } catch {
            print("❌ Failed to process 10MB file: \(error)")
        }
    }
    
    func testDebugRustJSONString() async throws {
        print("\n🔍 DEBUGGING RUST JSON STRING DIRECTLY")
        print(String(repeating: "=", count: 60))
        
        let testSizes: [(Int, String)] = [
            (10 * 1024 * 1024, "10MB"),   // Should work
            (20 * 1024 * 1024, "20MB")    // Should fail
        ]
        
        for (size, description) in testSizes {
            print("\n📊 Testing \(description)...")
            
            let testData = createValidJSONData(size: size)
            
            do {
                // This will call the Rust backend and capture the raw JSON string
                let result = try RustBackend.processData(testData, maxDepth: 0)
                
                // Try to encode the result to see what Swift gets
                let encoder = JSONEncoder()
                let encodedData = try encoder.encode(result)
                
                if let jsonString = String(data: encodedData, encoding: .utf8) {
                    let debugInfo = """
                    DEBUG INFO for \(description):
                      JSON String Length: \(jsonString.count)
                      JSON String Preview: \(String(jsonString.prefix(500)))
                      JSON String Suffix: \(String(jsonString.suffix(500)))
                      Full JSON String: \(jsonString)
                    """
                    print(debugInfo)
                    
                    // Write to file for easier debugging
                    let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                    let debugFile = documentsPath.appendingPathComponent("rust_debug_\(description).txt")
                    try debugInfo.write(to: debugFile, atomically: true, encoding: .utf8)
                    print("Debug info written to: \(debugFile.path)")
                }
                
            } catch {
                print("❌ \(description): FAILED - \(error)")
                
                // Write error to file
                let errorInfo = "Error for \(description): \(error)"
                let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let errorFile = documentsPath.appendingPathComponent("rust_error_\(description).txt")
                try errorInfo.write(to: errorFile, atomically: true, encoding: .utf8)
                print("Error info written to: \(errorFile.path)")
            }
        }
    }
    
    func testDebugSerializationRoundtrip() async throws {
        print("\n🔍 DEBUGGING SERIALIZATION ROUNDTRIP")
        print(String(repeating: "=", count: 60))
        
        let testSizes: [(Int, String)] = [
            (1 * 1024 * 1024, "1MB"),     // Small
            (5 * 1024 * 1024, "5MB"),     // Medium
            (10 * 1024 * 1024, "10MB"),   // Large but should work
            (15 * 1024 * 1024, "15MB")    // Around threshold
        ]
        
        for (size, description) in testSizes {
            print("\n📊 Testing roundtrip for \(description)...")
            
            let testData = createValidJSONData(size: size)
            
            do {
                // Step 1: Process with Rust backend
                let result = try RustBackend.processData(testData, maxDepth: 0)
                print("  ✅ Step 1: Rust processing successful")
                
                // Step 2: Encode to JSON
                let encoder = JSONEncoder()
                let encodedData = try encoder.encode(result)
                print("  ✅ Step 2: Swift encoding successful (\(encodedData.count) bytes)")
                
                // Step 3: Decode back from JSON
                let decoder = JSONDecoder()
                let decodedResult = try decoder.decode(RustJSONTree.self, from: encodedData)
                print("  ✅ Step 3: Swift decoding successful")
                
                // Step 4: Compare
                XCTAssertEqual(result.root.key, decodedResult.root.key, "Root key should match")
                XCTAssertEqual(result.root.path, decodedResult.root.path, "Root path should match")
                XCTAssertEqual(result.totalNodes, decodedResult.totalNodes, "Total nodes should match")
                print("  ✅ Step 4: Roundtrip comparison successful")
                
            } catch {
                print("  ❌ \(description): Roundtrip failed - \(error)")
            }
        }
    }
    
    func testDebugMemoryUsage() async throws {
        print("\n🔍 DEBUGGING MEMORY USAGE")
        print(String(repeating: "=", count: 60))
        
        let testSizes: [(Int, String)] = [
            (5 * 1024 * 1024, "5MB"),
            (10 * 1024 * 1024, "10MB"),
            (15 * 1024 * 1024, "15MB"),
            (20 * 1024 * 1024, "20MB")
        ]
        
        for (size, description) in testSizes {
            print("\n📊 Testing memory usage for \(description)...")
            
            let initialMemory = getMemoryUsage()
            let testData = createValidJSONData(size: size)
            
            do {
                let result = try RustBackend.processData(testData, maxDepth: 0)
                let finalMemory = getMemoryUsage()
                
                // Defensive memory calculation to prevent arithmetic overflow
                let memoryChange = calculateMemoryChange(initial: initialMemory, final: finalMemory)
                
                print("  ✅ Processing successful")
                print("  📊 Initial memory: \(initialMemory)")
                print("  📊 Final memory: \(finalMemory)")
                print("  📊 Memory change: \(String(format: "%.2f", Double(memoryChange) / 1024 / 1024)) MB")
                
                // Safe efficiency calculation
                if let efficiency = calculateMemoryEfficiency(memoryChange: memoryChange, fileSize: size) {
                    print("  📊 Memory efficiency: \(String(format: "%.2f", efficiency))% of file size")
                } else {
                    print("  📊 Memory efficiency: N/A (memory freed)")
                }
                print("  📊 Total nodes: \(result.totalNodes)")
                
            } catch {
                print("  ❌ Processing failed: \(error)")
            }
        }
    }
    
    // MARK: - Edge Case Tests
    
    func testMemoryCalculationEdgeCases() {
        print("\n🧪 TESTING MEMORY CALCULATION EDGE CASES")
        print(String(repeating: "=", count: 60))
        
        // Test case 1: Normal memory increase
        let normalIncrease = calculateMemoryChange(initial: 1000, final: 1500)
        XCTAssertEqual(normalIncrease, 500, "Normal memory increase should work")
        
        // Test case 2: Memory decrease (unsigned underflow scenario)
        let memoryDecrease = calculateMemoryChange(initial: 1500, final: 1000)
        XCTAssertEqual(memoryDecrease, -500, "Memory decrease should be negative")
        
        // Test case 3: No memory change
        let noChange = calculateMemoryChange(initial: 1000, final: 1000)
        XCTAssertEqual(noChange, 0, "No memory change should be zero")
        
        // Test case 4: Large memory increase
        let largeIncrease = calculateMemoryChange(initial: 1000, final: 2000)
        XCTAssertEqual(largeIncrease, 1000, "Large memory increase should work")
        
        // Test case 5: Large memory decrease (potential underflow)
        let largeDecrease = calculateMemoryChange(initial: 2000, final: 1000)
        XCTAssertEqual(largeDecrease, -1000, "Large memory decrease should be negative")
        
        print("✅ All memory calculation edge cases passed")
    }
    
    func testMemoryEfficiencyEdgeCases() {
        print("\n🧪 TESTING MEMORY EFFICIENCY EDGE CASES")
        print(String(repeating: "=", count: 60))
        
        // Test case 1: Normal efficiency calculation
        let normalEfficiency = calculateMemoryEfficiency(memoryChange: 1000, fileSize: 10000)
        XCTAssertNotNil(normalEfficiency, "Normal efficiency should not be nil")
        XCTAssertEqual(normalEfficiency!, 10.0, accuracy: 0.01, "Normal efficiency should be 10%")
        
        // Test case 2: Memory decrease (should return nil)
        let decreaseEfficiency = calculateMemoryEfficiency(memoryChange: -1000, fileSize: 10000)
        XCTAssertNil(decreaseEfficiency, "Memory decrease should return nil")
        
        // Test case 3: Zero memory change (should return nil)
        let zeroEfficiency = calculateMemoryEfficiency(memoryChange: 0, fileSize: 10000)
        XCTAssertNil(zeroEfficiency, "Zero memory change should return nil")
        
        // Test case 4: Zero file size (should return nil)
        let zeroFileEfficiency = calculateMemoryEfficiency(memoryChange: 1000, fileSize: 0)
        XCTAssertNil(zeroFileEfficiency, "Zero file size should return nil")
        
        // Test case 5: Very large memory change (should return nil to prevent overflow)
        let hugeMemoryChange = Int64.max / 50 // This will cause overflow in calculation
        let hugeEfficiency = calculateMemoryEfficiency(memoryChange: hugeMemoryChange, fileSize: 10000)
        XCTAssertNil(hugeEfficiency, "Very large memory change should return nil")
        
        // Test case 6: Edge case - exactly at the safe limit
        let safeLimit = Int64.max / 100
        let safeEfficiency = calculateMemoryEfficiency(memoryChange: safeLimit, fileSize: 10000)
        XCTAssertNotNil(safeEfficiency, "Safe limit should work")
        
        print("✅ All memory efficiency edge cases passed")
    }
    
    func testArithmeticOverflowPrevention() {
        print("\n🧪 TESTING ARITHMETIC OVERFLOW PREVENTION")
        print(String(repeating: "=", count: 60))
        
        // Test the original problematic scenario that caused overflow
        let initialMemory: UInt64 = 1000
        let finalMemory: UInt64 = 500  // This would cause underflow in original code
        
        // This should not crash or overflow
        let memoryChange = calculateMemoryChange(initial: initialMemory, final: finalMemory)
        XCTAssertEqual(memoryChange, -500, "Should handle underflow correctly")
        
        // Test efficiency calculation with the problematic values
        let efficiency = calculateMemoryEfficiency(memoryChange: memoryChange, fileSize: 1000)
        XCTAssertNil(efficiency, "Negative memory change should return nil for efficiency")
        
        // Test with large but safe values
        let largeInitial: UInt64 = 1000000
        let largeFinal: UInt64 = 2000000
        let largeChange = calculateMemoryChange(initial: largeInitial, final: largeFinal)
        XCTAssertEqual(largeChange, 1000000, "Should handle large values safely")
        
        print("✅ Arithmetic overflow prevention tests passed")
    }
    
    // MARK: - Helper Functions
    
    /// Safely calculates memory change, handling unsigned integer underflow
    private func calculateMemoryChange(initial: UInt64, final: UInt64) -> Int64 {
        if final >= initial {
            // Memory increased or stayed the same
            return Int64(final - initial)
        } else {
            // Memory decreased - handle unsigned underflow
            return -Int64(initial - final)
        }
    }
    
    /// Safely calculates memory efficiency percentage, handling edge cases
    private func calculateMemoryEfficiency(memoryChange: Int64, fileSize: Int) -> Double? {
        // Only calculate efficiency for memory increases
        guard memoryChange > 0 else { return nil }
        
        // Prevent division by zero
        guard fileSize > 0 else { return nil }
        
        // Check for potential overflow before calculation
        let maxSafeMemoryChange = Int64.max / 100
        guard memoryChange <= maxSafeMemoryChange else {
            print("  ⚠️ Memory change too large for safe efficiency calculation")
            return nil
        }
        
        return Double(memoryChange) / Double(fileSize) * 100
    }
    
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
