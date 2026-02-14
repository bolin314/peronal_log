import LogCore
import SwiftUI

@main
struct VoiceLogWatchApp: App {
    private let transferService = WatchTransferService.shared

    init() {
        transferService.activate()
    }

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
