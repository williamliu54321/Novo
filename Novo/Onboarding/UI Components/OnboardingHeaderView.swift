// MARK: - Reusable UI Components

import SwiftUI
// A reusable header with a back button and a progress bar.
struct OnboardingHeaderView: View {
    // We get the dismiss action from the environment to go back.
    @Environment(\.dismiss) private var dismiss
    
    // The current progress (a value between 0.0 and 1.0)
    let progress: Double

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                // The Back Button
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.title3.weight(.bold))
                        .foregroundColor(.primary)
                }
                Spacer()
            }
            
            // The Progress Bar
            ProgressView(value: progress)
                .progressViewStyle(.linear)
                .tint(.primary) // Makes the progress bar black
        }
        .padding(.horizontal)
    }
}
