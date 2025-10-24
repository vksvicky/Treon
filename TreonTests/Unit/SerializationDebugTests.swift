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
                let memoryIncrease = finalMemory - initialMemory
                
                print("  ✅ Processing successful")
                print("  📊 Memory increase: \(String(format: "%.2f", Double(memoryIncrease) / 1024 / 1024)) MB")
                print("  📊 Memory efficiency: \(String(format: "%.2f", Double(memoryIncrease) / Double(size) * 100))% of file size")
                print("  📊 Total nodes: \(result.totalNodes)")
                
            } catch {
                print("  ❌ Processing failed: \(error)")
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
