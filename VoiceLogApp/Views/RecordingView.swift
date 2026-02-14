import LogCore
import SwiftUI

struct RecordingView: View {
    @StateObject private var viewModel = RecordingViewModel()
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        NavigationStack {
            ZStack {
                switch viewModel.state {
                case .idle:
                    idleView
                case .recording:
                    recordingView
                case .selectingCategory:
                    categorySelectionView
                case .saving:
                    savingView
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .animation(.easeInOut(duration: 0.3), value: viewModel.state)
            .navigationTitle("Record")
        }
    }

    // MARK: - Idle

    private var idleView: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("Tap to record")
                .font(.title3)
                .foregroundStyle(.secondary)

            Button(action: viewModel.startRecording) {
                ZStack {
                    Circle()
                        .fill(.red)
                        .frame(width: 100, height: 100)
                        .shadow(color: .red.opacity(0.4), radius: 12, y: 4)

                    Image(systemName: "mic.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(.white)
                }
            }
            .buttonStyle(.plain)

            Spacer()
        }
    }

    // MARK: - Recording

    private var recordingView: some View {
        VStack(spacing: 32) {
            Spacer()

            ZStack {
                PulsingRingIOS(delay: 0.0)
                PulsingRingIOS(delay: 0.5)
                PulsingRingIOS(delay: 1.0)

                Circle()
                    .fill(.red.opacity(0.15))
                    .frame(width: 140, height: 140)

                Image(systemName: "mic.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(.red)
                    .symbolEffect(.pulse, options: .repeating)
            }

            Text(formattedDuration)
                .font(.system(size: 48, weight: .light, design: .monospaced))
                .foregroundStyle(.primary)
                .contentTransition(.numericText())

            Button { viewModel.stopRecording(context: modelContext) } label: {
                ZStack {
                    Circle()
                        .fill(.red)
                        .frame(width: 72, height: 72)

                    RoundedRectangle(cornerRadius: 6)
                        .fill(.white)
                        .frame(width: 28, height: 28)
                }
            }
            .buttonStyle(.plain)

            Text("Tap to stop")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Spacer()
        }
    }

    // MARK: - Category Selection

    private var categorySelectionView: some View {
        VStack(spacing: 24) {
            Spacer()

            VStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(.green)

                Text(formattedFinalDuration)
                    .font(.title3.monospacedDigit())
                    .foregroundStyle(.secondary)
            }

            VStack(spacing: 12) {
                Text("Choose a category")
                    .font(.headline)

                Text("Auto-saves as Log in 5 seconds")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(LogCategory.allCases, id: \.self) { category in
                    Button {
                        viewModel.selectCategory(category, context: modelContext)
                    } label: {
                        VStack(spacing: 8) {
                            Image(systemName: category.systemImage)
                                .font(.title2)
                            Text(category.displayName)
                                .font(.subheadline.weight(.medium))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background(category.color.opacity(0.15), in: RoundedRectangle(cornerRadius: 14))
                        .foregroundStyle(category.color)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 24)

            Spacer()
        }
    }

    // MARK: - Saving

    private var savingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .controlSize(.large)
            Text("Saving...")
                .font(.headline)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Helpers

    private var formattedDuration: String {
        let seconds = Int(viewModel.audioRecorder.elapsedSeconds)
        let mins = seconds / 60
        let secs = seconds % 60
        return String(format: "%d:%02d", mins, secs)
    }

    private var formattedFinalDuration: String {
        let seconds = Int(viewModel.elapsedSeconds)
        let mins = seconds / 60
        let secs = seconds % 60
        return String(format: "%d:%02d recorded", mins, secs)
    }
}

// MARK: - Pulsing Ring (iOS)

private struct PulsingRingIOS: View {
    let delay: Double

    @State private var animate = false

    var body: some View {
        Circle()
            .stroke(.red.opacity(0.25), lineWidth: 2.5)
            .frame(width: 140, height: 140)
            .scaleEffect(animate ? 2.0 : 1.0)
            .opacity(animate ? 0 : 0.8)
            .onAppear {
                withAnimation(
                    .easeOut(duration: 2.0)
                    .repeatForever(autoreverses: false)
                    .delay(delay)
                ) {
                    animate = true
                }
            }
    }
}

#Preview {
    RecordingView()
        .modelContainer(for: VoiceLog.self, inMemory: true)
}
