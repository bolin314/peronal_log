import LogCore
import SwiftUI

@main
struct VoiceLogApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: VoiceLog.self)
    }
}
