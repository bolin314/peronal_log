import LogCore
import SwiftUI

struct RecordingView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Spacer()

                Image(systemName: "mic.circle.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.red)

                Text("Recording")
                    .font(.title2)

                Text("iOS recording coming soon.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Spacer()
            }
            .navigationTitle("Record")
        }
    }
}

#Preview {
    RecordingView()
}
