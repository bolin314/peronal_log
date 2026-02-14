import XCTest

final class iOSScreenshotTests: XCTestCase {

    private var app: XCUIApplication!
    private let screenshotDir = "/tmp/ios-screenshots"

    override func setUpWithError() throws {
        continueAfterFailure = true
        app = XCUIApplication()
        app.launch()

        try FileManager.default.createDirectory(
            atPath: screenshotDir,
            withIntermediateDirectories: true
        )
    }

    // MARK: - Screenshots

    func testCaptureLogListEmpty() throws {
        // App launches on the Logs tab by default — empty state with no data
        sleep(1)
        saveScreenshot(named: "04_ios_log_list_empty")
    }

    func testCaptureRecordIdle() throws {
        let recordTab = app.tabBars.buttons["Record"]
        XCTAssertTrue(recordTab.waitForExistence(timeout: 5), "Record tab should exist")
        recordTab.tap()

        sleep(1)
        saveScreenshot(named: "05_ios_record_idle")
    }

    // MARK: - Helpers

    private func saveScreenshot(named name: String) {
        let screenshot = app.screenshot()

        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)

        let pngData = screenshot.pngRepresentation
        let filePath = "\(screenshotDir)/\(name).png"
        FileManager.default.createFile(atPath: filePath, contents: pngData)
    }
}
