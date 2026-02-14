import LogCore
import SwiftUI

@main
struct VoiceLogWatchApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                List {
                    NavigationLink("Voice Logs") {
                        WatchLogListView()
                    }
                    NavigationLink("Record") {
                        WatchRecordingView()
                    }
                }
                .navigationTitle("VoiceLog")
            }
        }
        .modelContainer(for: VoiceLog.self)
    }
}
