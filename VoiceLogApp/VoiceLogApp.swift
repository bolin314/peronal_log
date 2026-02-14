import LogCore
import SwiftData
import SwiftUI

@main
struct VoiceLogApp: App {
    private let modelContainer: ModelContainer
    private let transferService = PhoneTransferService.shared

    init() {
        do {
            modelContainer = try ModelContainer(for: VoiceLog.self)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
        transferService.configure(modelContainer: modelContainer)
        transferService.activate()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(modelContainer)
    }
}
