import LogCore
import SwiftUI

struct WatchLogListView: View {
    @Query(sort: \VoiceLog.timestamp, order: .reverse) private var logs: [VoiceLog]
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        Group {
            if logs.isEmpty {
                Text("No logs yet.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                List {
                    ForEach(logs) { log in
                        NavigationLink(destination: WatchLogDetailView(log: log)) {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Image(systemName: log.category.systemImage)
                                        .foregroundStyle(log.category.color)
                                    Text(log.timestamp.timeOnly)
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                                Text(log.transcript.isEmpty ? "Transcribing..." : log.transcript)
                                    .font(.caption)
                                    .lineLimit(2)
                            }
                        }
                    }
                    .onDelete(perform: deleteLogs)
                }
            }
        }
        .navigationTitle("Voice Logs")
    }

    private func deleteLogs(at offsets: IndexSet) {
        for index in offsets {
            let log = logs[index]
            if let fileName = log.audioFileName {
                let fileURL = AudioRecorderService.recordingsDirectory.appendingPathComponent(fileName)
                try? FileManager.default.removeItem(at: fileURL)
            }
            modelContext.delete(log)
        }
    }
}
