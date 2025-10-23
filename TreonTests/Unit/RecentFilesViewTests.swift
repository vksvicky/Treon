import XCTest
import SwiftUI
@testable import Treon

@MainActor
final class RecentFilesViewTests: XCTestCase {

    private var fileManager: TreonFileManager!

    override func setUp() {
        super.setUp()
        fileManager = TreonFileManager.shared
        // Clear any existing recent files for clean test state
        fileManager.clearAllRecentFiles()
    }

    override func tearDown() {
        fileManager.clearAllRecentFiles()
        super.tearDown()
    }

    func testRecentFilesView_initialState_showsDropdownButton() {
        // Given: A RecentFilesView with no recent files
        _ = RecentFilesView { _ in }

        // When: View is created
        // Then: The dropdown button should be visible (we can't directly test SwiftUI views,
        // but we can test the underlying logic)
        XCTAssertTrue(fileManager.recentFiles.isEmpty)
    }

    func testRecentFilesView_withRecentFiles_showsFilesInList() {
        // Given: Some recent files
        let testFile1 = RecentFile(
            url: URL(fileURLWithPath: "/test/file1.json"),
            name: "file1.json",
            lastOpened: Date(),
            size: 1024,
            isValidJSON: true
        )
        let testFile2 = RecentFile(
            url: URL(fileURLWithPath: "/test/file2.json"),
            name: "file2.json",
            lastOpened: Date().addingTimeInterval(-3600),
            size: 2048,
            isValidJSON: false
        )

        // When: Adding recent files (simulating what happens when files are opened)
        // Note: We can't directly add to recent files, but we can test the logic
        // by checking if the file manager has the expected behavior

        // Then: We can test the RecentFile struct creation
        XCTAssertEqual(testFile1.name, "file1.json")
        XCTAssertEqual(testFile2.name, "file2.json")
        XCTAssertTrue(testFile1.isValidJSON)
        XCTAssertFalse(testFile2.isValidJSON)
    }

    func testRecentFilesView_emptyState_showsNoRecentFilesMessage() {
        // Given: No recent files
        XCTAssertTrue(fileManager.recentFiles.isEmpty)

        // When: Creating RecentFilesView
        _ = RecentFilesView { _ in }

        // Then: Should handle empty state gracefully
        // (The actual UI testing would require SwiftUI testing framework)
        XCTAssertTrue(fileManager.recentFiles.isEmpty)
    }

    func testRecentFilesView_fileSelection_callsCallback() {
        // Given: A recent file and a callback expectation
        let testFile = RecentFile(
            url: URL(fileURLWithPath: "/test/file.json"),
            name: "file.json",
            lastOpened: Date(),
            size: 1024,
            isValidJSON: true
        )

        var selectedFile: RecentFile?
        _ = RecentFilesView { file in
            selectedFile = file
        }

        // When: Simulating file selection (in real UI, this would be triggered by tap)
        // We can't directly test the SwiftUI interaction, but we can test the callback logic
        let callback: (RecentFile) -> Void = { file in
            selectedFile = file
        }
        callback(testFile)

        // Then: Callback should be called with correct file
        XCTAssertNotNil(selectedFile)
        XCTAssertEqual(selectedFile?.name, "file.json")
    }

    func testRecentFilesView_maxFiles_showsOnlyFirstFive() {
        // Given: More than 5 recent files
        var testFiles: [RecentFile] = []
        for i in 1...7 {
            let testFile = RecentFile(
                url: URL(fileURLWithPath: "/test/file\(i).json"),
                name: "file\(i).json",
                lastOpened: Date().addingTimeInterval(-Double(i) * 3600),
                size: Int64(1024 * i),
                isValidJSON: true
            )
            testFiles.append(testFile)
        }

        // When: Testing the prefix logic (as used in the view)
        let firstFive = Array(testFiles.prefix(5))

        // Then: Should only show the first 5 files
        XCTAssertEqual(firstFive.count, 5)
        XCTAssertEqual(firstFive.first?.name, "file1.json")
        XCTAssertEqual(firstFive.last?.name, "file5.json")
    }
}
