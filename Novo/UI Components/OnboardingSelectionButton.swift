import SwiftUI

/// A reusable, styled button for the onboarding flow.
/// It can optionally display an SF Symbol icon to the left of the title.
/// This version is architected to be visually stable and animation-friendly.
struct OnboardingSelectionButton: View {
    
    // MARK: - Properties
    let iconName: String?
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    // MARK: - Initializer
    init(iconName: String? = nil, title: String, isSelected: Bool, action: @escaping () -> Void) {
        self.iconName = iconName
        self.title = title
        self.isSelected = isSelected
        self.action = action
    }

    // MARK: - Body
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                if let iconName = iconName {
                    Image(systemName: iconName)
                        .font(.title3)
                        .fontWeight(.semibold)
                }
                
                Text(title)
                    .font(.headline)
                    .fontWeight(.bold)
                
                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity, minHeight: 60)
            // The foreground color is now a simple modifier.
            .foregroundColor(isSelected ? .white : .primary)
            .background(isSelected ? Color.black : Color(uiColor: .systemGray6))
            .cornerRadius(12)
        }
        // Applying the buttonStyle here ensures the tap animation is correct.
        .buttonStyle(.plain)
        
        // --- THIS IS THE KEY TO FIXING THE ANIMATION ---
        // By explicitly telling the button to animate when its `isSelected`
        // state changes, we guarantee the animation will happen everywhere.
        .animation(.easeInOut(duration: 0.1), value: isSelected)
    }
}


// MARK: - Preview
struct OnboardingSelectionButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            // Preview for a button WITH an icon
            OnboardingSelectionButton(
                iconName: "play.fill",
                title: "I'm about to start a GLP-1",
                isSelected: true,
                action: {}
            )
            
            // Preview for a button WITHOUT an icon
            OnboardingSelectionButton(
                title: "Wegovy®",
                isSelected: false,
                action: {}
            )
        }
        .padding()
    }
}
