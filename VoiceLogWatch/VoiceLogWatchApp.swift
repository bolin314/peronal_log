import LogCore
import SwiftUI

@main
struct VoiceLogWatchApp: App {
    var body: some Scene {
        WindowGroup {
            WatchRecordingView()
        }
        .modelContainer(for: VoiceLog.self)
    }
}
