import Foundation
import LogCore
import SwiftData
import WatchConnectivity

final class PhoneTransferService: NSObject, ObservableObject {

    static let shared = PhoneTransferService()

    private var modelContainer: ModelContainer?
    private var session: WCSession?

    private override init() {
        super.init()
    }

    func configure(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
    }

    func activate() {
        guard WCSession.isSupported() else { return }
        let session = WCSession.default
        session.delegate = self
        session.activate()
        self.session = session
    }
}

extension PhoneTransferService: WCSessionDelegate {

    func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        if let error {
            print("[PhoneTransfer] Activation error: \(error)")
        }
    }

    func sessionDidBecomeInactive(_ session: WCSession) {
        // no-op
    }

    func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }

    func session(_ session: WCSession, didReceive file: WCSessionFile) {
        guard let modelContainer else {
            print("[PhoneTransfer] ModelContainer not configured")
            return
        }

        guard let metadata = file.metadata else {
            print("[PhoneTransfer] No metadata in received file")
            return
        }

        do {
            let payload = try VoiceLogTransferPayload.from(metadata: metadata)

            let context = ModelContext(modelContainer)
            let existingID = payload.id
            var descriptor = FetchDescriptor<VoiceLog>(
                predicate: #Predicate { $0.id == existingID }
            )
            descriptor.fetchLimit = 1

            let existing = try context.fetch(descriptor)
            guard existing.isEmpty else {
                print("[PhoneTransfer] Duplicate log \(payload.id), skipping")
                return
            }

            let recordingsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                .appendingPathComponent("Recordings", isDirectory: true)
            try? FileManager.default.createDirectory(at: recordingsDir, withIntermediateDirectories: true)
            if let audioFileName = payload.audioFileName {
                let destURL = recordingsDir.appendingPathComponent(audioFileName)
                if !FileManager.default.fileExists(atPath: destURL.path) {
                    try FileManager.default.copyItem(at: file.fileURL, to: destURL)
                }
            }

            let voiceLog = payload.toVoiceLog()
            context.insert(voiceLog)
            try context.save()
        } catch {
            print("[PhoneTransfer] Failed to process received file: \(error)")
        }
    }
}
