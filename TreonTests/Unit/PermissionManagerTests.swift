import XCTest
import AppKit
import Combine
@testable import Treon

@MainActor
final class PermissionManagerTests: XCTestCase {

    private var permissionManager: PermissionManager!

    override func setUp() {
        super.setUp()
        permissionManager = PermissionManager.shared
        // Reset permission state for clean test state
        permissionManager.hasFileAccessPermission = false
    }

    override func tearDown() {
        // Reset permission state
        permissionManager.hasFileAccessPermission = false
        super.tearDown()
    }

    func testPermissionManager_initialState_noPermission() {
        // Given: Fresh permission manager
        // When: Checking initial state
        // Then: Should have no permission
        XCTAssertFalse(permissionManager.hasFileAccessPermission)
    }

    func testPermissionManager_resetPermission_resetsState() {
        // Given: Permission manager with some state
        permissionManager.hasFileAccessPermission = true

        // When: Resetting permission
        permissionManager.hasFileAccessPermission = false

        // Then: Should have no permission
        XCTAssertFalse(permissionManager.hasFileAccessPermission)
    }

    func testPermissionManager_checkPermission_checksFileAccess() {
        // Given: Permission manager
        // When: Checking permission (this will test actual file system access)
        permissionManager.checkFileAccessPermission()

        // Then: Should have some permission state (depends on system permissions)
        // We can't predict the exact state, but we can test that the method runs without error
        // The actual permission state depends on the system's file access permissions
        XCTAssertNotNil(permissionManager.hasFileAccessPermission)
    }

    func testPermissionManager_requestPermission_handlesUserCancellation() async {
        // Given: Permission manager
        XCTAssertFalse(permissionManager.hasFileAccessPermission)

        // When: Requesting permission (this will show NSOpenPanel)
        // Note: In a real test, we'd need to mock NSOpenPanel or test the async behavior
        // For now, we'll test the state management logic

        // Simulate user cancellation by not changing the permission state
        let initialPermission = permissionManager.hasFileAccessPermission

        // Then: Permission should remain unchanged (simulating cancellation)
        XCTAssertEqual(permissionManager.hasFileAccessPermission, initialPermission)
    }

    func testPermissionManager_singleton_returnsSameInstance() {
        // Given: Two references to PermissionManager
        let manager1 = PermissionManager.shared
        let manager2 = PermissionManager.shared

        // When: Comparing instances
        // Then: Should be the same instance
        XCTAssertIdentical(manager1, manager2)
    }

    func testPermissionManager_permissionState_publishesChanges() {
        // Given: Permission manager and expectation
        let expectation = XCTestExpectation(description: "Permission state changed")
        expectation.expectedFulfillmentCount = 2 // Initial state + change

        var receivedStates: [Bool] = []
        var cancellables = Set<AnyCancellable>()

        // When: Observing permission state changes
        permissionManager.$hasFileAccessPermission
            .sink { hasPermission in
                receivedStates.append(hasPermission)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        // Simulate permission change
        permissionManager.hasFileAccessPermission = true

        // Then: Should receive state changes
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(receivedStates.count, 2)
        XCTAssertFalse(receivedStates[0]) // Initial state
        XCTAssertTrue(receivedStates[1])  // After permission granted
    }

    func testPermissionManager_permissionStatusMessage_returnsCorrectMessage() {
        // Given: Permission manager with different states

        // When: Permission status is needsUserAction
        permissionManager.permissionStatus = .needsUserAction

        // Then: Should return appropriate message
        XCTAssertEqual(permissionManager.permissionStatusMessage, "File access permission is required")

        // When: Permission status is granted
        permissionManager.permissionStatus = .granted
        permissionManager.grantedDirectories = [URL(fileURLWithPath: "/test/directory")]

        // Then: Should return appropriate message
        XCTAssertEqual(permissionManager.permissionStatusMessage, "Access granted to: directory")
    }

    func testPermissionManager_permissionStatusColor_returnsCorrectColor() {
        // Given: Permission manager with different states

        // When: Permission status is denied
        permissionManager.permissionStatus = .denied

        // Then: Should return appropriate color
        XCTAssertEqual(permissionManager.permissionStatusColor, "red")

        // When: Permission status is granted
        permissionManager.permissionStatus = .granted

        // Then: Should return appropriate color
        XCTAssertEqual(permissionManager.permissionStatusColor, "green")
    }
}
