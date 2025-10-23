#!/usr/bin/env swift

import Foundation

// Simple test to see if we can load the Rust library
let rustLib = dlopen("/Users/vivek/Development/Treon/rust_backend/target/release/libtreon_rust_backend.dylib", RTLD_LAZY)

if rustLib == nil {
    print("Failed to load Rust library: \(String(cString: dlerror()))")
    exit(1)
}

print("Successfully loaded Rust library")

// Try to get the init function
let initFunc = dlsym(rustLib, "treon_rust_init")
if initFunc == nil {
    print("Failed to find treon_rust_init function: \(String(cString: dlerror()))")
    exit(1)
}

print("Found treon_rust_init function")

// Try to get the process function
let processFunc = dlsym(rustLib, "treon_rust_process_data")
if processFunc == nil {
    print("Failed to find treon_rust_process_data function: \(String(cString: dlerror()))")
    exit(1)
}

print("Found treon_rust_process_data function")

// Try to call init
typealias InitFunc = @convention(c) () -> Void
let initFunction = unsafeBitCast(initFunc, to: InitFunc.self)
initFunction()

print("Successfully called treon_rust_init")

// Try to process some JSON
let jsonData = """
{
    "name": "test",
    "value": 42,
    "active": true
}
""".data(using: .utf8)!

typealias ProcessFunc = @convention(c) (UnsafePointer<UInt8>, Int32) -> UnsafeMutablePointer<CChar>?
let processFunction = unsafeBitCast(processFunc, to: ProcessFunc.self)

let result = jsonData.withUnsafeBytes { bytes in
    processFunction(bytes.bindMemory(to: UInt8.self).baseAddress!, Int32(jsonData.count))
}

if result == nil {
    print("Failed to process JSON data")
    exit(1)
}

let resultString = String(cString: result!)
print("Successfully processed JSON: \(resultString)")

// Free the result
typealias FreeFunc = @convention(c) (UnsafeMutablePointer<CChar>) -> Void
let freeFunc = dlsym(rustLib, "treon_rust_free_string")
if freeFunc != nil {
    let freeFunction = unsafeBitCast(freeFunc, to: FreeFunc.self)
    freeFunction(result!)
}

print("Test completed successfully")
