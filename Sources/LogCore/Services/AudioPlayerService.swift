import AVFoundation
import Foundation

@MainActor
public final class AudioPlayerService: NSObject, ObservableObject {
    @Published public var isPlaying = false
    @Published public var currentTime: Double = 0
    @Published public var duration: Double = 0

    private var player: AVAudioPlayer?
    private var timer: Timer?

    public override init() {
        super.init()
    }

    public func play(url: URL) throws {
        if player?.url == url, !isPlaying {
            // Resume playback of same file
            player?.play()
            isPlaying = true
            startTimer()
            return
        }

        stop()

        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playback, mode: .default)
        try session.setActive(true)

        player = try AVAudioPlayer(contentsOf: url)
        player?.delegate = self
        duration = player?.duration ?? 0
        player?.play()
        isPlaying = true
        startTimer()
    }

    public func pause() {
        player?.pause()
        isPlaying = false
        timer?.invalidate()
        timer = nil
    }

    public func stop() {
        player?.stop()
        player = nil
        isPlaying = false
        currentTime = 0
        duration = 0
        timer?.invalidate()
        timer = nil
    }

    public func seek(to time: Double) {
        player?.currentTime = time
        currentTime = time
    }

    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self, let player = self.player else { return }
                self.currentTime = player.currentTime
            }
        }
    }
}

extension AudioPlayerService: @preconcurrency AVAudioPlayerDelegate {
    nonisolated public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        Task { @MainActor in
            self.isPlaying = false
            self.currentTime = 0
            self.timer?.invalidate()
            self.timer = nil
        }
    }
}
