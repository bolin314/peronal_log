import AVFoundation
import Foundation

@MainActor
public final class AudioRecorderService: NSObject, ObservableObject {
    @Published public var isRecording = false
    @Published public var elapsedSeconds: Double = 0

    private var recorder: AVAudioRecorder?
    private var timer: Timer?
    private var startTime: Date?

    public var currentFileURL: URL? {
        recorder?.url
    }

    public override init() {
        super.init()
    }

    public func startRecording() throws -> URL {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.record, mode: .default)
        try session.setActive(true)

        let fileName = "\(UUID().uuidString).m4a"
        let url = Self.recordingsDirectory.appendingPathComponent(fileName)

        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 16000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
        ]

        recorder = try AVAudioRecorder(url: url, settings: settings)
        recorder?.delegate = self
        recorder?.record()

        isRecording = true
        startTime = .now
        elapsedSeconds = 0

        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self, let startTime = self.startTime else { return }
                self.elapsedSeconds = Date.now.timeIntervalSince(startTime)
            }
        }

        return url
    }

    public func stopRecording() -> (url: URL, duration: Double)? {
        guard let recorder, isRecording else { return nil }

        let url = recorder.url
        let duration = elapsedSeconds

        recorder.stop()
        self.recorder = nil
        isRecording = false

        timer?.invalidate()
        timer = nil
        startTime = nil

        return (url: url, duration: duration)
    }

    public static var recordingsDirectory: URL {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Recordings", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }
}

extension AudioRecorderService: @preconcurrency AVAudioRecorderDelegate {
    nonisolated public func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        Task { @MainActor in
            if !flag {
                isRecording = false
            }
        }
    }
}
