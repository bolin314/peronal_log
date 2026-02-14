import LogCore
import SwiftUI

struct LogListView: View {
    @Query(sort: \VoiceLog.timestamp, order: .reverse) private var logs: [VoiceLog]
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        NavigationStack {
            Group {
                if logs.isEmpty {
                    ContentUnavailableView(
                        "No Logs Yet",
                        systemImage: "mic.slash",
                        description: Text("Record your first voice log to get started.")
                    )
                } else {
                    List {
                        ForEach(logs) { log in
                            NavigationLink(destination: LogDetailView(log: log)) {
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        Image(systemName: log.category.systemImage)
                                            .foregroundStyle(log.category.color)
                                        Text(log.category.displayName)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                        Spacer()
                                        Text(log.timestamp.shortDisplay)
                                            .font(.caption2)
                                            .foregroundStyle(.tertiary)
                                    }

                                    Text(log.transcript.isEmpty ? "Transcribing..." : log.transcript)
                                        .font(.body)
                                        .lineLimit(3)
                                }
                                .padding(.vertical, 4)
                            }
                        }
                        .onDelete(perform: deleteLogs)
                    }
                }
            }
            .navigationTitle("Voice Logs")
        }
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

#Preview {
    LogListView()
        .modelContainer(for: VoiceLog.self, inMemory: true)
}
