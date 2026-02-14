import Foundation
import WhisperKit

@MainActor
public final class TranscriptionService: ObservableObject {
    @Published public var isLoading = false
    @Published public var isTranscribing = false

    private var whisperKit: WhisperKit?
    private let modelVariant: String

    public init(modelVariant: String = "base") {
        self.modelVariant = modelVariant
    }

    public func loadModel() async throws {
        guard whisperKit == nil else { return }
        isLoading = true
        defer { isLoading = false }

        whisperKit = try await WhisperKit(model: modelVariant)
    }

    public func transcribe(audioURL: URL) async throws -> String {
        if whisperKit == nil {
            try await loadModel()
        }

        guard let whisperKit else {
            throw TranscriptionError.modelNotLoaded
        }

        isTranscribing = true
        defer { isTranscribing = false }

        let results = try await whisperKit.transcribe(audioPath: audioURL.path())

        return results
            .compactMap(\.text)
            .joined(separator: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

public enum TranscriptionError: LocalizedError {
    case modelNotLoaded

    public var errorDescription: String? {
        switch self {
        case .modelNotLoaded:
            "Whisper model failed to load."
        }
    }
}
