import Foundation
import LogCore
import WatchConnectivity

final class WatchTransferService: NSObject, ObservableObject {

    static let shared = WatchTransferService()

    @Published var isActivated = false
    @Published var isPairedPhoneReachable = false
    @Published var pendingTransferCount = 0

    private var session: WCSession?

    private override init() {
        super.init()
    }

    func activate() {
        guard WCSession.isSupported() else { return }
        let session = WCSession.default
        session.delegate = self
        session.activate()
        self.session = session
    }

    func transferVoiceLog(_ voiceLog: VoiceLog) {
        guard let session, session.activationState == .activated else {
            print("[WatchTransfer] Session not activated, skipping transfer")
            return
        }

        guard let audioFileName = voiceLog.audioFileName else {
            print("[WatchTransfer] No audio file to transfer")
            return
        }

        let recordingsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Recordings", isDirectory: true)
        let audioURL = recordingsDir.appendingPathComponent(audioFileName)

        guard FileManager.default.fileExists(atPath: audioURL.path) else {
            print("[WatchTransfer] Audio file not found: \(audioURL.path)")
            return
        }

        do {
            let payload = VoiceLogTransferPayload(voiceLog: voiceLog)
            let metadata = try payload.toDictionary()
            session.transferFile(audioURL, metadata: metadata)
            pendingTransferCount = session.outstandingFileTransfers.count
        } catch {
            print("[WatchTransfer] Failed to encode payload: \(error)")
        }
    }
}

extension WatchTransferService: WCSessionDelegate {

    func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        DispatchQueue.main.async {
            self.isActivated = activationState == .activated
            if let error {
                print("[WatchTransfer] Activation error: \(error)")
            }
        }
    }

    #if os(watchOS)
    func sessionCompanionAppInstalledDidChange(_ session: WCSession) {
        // no-op — keep for protocol conformance
    }
    #endif

    func sessionReachabilityDidChange(_ session: WCSession) {
        DispatchQueue.main.async {
            self.isPairedPhoneReachable = session.isReachable
        }
    }

    func session(
        _ session: WCSession,
        didFinish fileTransfer: WCSessionFileTransfer,
        error: Error?
    ) {
        DispatchQueue.main.async {
            self.pendingTransferCount = session.outstandingFileTransfers.count
        }
        if let error {
            print("[WatchTransfer] File transfer failed: \(error)")
        }
    }
}
