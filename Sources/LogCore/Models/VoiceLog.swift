import Foundation
import SwiftData

@Model
public final class VoiceLog {
    public var id: UUID
    public var timestamp: Date
    public var transcript: String
    public var latitude: Double?
    public var longitude: Double?
    public var category: LogCategory
    public var audioFileName: String?
    public var durationSeconds: Double?

    public init(
        id: UUID = UUID(),
        timestamp: Date = .now,
        transcript: String = "",
        latitude: Double? = nil,
        longitude: Double? = nil,
        category: LogCategory = .log,
        audioFileName: String? = nil,
        durationSeconds: Double? = nil
    ) {
        self.id = id
        self.timestamp = timestamp
        self.transcript = transcript
        self.latitude = latitude
        self.longitude = longitude
        self.category = category
        self.audioFileName = audioFileName
        self.durationSeconds = durationSeconds
    }
}
