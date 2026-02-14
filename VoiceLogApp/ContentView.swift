import LogCore
import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            LogListView()
                .tabItem {
                    Label("Logs", systemImage: "list.bullet")
                }

            RecordingView()
                .tabItem {
                    Label("Record", systemImage: "mic.fill")
                }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: VoiceLog.self, inMemory: true)
}
