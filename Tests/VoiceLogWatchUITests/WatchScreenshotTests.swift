import XCTest

final class WatchScreenshotTests: XCTestCase {

    private var app: XCUIApplication!
    private let screenshotDir = "/tmp/watchos-screenshots"

    override func setUpWithError() throws {
        continueAfterFailure = true
        app = XCUIApplication()
        app.launch()

        // Ensure output directory exists
        try FileManager.default.createDirectory(
            atPath: screenshotDir,
            withIntermediateDirectories: true
        )
    }

    // MARK: - Screenshots

    func testCaptureHomeHub() throws {
        // The app launches to the NavigationStack hub with "Voice Logs" and "Record"
        sleep(1) // let animations settle
        saveScreenshot(named: "01_home_hub")
    }

    func testCaptureVoiceLogsList() throws {
        let voiceLogsLink = app.buttons["Voice Logs"]
        XCTAssertTrue(voiceLogsLink.waitForExistence(timeout: 5), "Voice Logs link should exist")
        voiceLogsLink.tap()

        sleep(1)
        saveScreenshot(named: "02_voice_logs_list")
    }

    func testCaptureRecordScreen() throws {
        let recordLink = app.buttons["Record"]
        XCTAssertTrue(recordLink.waitForExistence(timeout: 5), "Record link should exist")
        recordLink.tap()

        sleep(1)
        saveScreenshot(named: "03_record_screen")
    }

    // MARK: - Helpers

    private func saveScreenshot(named name: String) {
        let screenshot = app.screenshot()

        // Attach to xcresult bundle
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)

        // Write PNG to disk for artifact upload
        let pngData = screenshot.pngRepresentation
        let filePath = "\(screenshotDir)/\(name).png"
        FileManager.default.createFile(atPath: filePath, contents: pngData)
    }
}
