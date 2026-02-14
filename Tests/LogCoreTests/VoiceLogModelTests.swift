import Foundation
import Testing

@testable import LogCore

@Suite("VoiceLog Model Tests")
struct VoiceLogModelTests {

    @Test("VoiceLog initializes with defaults")
    func defaultInit() {
        let log = VoiceLog()

        #expect(log.transcript == "")
        #expect(log.category == .log)
        #expect(log.latitude == nil)
        #expect(log.longitude == nil)
        #expect(log.audioFileName == nil)
        #expect(log.durationSeconds == nil)
    }

    @Test("VoiceLog initializes with custom values")
    func customInit() {
        let log = VoiceLog(
            transcript: "Buy groceries",
            latitude: 37.7749,
            longitude: -122.4194,
            category: .todo,
            audioFileName: "test.m4a",
            durationSeconds: 5.2
        )

        #expect(log.transcript == "Buy groceries")
        #expect(log.latitude == 37.7749)
        #expect(log.longitude == -122.4194)
        #expect(log.category == .todo)
        #expect(log.audioFileName == "test.m4a")
        #expect(log.durationSeconds == 5.2)
    }
}

@Suite("LogCategory Tests")
struct LogCategoryTests {

    @Test("All cases are present")
    func allCases() {
        #expect(LogCategory.allCases.count == 4)
        #expect(LogCategory.allCases.contains(.todo))
        #expect(LogCategory.allCases.contains(.thoughts))
        #expect(LogCategory.allCases.contains(.log))
        #expect(LogCategory.allCases.contains(.mood))
    }

    @Test("Display names are human readable")
    func displayNames() {
        #expect(LogCategory.todo.displayName == "To-Do")
        #expect(LogCategory.thoughts.displayName == "Thoughts")
        #expect(LogCategory.log.displayName == "Log")
        #expect(LogCategory.mood.displayName == "Mood")
    }

    @Test("System images are valid SF Symbol names")
    func systemImages() {
        for category in LogCategory.allCases {
            #expect(!category.systemImage.isEmpty)
        }
    }

    @Test("JSON round-trip encoding")
    func jsonCoding() throws {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        for category in LogCategory.allCases {
            let data = try encoder.encode(category)
            let decoded = try decoder.decode(LogCategory.self, from: data)
            #expect(decoded == category)
        }
    }
}
