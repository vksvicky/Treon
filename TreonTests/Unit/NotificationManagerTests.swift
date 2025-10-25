//
//  NotificationManagerTests.swift
//  TreonTests
//
//  Created by Vivek on 2025-10-25.
//  Copyright © 2025 Treon. All rights reserved.
//

import XCTest
import AppKit
@testable import Treon

@MainActor
final class NotificationManagerTests: XCTestCase, @unchecked Sendable {
    
    private var notificationManager: NotificationManager!
    
    override func setUp() async throws {
        try await super.setUp()
        notificationManager = NotificationManager.shared
        // Clear any existing notifications
        notificationManager.dismissNotification()
    }
    
    override func tearDown() async throws {
        notificationManager.dismissNotification()
        notificationManager = nil
        try await super.tearDown()
    }
    
    // MARK: - Basic Notification Tests
    
    func testNotificationManagerInitialization() {
        XCTAssertNotNil(notificationManager)
        XCTAssertFalse(notificationManager.isShowingNotification)
        XCTAssertNil(notificationManager.currentNotification)
    }
    
    func testShowSuccessNotification() {
        let message = "Test success message"
        let notification = AppNotification(
            type: .success,
            title: "Success",
            message: message
        )
        
        notificationManager.showNotification(notification)
        
        XCTAssertTrue(notificationManager.isShowingNotification)
        XCTAssertNotNil(notificationManager.currentNotification)
        XCTAssertEqual(notificationManager.currentNotification?.title, "Success")
        XCTAssertEqual(notificationManager.currentNotification?.message, message)
        XCTAssertEqual(notificationManager.currentNotification?.type, .success)
    }
    
    func testShowErrorNotification() {
        let message = "Test error message"
        let notification = AppNotification(
            type: .error,
            title: "Error",
            message: message
        )
        
        notificationManager.showNotification(notification)
        
        XCTAssertTrue(notificationManager.isShowingNotification)
        XCTAssertNotNil(notificationManager.currentNotification)
        XCTAssertEqual(notificationManager.currentNotification?.title, "Error")
        XCTAssertEqual(notificationManager.currentNotification?.message, message)
        XCTAssertEqual(notificationManager.currentNotification?.type, .error)
    }
    
    func testShowPermissionNotification() {
        let message = "Test permission message"
        let notification = AppNotification(
            type: .permission,
            title: "Permission",
            message: message
        )
        
        notificationManager.showNotification(notification)
        
        XCTAssertTrue(notificationManager.isShowingNotification)
        XCTAssertNotNil(notificationManager.currentNotification)
        XCTAssertEqual(notificationManager.currentNotification?.title, "Permission")
        XCTAssertEqual(notificationManager.currentNotification?.message, message)
        XCTAssertEqual(notificationManager.currentNotification?.type, .permission)
    }
    
    func testShowInfoNotification() {
        let message = "Test info message"
        let notification = AppNotification(
            type: .info,
            title: "Info",
            message: message
        )
        
        notificationManager.showNotification(notification)
        
        XCTAssertTrue(notificationManager.isShowingNotification)
        XCTAssertNotNil(notificationManager.currentNotification)
        XCTAssertEqual(notificationManager.currentNotification?.title, "Info")
        XCTAssertEqual(notificationManager.currentNotification?.message, message)
        XCTAssertEqual(notificationManager.currentNotification?.type, .info)
    }
    
    // MARK: - Notification Dismissal Tests
    
    func testDismissNotification() {
        // Show a notification first
        let notification = AppNotification(
            type: .info,
            title: "Test",
            message: "Test message"
        )
        notificationManager.showNotification(notification)
        
        XCTAssertTrue(notificationManager.isShowingNotification)
        
        // Dismiss the notification
        notificationManager.dismissNotification()
        
        XCTAssertFalse(notificationManager.isShowingNotification)
        
        // Wait for the async cleanup (NotificationManager clears currentNotification after 0.3 seconds)
        let expectation = XCTestExpectation(description: "Notification dismissed")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
        XCTAssertNil(notificationManager.currentNotification)
    }
    
    func testDismissNotificationWhenNoneShowing() {
        // Try to dismiss when no notification is showing
        notificationManager.dismissNotification()
        
        XCTAssertFalse(notificationManager.isShowingNotification)
        XCTAssertNil(notificationManager.currentNotification)
    }
    
    // MARK: - Notification Replacement Tests
    
    func testReplaceNotification() {
        // Show first notification
        let firstNotification = AppNotification(
            type: .info,
            title: "First",
            message: "First message"
        )
        notificationManager.showNotification(firstNotification)
        
        XCTAssertEqual(notificationManager.currentNotification?.title, "First")
        
        // Show second notification (should replace first)
        let secondNotification = AppNotification(
            type: .error,
            title: "Second",
            message: "Second message"
        )
        notificationManager.showNotification(secondNotification)
        
        XCTAssertEqual(notificationManager.currentNotification?.title, "Second")
        XCTAssertEqual(notificationManager.currentNotification?.message, "Second message")
        XCTAssertEqual(notificationManager.currentNotification?.type, .error)
    }
    
    // MARK: - Notification Content Tests
    
    func testNotificationWithLongMessage() {
        let longMessage = String(repeating: "This is a very long message. ", count: 100)
        let notification = AppNotification(
            type: .info,
            title: "Long Message",
            message: longMessage
        )
        
        notificationManager.showNotification(notification)
        
        XCTAssertTrue(notificationManager.isShowingNotification)
        XCTAssertEqual(notificationManager.currentNotification?.message, longMessage)
    }
    
    func testNotificationWithEmptyMessage() {
        let notification = AppNotification(
            type: .info,
            title: "Empty Message",
            message: ""
        )
        
        notificationManager.showNotification(notification)
        
        XCTAssertTrue(notificationManager.isShowingNotification)
        XCTAssertEqual(notificationManager.currentNotification?.message, "")
    }
    
    func testNotificationWithEmptyTitle() {
        let notification = AppNotification(
            type: .info,
            title: "",
            message: "Test message"
        )
        
        notificationManager.showNotification(notification)
        
        XCTAssertTrue(notificationManager.isShowingNotification)
        XCTAssertEqual(notificationManager.currentNotification?.title, "")
    }
    
    func testNotificationWithSpecialCharacters() {
        let specialMessage = "Message with special chars: !@#$%^&*()_+-=[]{}|;':\",./<>?"
        let notification = AppNotification(
            type: .info,
            title: "Special Chars",
            message: specialMessage
        )
        
        notificationManager.showNotification(notification)
        
        XCTAssertTrue(notificationManager.isShowingNotification)
        XCTAssertEqual(notificationManager.currentNotification?.message, specialMessage)
    }
    
    func testNotificationWithUnicodeCharacters() {
        let unicodeMessage = "Unicode message: Hello 世界 🌍 émojis 🚀"
        let notification = AppNotification(
            type: .info,
            title: "Unicode",
            message: unicodeMessage
        )
        
        notificationManager.showNotification(notification)
        
        XCTAssertTrue(notificationManager.isShowingNotification)
        XCTAssertEqual(notificationManager.currentNotification?.message, unicodeMessage)
    }
    
    // MARK: - Performance Tests
    
    func testNotificationPerformance() {
        measure {
            for i in 0..<100 {
                let notification = AppNotification(
                    type: .info,
                    title: "Performance Test \(i)",
                    message: "Message \(i)"
                )
                notificationManager.showNotification(notification)
                notificationManager.dismissNotification()
            }
        }
    }
    
    func testNotificationReplacementPerformance() {
        // Show initial notification
        let initialNotification = AppNotification(
            type: .info,
            title: "Initial",
            message: "Initial message"
        )
        notificationManager.showNotification(initialNotification)
        
        measure {
            for i in 0..<1000 {
                let notification = AppNotification(
                    type: .info,
                    title: "Replacement \(i)",
                    message: "Replacement message \(i)"
                )
                notificationManager.showNotification(notification)
            }
        }
        
        // Clean up
        notificationManager.dismissNotification()
    }
    
    // MARK: - Edge Cases Tests
    
    func testMultipleDismissCalls() {
        // Show a notification
        let notification = AppNotification(
            type: .info,
            title: "Test",
            message: "Test message"
        )
        notificationManager.showNotification(notification)
        
        // Call dismiss multiple times
        notificationManager.dismissNotification()
        notificationManager.dismissNotification()
        notificationManager.dismissNotification()
        
        XCTAssertFalse(notificationManager.isShowingNotification)
        
        // Wait for the async cleanup
        let expectation = XCTestExpectation(description: "Notification dismissed")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
        XCTAssertNil(notificationManager.currentNotification)
    }
    
    // MARK: - Thread Safety Tests
    
    func testNotificationThreadSafety() {
        let expectation = XCTestExpectation(description: "Thread safety test")
        expectation.expectedFulfillmentCount = 10

        for i in 0..<10 {
            DispatchQueue.global().async {
                let notification = AppNotification(
                    type: .info,
                    title: "Thread \(i)",
                    message: "Message from thread \(i)"
                )

                // Ensure UI updates happen on main actor using shared instance
                Task { @MainActor in
                    NotificationManager.shared.showNotification(notification)
                    expectation.fulfill()
                }
            }
        }

        wait(for: [expectation], timeout: 5.0)
        
        // Clean up
        NotificationManager.shared.dismissNotification()
        
        // Wait for the async cleanup (NotificationManager clears currentNotification after 0.3 seconds)
        let cleanupExpectation = XCTestExpectation(description: "Notification cleanup")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            cleanupExpectation.fulfill()
        }
        
        wait(for: [cleanupExpectation], timeout: 1.0)
        
        // Now verify the notification is properly dismissed
        XCTAssertFalse(NotificationManager.shared.isShowingNotification)
        XCTAssertNil(NotificationManager.shared.currentNotification)
    }
    
    // MARK: - Notification Type Tests
    
    func testAllNotificationTypes() {
        let types: [NotificationType] = [.success, .error, .permission, .info]
        
        for type in types {
            let notification = AppNotification(
                type: type,
                title: "\(type) Test",
                message: "Testing \(type) notification"
            )
            notificationManager.showNotification(notification)
            
            XCTAssertEqual(notificationManager.currentNotification?.type, type)
            notificationManager.dismissNotification()
        }
    }
    
    // MARK: - Singleton Tests
    
    func testNotificationManagerSingleton() {
        let manager1 = NotificationManager.shared
        let manager2 = NotificationManager.shared
        
        XCTAssertTrue(manager1 === manager2, "NotificationManager should be a singleton")
    }
    
    // MARK: - Auto Dismiss Tests
    
    func testAutoDismissNotification() {
        let notification = AppNotification(
            type: .info,
            title: "Auto Dismiss",
            message: "This will auto dismiss",
            autoDismissDuration: 0.1
        )
        
        notificationManager.showNotification(notification)
        
        XCTAssertTrue(notificationManager.isShowingNotification)
        
        // Wait for auto dismiss (0.1s) + animation cleanup (0.3s) + buffer
        let expectation = XCTestExpectation(description: "Auto dismiss")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertFalse(notificationManager.isShowingNotification)
        XCTAssertNil(notificationManager.currentNotification)
    }
    
    // MARK: - Notification Actions Tests
    
    func testNotificationWithActions() {
        let primaryAction = NotificationAction(
            title: "Primary",
            action: {},
            style: .primary
        )
        
        let secondaryAction = NotificationAction(
            title: "Secondary",
            action: {},
            style: .secondary
        )
        
        let notification = AppNotification(
            type: .info,
            title: "With Actions",
            message: "This has actions",
            primaryAction: primaryAction,
            secondaryAction: secondaryAction
        )
        
        notificationManager.showNotification(notification)
        
        XCTAssertTrue(notificationManager.isShowingNotification)
        XCTAssertNotNil(notificationManager.currentNotification?.primaryAction)
        XCTAssertNotNil(notificationManager.currentNotification?.secondaryAction)
        XCTAssertEqual(notificationManager.currentNotification?.primaryAction?.title, "Primary")
        XCTAssertEqual(notificationManager.currentNotification?.secondaryAction?.title, "Secondary")
    }
}
