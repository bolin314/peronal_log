import LogCore
import SwiftUI

struct WatchRecordingView: View {
    @StateObject private var viewModel = WatchRecordingViewModel()
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        ZStack {
            switch viewModel.state {
            case .idle:
                recordButton
            case .recording:
                recordingView
            case .selectingCategory:
                categoryGrid
            case .saving:
                ProgressView("Saving...")
            }
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.state)
    }

    // MARK: - Record Button

    private var recordButton: some View {
        Button(action: viewModel.startRecording) {
            ZStack {
                PulsingRing(delay: 0.0)
                PulsingRing(delay: 0.4)
                PulsingRing(delay: 0.8)

                Circle()
                    .fill(.red)
                    .frame(width: 60, height: 60)
                    .overlay {
                        Image(systemName: "mic.fill")
                            .font(.title2)
                            .foregroundStyle(.white)
                    }
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Recording View

    private var recordingView: some View {
        VStack(spacing: 12) {
            Text(formattedDuration)
                .font(.title3.monospacedDigit())
                .foregroundStyle(.red)

            Button { viewModel.stopRecording(context: modelContext) } label: {
                Circle()
                    .fill(.red)
                    .frame(width: 60, height: 60)
                    .overlay {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(.white)
                            .frame(width: 22, height: 22)
                    }
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Category Grid

    private var categoryGrid: some View {
        VStack(spacing: 6) {
            Text("Category")
                .font(.caption2)
                .foregroundStyle(.secondary)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 6) {
                ForEach(LogCategory.allCases, id: \.self) { category in
                    Button {
                        viewModel.selectCategory(category, context: modelContext)
                    } label: {
                        VStack(spacing: 2) {
                            Image(systemName: category.systemImage)
                                .font(.body)
                            Text(category.displayName)
                                .font(.caption2)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(category.color.opacity(0.25), in: RoundedRectangle(cornerRadius: 8))
                        .foregroundStyle(category.color)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Helpers

    private var formattedDuration: String {
        let seconds = Int(viewModel.audioRecorder.elapsedSeconds)
        let mins = seconds / 60
        let secs = seconds % 60
        return String(format: "%d:%02d", mins, secs)
    }
}

// MARK: - Pulsing Ring

struct PulsingRing: View {
    let delay: Double

    @State private var animate = false

    var body: some View {
        Circle()
            .stroke(.red.opacity(0.3), lineWidth: 2)
            .frame(width: 80, height: 80)
            .scaleEffect(animate ? 1.6 : 1.0)
            .opacity(animate ? 0 : 1)
            .onAppear {
                withAnimation(
                    .easeOut(duration: 1.8)
                    .repeatForever(autoreverses: false)
                    .delay(delay)
                ) {
                    animate = true
                }
            }
    }
}

#Preview {
    WatchRecordingView()
        .modelContainer(for: VoiceLog.self, inMemory: true)
}
