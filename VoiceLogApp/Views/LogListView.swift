import LogCore
import SwiftUI

struct LogListView: View {
    @Query(sort: \VoiceLog.timestamp, order: .reverse) private var logs: [VoiceLog]

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
                    List(logs) { log in
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
            }
            .navigationTitle("Voice Logs")
        }
    }
}

#Preview {
    LogListView()
        .modelContainer(for: VoiceLog.self, inMemory: true)
}
