import Foundation
import Testing

@testable import LogCore

@Suite("VoiceLogTransferPayload Tests")
struct VoiceLogTransferPayloadTests {

    @Test("Round-trip toDictionary and from(metadata:)")
    func dictionaryRoundTrip() throws {
        let log = VoiceLog(
            transcript: "Test entry",
            latitude: 37.7749,
            longitude: -122.4194,
            category: .todo,
            audioFileName: "test.m4a",
            durationSeconds: 12.5
        )

        let payload = VoiceLogTransferPayload(voiceLog: log)
        let dict = try payload.toDictionary()
        let decoded = try VoiceLogTransferPayload.from(metadata: dict)

        #expect(decoded.id == log.id)
        #expect(decoded.timestamp == log.timestamp)
        #expect(decoded.transcript == "Test entry")
        #expect(decoded.latitude == 37.7749)
        #expect(decoded.longitude == -122.4194)
        #expect(decoded.categoryRawValue == "todo")
        #expect(decoded.audioFileName == "test.m4a")
        #expect(decoded.durationSeconds == 12.5)
    }

    @Test("toVoiceLog() produces correct fields")
    func toVoiceLog() {
        let id = UUID()
        let date = Date(timeIntervalSince1970: 1_000_000)
        let log = VoiceLog(
            id: id,
            timestamp: date,
            transcript: "Hello world",
            latitude: 40.0,
            longitude: -74.0,
            category: .mood,
            audioFileName: "mood.m4a",
            durationSeconds: 3.0
        )

        let payload = VoiceLogTransferPayload(voiceLog: log)
        let result = payload.toVoiceLog()

        #expect(result.id == id)
        #expect(result.timestamp == date)
        #expect(result.transcript == "Hello world")
        #expect(result.latitude == 40.0)
        #expect(result.longitude == -74.0)
        #expect(result.category == .mood)
        #expect(result.audioFileName == "mood.m4a")
        #expect(result.durationSeconds == 3.0)
    }

    @Test("from(metadata:) throws on missing payload")
    func missingPayloadThrows() {
        #expect(throws: TransferPayloadError.missingPayload) {
            _ = try VoiceLogTransferPayload.from(metadata: [:])
        }
    }

    @Test("Nil optional fields round-trip correctly")
    func nilOptionalFields() throws {
        let log = VoiceLog(
            transcript: "No location or audio",
            category: .thoughts
        )

        let payload = VoiceLogTransferPayload(voiceLog: log)
        let dict = try payload.toDictionary()
        let decoded = try VoiceLogTransferPayload.from(metadata: dict)

        #expect(decoded.latitude == nil)
        #expect(decoded.longitude == nil)
        #expect(decoded.audioFileName == nil)
        #expect(decoded.durationSeconds == nil)

        let result = decoded.toVoiceLog()
        #expect(result.latitude == nil)
        #expect(result.longitude == nil)
        #expect(result.audioFileName == nil)
        #expect(result.durationSeconds == nil)
        #expect(result.category == .thoughts)
    }

    @Test("JSON encode/decode round-trip preserves all fields")
    func jsonRoundTrip() throws {
        let log = VoiceLog(
            transcript: "Full round trip",
            latitude: 51.5074,
            longitude: -0.1278,
            category: .log,
            audioFileName: "london.m4a",
            durationSeconds: 60.0
        )

        let payload = VoiceLogTransferPayload(voiceLog: log)
        let data = try JSONEncoder().encode(payload)
        let decoded = try JSONDecoder().decode(VoiceLogTransferPayload.self, from: data)

        #expect(decoded.id == payload.id)
        #expect(decoded.timestamp == payload.timestamp)
        #expect(decoded.transcript == payload.transcript)
        #expect(decoded.latitude == payload.latitude)
        #expect(decoded.longitude == payload.longitude)
        #expect(decoded.categoryRawValue == payload.categoryRawValue)
        #expect(decoded.audioFileName == payload.audioFileName)
        #expect(decoded.durationSeconds == payload.durationSeconds)
    }
}
