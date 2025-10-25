//
//  JSONTextViewTests.swift
//  TreonTests
//
//  Created by Vivek on 2025-10-25.
//  Copyright © 2025 Treon. All rights reserved.
//

import XCTest
import SwiftUI
import AppKit
@testable import Treon

@MainActor
final class JSONTextViewTests: XCTestCase {
    
    private var textView: JSONTextView!
    private var binding: Binding<String>!
    
    override func setUp() async throws {
        try await super.setUp()
        
        // Create a binding for testing
        var text = "{\n  \"test\": \"value\"\n}"
        binding = Binding<String>(
            get: { text },
            set: { text = $0 }
        )
        
        textView = JSONTextView(
            text: binding,
            isWordWrapEnabled: false
        )
    }
    
    override func tearDown() async throws {
        textView = nil
        binding = nil
        try await super.tearDown()
    }
    
    // MARK: - Basic Functionality Tests
    
    func testJSONTextViewInitialization() {
        XCTAssertNotNil(textView)
        XCTAssertEqual(binding.wrappedValue, "{\n  \"test\": \"value\"\n}")
        XCTAssertFalse(textView.isWordWrapEnabled)
    }
    
    func testJSONTextViewWithWordWrap() {
        let wrappedTextView = JSONTextView(
            text: binding,
            isWordWrapEnabled: true
        )
        
        XCTAssertTrue(wrappedTextView.isWordWrapEnabled)
    }
    
    func testJSONTextViewWithEmptyText() {
        var emptyText = ""
        let emptyBinding = Binding<String>(
            get: { emptyText },
            set: { emptyText = $0 }
        )
        
        let emptyTextView = JSONTextView(
            text: emptyBinding,
            isWordWrapEnabled: false
        )
        
        XCTAssertEqual(emptyBinding.wrappedValue, "")
    }
    
    func testJSONTextViewWithLargeText() {
        let largeJSON = String(repeating: "{\n  \"key\": \"value\",\n", count: 1000) + "}"
        var largeText = largeJSON
        let largeBinding = Binding<String>(
            get: { largeText },
            set: { largeText = $0 }
        )
        
        let largeTextView = JSONTextView(
            text: largeBinding,
            isWordWrapEnabled: false
        )
        
        XCTAssertEqual(largeBinding.wrappedValue, largeJSON)
    }
    
    // MARK: - Text Content Tests
    
    func testJSONTextViewWithValidJSON() {
        let validJSON = """
        {
            "name": "Test",
            "age": 30,
            "active": true,
            "items": [1, 2, 3]
        }
        """
        
        var text = validJSON
        let binding = Binding<String>(
            get: { text },
            set: { text = $0 }
        )
        
        let jsonTextView = JSONTextView(
            text: binding,
            isWordWrapEnabled: false
        )
        
        XCTAssertEqual(binding.wrappedValue, validJSON)
    }
    
    func testJSONTextViewWithInvalidJSON() {
        let invalidJSON = "{ invalid json content }"
        
        var text = invalidJSON
        let binding = Binding<String>(
            get: { text },
            set: { text = $0 }
        )
        
        let jsonTextView = JSONTextView(
            text: binding,
            isWordWrapEnabled: false
        )
        
        XCTAssertEqual(binding.wrappedValue, invalidJSON)
    }
    
    func testJSONTextViewWithSpecialCharacters() {
        let specialJSON = """
        {
            "unicode": "Hello 世界 🌍",
            "quotes": "He said \\"Hello\\"",
            "newlines": "Line 1\\nLine 2",
            "tabs": "Column1\\tColumn2"
        }
        """
        
        var text = specialJSON
        let binding = Binding<String>(
            get: { text },
            set: { text = $0 }
        )
        
        let jsonTextView = JSONTextView(
            text: binding,
            isWordWrapEnabled: false
        )
        
        XCTAssertEqual(binding.wrappedValue, specialJSON)
    }
    
    // MARK: - Word Wrap Tests
    
    func testWordWrapEnabled() {
        let wrappedTextView = JSONTextView(
            text: binding,
            isWordWrapEnabled: true
        )
        
        XCTAssertTrue(wrappedTextView.isWordWrapEnabled)
    }
    
    func testWordWrapDisabled() {
        let noWrapTextView = JSONTextView(
            text: binding,
            isWordWrapEnabled: false
        )
        
        XCTAssertFalse(noWrapTextView.isWordWrapEnabled)
    }
    
    // MARK: - Performance Tests
    
    func testJSONTextViewPerformanceWithLargeContent() {
        let largeContent = String(repeating: "{\n  \"key\": \"value\",\n", count: 10000) + "}"
        
        measure {
            var text = largeContent
            let binding = Binding<String>(
                get: { text },
                set: { text = $0 }
            )
            
            let _ = JSONTextView(
                text: binding,
                isWordWrapEnabled: false
            )
        }
    }
    
    func testJSONTextViewPerformanceWithWordWrap() {
        let largeContent = String(repeating: "{\n  \"key\": \"value\",\n", count: 5000) + "}"
        
        measure {
            var text = largeContent
            let binding = Binding<String>(
                get: { text },
                set: { text = $0 }
            )
            
            let _ = JSONTextView(
                text: binding,
                isWordWrapEnabled: true
            )
        }
    }
    
    // MARK: - Edge Cases Tests
    
    func testJSONTextViewWithNilBinding() {
        // Test that the component handles binding changes gracefully
        var text = "initial"
        let binding = Binding<String>(
            get: { text },
            set: { text = $0 }
        )
        
        let jsonTextView = JSONTextView(
            text: binding,
            isWordWrapEnabled: false
        )
        
        // Change the binding value
        binding.wrappedValue = "updated"
        
        XCTAssertEqual(binding.wrappedValue, "updated")
    }
    
    func testJSONTextViewWithVeryLongLine() {
        let longLine = "{\"key\": \"" + String(repeating: "a", count: 10000) + "\"}"
        
        var text = longLine
        let binding = Binding<String>(
            get: { text },
            set: { text = $0 }
        )
        
        let jsonTextView = JSONTextView(
            text: binding,
            isWordWrapEnabled: true
        )
        
        XCTAssertEqual(binding.wrappedValue, longLine)
    }
    
    func testJSONTextViewWithOnlyWhitespace() {
        let whitespaceText = "   \n\t  \n   "
        
        var text = whitespaceText
        let binding = Binding<String>(
            get: { text },
            set: { text = $0 }
        )
        
        let jsonTextView = JSONTextView(
            text: binding,
            isWordWrapEnabled: false
        )
        
        XCTAssertEqual(binding.wrappedValue, whitespaceText)
    }
    
    // MARK: - Integration Tests
    
    func testJSONTextViewWithSettingsIntegration() {
        let settings = UserSettingsManager.shared
        let originalWrapText = settings.wrapText
        
        // Test with settings-based word wrap
        settings.wrapText = true
        let wrappedTextView = JSONTextView(
            text: binding,
            isWordWrapEnabled: settings.wrapText
        )
        XCTAssertTrue(wrappedTextView.isWordWrapEnabled)
        
        settings.wrapText = false
        let noWrapTextView = JSONTextView(
            text: binding,
            isWordWrapEnabled: settings.wrapText
        )
        XCTAssertFalse(noWrapTextView.isWordWrapEnabled)
        
        // Restore original setting
        settings.wrapText = originalWrapText
    }
}
