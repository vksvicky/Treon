import XCTest
import Combine
@testable import Treon

@MainActor
final class NotificationManagerTests: XCTestCase {
    
    private var notificationManager: NotificationManager!
    private var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        notificationManager = NotificationManager.shared
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDown() {
        cancellables = nil
        // Reset notification state
        notificationManager.dismissNotification()
        super.tearDown()
    }
    
    func testNotificationManager_initialState_noNotificationShowing() {
        // Given: Fresh notification manager
        // When: Checking initial state
        // Then: No notification should be showing
        XCTAssertFalse(notificationManager.isShowingNotification)
        XCTAssertNil(notificationManager.currentNotification)
    }
    
    func testNotificationManager_showNotification_setsCorrectState() {
        // Given: A test notification
        let testNotification = AppNotification(
            type: .info,
            title: "Test Title",
            message: "Test Message"
        )
        
        // When: Showing notification
        notificationManager.showNotification(testNotification)
        
        // Then: State should be updated
        XCTAssertTrue(notificationManager.isShowingNotification)
        XCTAssertNotNil(notificationManager.currentNotification)
        XCTAssertEqual(notificationManager.currentNotification?.title, "Test Title")
        XCTAssertEqual(notificationManager.currentNotification?.message, "Test Message")
        XCTAssertEqual(notificationManager.currentNotification?.type, .info)
    }
    
    func testNotificationManager_dismissNotification_clearsState() {
        // Given: A notification is showing
        let testNotification = AppNotification(
            type: .error,
            title: "Error Title",
            message: "Error Message"
        )
        notificationManager.showNotification(testNotification)
        XCTAssertTrue(notificationManager.isShowingNotification)
        
        // When: Dismissing notification
        notificationManager.dismissNotification()
        
        // Then: State should be cleared
        XCTAssertFalse(notificationManager.isShowingNotification)
        // Note: currentNotification might still be set for animation purposes
    }
    
    func testNotificationManager_notificationWithActions_createsCorrectActions() {
        // Given: A notification with actions
        var primaryActionCalled = false
        var secondaryActionCalled = false
        
        let primaryAction = NotificationAction(
            title: "Primary",
            action: { primaryActionCalled = true },
            style: .primary
        )
        
        let secondaryAction = NotificationAction(
            title: "Secondary",
            action: { secondaryActionCalled = true },
            style: .secondary
        )
        
        let testNotification = AppNotification(
            type: .permission,
            title: "Permission Required",
            message: "Please grant permission",
            primaryAction: primaryAction,
            secondaryAction: secondaryAction
        )
        
        // When: Showing notification
        notificationManager.showNotification(testNotification)
        
        // Then: Actions should be set correctly
        XCTAssertTrue(notificationManager.isShowingNotification)
        XCTAssertNotNil(notificationManager.currentNotification?.primaryAction)
        XCTAssertNotNil(notificationManager.currentNotification?.secondaryAction)
        XCTAssertEqual(notificationManager.currentNotification?.primaryAction?.title, "Primary")
        XCTAssertEqual(notificationManager.currentNotification?.secondaryAction?.title, "Secondary")
        
        // When: Executing actions
        notificationManager.currentNotification?.primaryAction?.action()
        notificationManager.currentNotification?.secondaryAction?.action()
        
        // Then: Actions should be called
        XCTAssertTrue(primaryActionCalled)
        XCTAssertTrue(secondaryActionCalled)
    }
    
    func testNotificationManager_notificationWithDuration_autoDismisses() {
        // Given: A notification with short duration
        let testNotification = AppNotification(
            type: .success,
            title: "Success",
            message: "Operation completed",
            autoDismissDuration: 0.1 // Very short duration for testing
        )
        
        let expectation = XCTestExpectation(description: "Notification auto-dismissed")
        
        // When: Showing notification and waiting for auto-dismiss
        notificationManager.showNotification(testNotification)
        XCTAssertTrue(notificationManager.isShowingNotification)
        
        // Wait for auto-dismiss
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
        
        // Then: Notification should be dismissed
        XCTAssertFalse(notificationManager.isShowingNotification)
    }
    
    func testNotificationManager_notificationWithoutDuration_doesNotAutoDismiss() {
        // Given: A notification without duration
        let testNotification = AppNotification(
            type: .error,
            title: "Error",
            message: "Something went wrong"
            // No duration specified
        )
        
        // When: Showing notification
        notificationManager.showNotification(testNotification)
        
        // Then: Notification should remain showing
        XCTAssertTrue(notificationManager.isShowingNotification)
        
        // Wait a bit to ensure it doesn't auto-dismiss
        let expectation = XCTestExpectation(description: "Notification stays visible")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertTrue(self.notificationManager.isShowingNotification)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 0.5)
    }
    
    func testNotificationManager_multipleNotifications_replacesPrevious() {
        // Given: First notification
        let firstNotification = AppNotification(
            type: .info,
            title: "First",
            message: "First message"
        )
        
        // When: Showing first notification
        notificationManager.showNotification(firstNotification)
        XCTAssertEqual(notificationManager.currentNotification?.title, "First")
        
        // When: Showing second notification
        let secondNotification = AppNotification(
            type: .error,
            title: "Second",
            message: "Second message"
        )
        notificationManager.showNotification(secondNotification)
        
        // Then: Second notification should replace first
        XCTAssertTrue(notificationManager.isShowingNotification)
        XCTAssertEqual(notificationManager.currentNotification?.title, "Second")
        XCTAssertEqual(notificationManager.currentNotification?.type, .error)
    }
}
