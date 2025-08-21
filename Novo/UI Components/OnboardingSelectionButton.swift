//
//  OnboardingSelectionButton.swift
//  Novo
//
//  Created by William Liu on 2025-08-20.
//

import SwiftUI

/// A reusable component for the main selection buttons in the onboarding flow.
/// It displays a title and can optionally display an SF Symbol icon to the left.
struct OnboardingSelectionButton: View {
    
    // MARK: - Properties
    
    /// The name of the SF Symbol to display. This is now optional.
    let iconName: String?
    
    /// The text to display on the button.
    let title: String
    
    /// A boolean that determines if the button is in its "selected" state.
    let isSelected: Bool
    
    /// The action to perform when the button is tapped.
    let action: () -> Void

    // MARK: - Initializer
    
    // We create a custom initializer. This is a best practice for complex views.
    // It allows us to make `iconName` optional with a default value of `nil`.
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
                
                // --- THIS IS THE KEY CHANGE ---
                // This `if let` block checks if an iconName was provided.
                // The Image view will only be created if iconName is not nil.
                if let iconName = iconName {
                    Image(systemName: iconName)
                        .font(.title3)
                        .fontWeight(.semibold)
                }
                
                Text(title)
                    .font(.headline)
                    .fontWeight(.bold)
                
                Spacer() // Pushes the content to the left
            }
            .padding()
            .frame(maxWidth: .infinity, minHeight: 60)
            .background(isSelected ? Color.black : Color(uiColor: .systemGray6))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(12)
        }
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
