import LogCore
import SwiftUI

struct LogDetailView: View {
    let log: VoiceLog

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @StateObject private var player = AudioPlayerService()

    private var audioURL: URL? {
        guard let fileName = log.audioFileName else { return nil }
        return AudioRecorderService.recordingsDirectory.appendingPathComponent(fileName)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header
                transcriptSection
                if audioURL != nil {
                    audioPlayerSection
                }
                metadataSection
                deleteButton
            }
            .padding()
        }
        .navigationTitle("Log Detail")
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            player.stop()
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            Image(systemName: log.category.systemImage)
                .font(.title2)
                .foregroundStyle(log.category.color)
            Text(log.category.displayName)
                .font(.headline)
                .foregroundStyle(log.category.color)
            Spacer()
            VStack(alignment: .trailing) {
                Text(log.timestamp.relativeDayDisplay)
                    .font(.subheadline)
                Text(log.timestamp.timeOnly)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Transcript

    private var transcriptSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Transcript")
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(log.transcript.isEmpty ? "No transcript available." : log.transcript)
                .font(.body)
        }
    }

    // MARK: - Audio Player

    private var audioPlayerSection: some View {
        VStack(spacing: 12) {
            ProgressView(value: player.duration > 0 ? player.currentTime : 0, total: max(player.duration, 1))

            HStack {
                Text(formatTime(player.currentTime))
                    .font(.caption)
                    .monospacedDigit()
                Spacer()
                Text(formatTime(player.duration))
                    .font(.caption)
                    .monospacedDigit()
            }
            .foregroundStyle(.secondary)

            Button {
                togglePlayback()
            } label: {
                Image(systemName: player.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .font(.system(size: 44))
            }
        }
        .padding()
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Metadata

    private var metadataSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let duration = log.durationSeconds {
                Label(formatTime(duration), systemImage: "clock")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            if let lat = log.latitude, let lon = log.longitude {
                Label(String(format: "%.4f, %.4f", lat, lon), systemImage: "location")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Delete

    private var deleteButton: some View {
        Button(role: .destructive) {
            deleteLog()
        } label: {
            Label("Delete Log", systemImage: "trash")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.bordered)
        .padding(.top, 8)
    }

    // MARK: - Actions

    private func togglePlayback() {
        guard let url = audioURL else { return }
        if player.isPlaying {
            player.pause()
        } else {
            try? player.play(url: url)
        }
    }

    private func deleteLog() {
        player.stop()
        if let fileName = log.audioFileName {
            let fileURL = AudioRecorderService.recordingsDirectory.appendingPathComponent(fileName)
            try? FileManager.default.removeItem(at: fileURL)
        }
        modelContext.delete(log)
        dismiss()
    }

    private func formatTime(_ seconds: Double) -> String {
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%d:%02d", mins, secs)
    }
}
