import LogCore
import SwiftUI

@MainActor
final class RecordingViewModel: ObservableObject {

    enum State: Equatable {
        case idle
        case recording
        case selectingCategory
        case saving
    }

    @Published var state: State = .idle
    @Published var elapsedSeconds: Double = 0
    @Published var transcript: String = ""

    let audioRecorder = AudioRecorderService()
    let locationService = LocationService()
    let transcriptionService = TranscriptionService(modelVariant: "base")

    private var audioURL: URL?
    private var recordingDuration: Double?
    private var capturedLocation: (latitude: Double, longitude: Double)?
    private var autoDismissTask: Task<Void, Never>?
    private weak var modelContext: ModelContext?

    // MARK: - Recording

    func startRecording() {
        do {
            audioURL = try audioRecorder.startRecording()
            state = .recording

            Task {
                capturedLocation = await locationService.requestLocation()
            }
        } catch {
            print("Failed to start recording: \(error)")
        }
    }

    func stopRecording(context: ModelContext) {
        guard let result = audioRecorder.stopRecording() else { return }
        audioURL = result.url
        recordingDuration = result.duration
        elapsedSeconds = result.duration
        modelContext = context
        state = .selectingCategory

        startAutoDismissTimer()
        beginTranscription()
    }

    // MARK: - Category Selection

    func selectCategory(_ category: LogCategory, context: ModelContext) {
        autoDismissTask?.cancel()
        saveLog(category: category, context: context)
    }

    // MARK: - Private

    private func startAutoDismissTimer() {
        autoDismissTask?.cancel()
        autoDismissTask = Task {
            try? await Task.sleep(for: .seconds(5))
            guard !Task.isCancelled, state == .selectingCategory else { return }
            if let modelContext {
                saveLog(category: .log, context: modelContext)
            } else {
                reset()
            }
        }
    }

    private func beginTranscription() {
        Task {
            do {
                guard let audioURL else { return }
                transcript = try await transcriptionService.transcribe(audioURL: audioURL)
            } catch {
                print("Transcription failed: \(error)")
            }
        }
    }

    private func saveLog(category: LogCategory, context: ModelContext) {
        state = .saving

        let log = VoiceLog(
            transcript: transcript,
            latitude: capturedLocation?.latitude,
            longitude: capturedLocation?.longitude,
            category: category,
            audioFileName: audioURL?.lastPathComponent,
            durationSeconds: recordingDuration
        )

        context.insert(log)

        // Brief delay so the saving indicator is visible
        Task {
            try? await Task.sleep(for: .milliseconds(400))
            reset()
        }
    }

    private func reset() {
        state = .idle
        elapsedSeconds = 0
        transcript = ""
        audioURL = nil
        recordingDuration = nil
        capturedLocation = nil
        autoDismissTask = nil
    }
}
