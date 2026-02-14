import CoreLocation
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
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                gpsIndicator
            }
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.state)
        .onAppear {
            viewModel.locationService.requestPermission()
        }
    }

    // MARK: - GPS Indicator

    private var gpsIndicator: some View {
        let authorized = viewModel.locationService.authorizationStatus == .authorizedWhenInUse
            || viewModel.locationService.authorizationStatus == .authorizedAlways
        return Image(systemName: "location.fill")
            .font(.caption)
            .foregroundStyle(authorized ? .green : .gray)
    }

    // MARK: - Record Button

    private var recordButton: some View {
        Button(action: viewModel.startRecording) {
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.4), lineWidth: 2)
                    .frame(width: 70, height: 70)
                Circle()
                    .fill(.red)
                    .frame(width: 60, height: 60)
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Recording View

    private var recordingView: some View {
        VStack(spacing: 12) {
            Button { viewModel.stopRecording(context: modelContext) } label: {
                Circle()
                    .fill(.red)
                    .frame(width: 60, height: 60)
            }
            .buttonStyle(.plain)

            Text(formattedDuration)
                .font(.title3.monospacedDigit())
                .foregroundStyle(.red)
        }
    }

    // MARK: - Category Grid

    private var categoryGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 6) {
            ForEach(LogCategory.allCases, id: \.self) { category in
                Button {
                    viewModel.selectCategory(category, context: modelContext)
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: category.systemImage)
                            .font(.title2)
                            .foregroundStyle(.white)
                        Text(category.displayName)
                            .font(.caption2)
                            .foregroundStyle(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(category.color, in: RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal)
    }

    // MARK: - Helpers

    private var formattedDuration: String {
        let seconds = Int(viewModel.audioRecorder.elapsedSeconds)
        let mins = seconds / 60
        let secs = seconds % 60
        return String(format: "%02d:%02d", mins, secs)
    }
}

#Preview {
    WatchRecordingView()
        .modelContainer(for: VoiceLog.self, inMemory: true)
}
