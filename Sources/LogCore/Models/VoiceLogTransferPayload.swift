import Foundation

public struct VoiceLogTransferPayload: Codable, Sendable {
    public let id: UUID
    public let timestamp: Date
    public let transcript: String
    public let latitude: Double?
    public let longitude: Double?
    public let categoryRawValue: String
    public let audioFileName: String?
    public let durationSeconds: Double?

    public init(voiceLog: VoiceLog) {
        self.id = voiceLog.id
        self.timestamp = voiceLog.timestamp
        self.transcript = voiceLog.transcript
        self.latitude = voiceLog.latitude
        self.longitude = voiceLog.longitude
        self.categoryRawValue = voiceLog.category.rawValue
        self.audioFileName = voiceLog.audioFileName
        self.durationSeconds = voiceLog.durationSeconds
    }

    private static let metadataKey = "voiceLogPayload"

    public func toDictionary() throws -> [String: Any] {
        let data = try JSONEncoder().encode(self)
        return [Self.metadataKey: data]
    }

    public static func from(metadata: [String: Any]) throws -> VoiceLogTransferPayload {
        guard let data = metadata[metadataKey] as? Data else {
            throw TransferPayloadError.missingPayload
        }
        return try JSONDecoder().decode(VoiceLogTransferPayload.self, from: data)
    }

    public func toVoiceLog() -> VoiceLog {
        VoiceLog(
            id: id,
            timestamp: timestamp,
            transcript: transcript,
            latitude: latitude,
            longitude: longitude,
            category: LogCategory(rawValue: categoryRawValue) ?? .log,
            audioFileName: audioFileName,
            durationSeconds: durationSeconds
        )
    }
}

public enum TransferPayloadError: Error, LocalizedError {
    case missingPayload

    public var errorDescription: String? {
        switch self {
        case .missingPayload:
            return "Voice log payload not found in transfer metadata"
        }
    }
}
