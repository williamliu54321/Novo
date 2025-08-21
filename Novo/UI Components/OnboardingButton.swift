//
//  OnboardingButton.swift
//  Novo
//
//  Created by William Liu on 2025-08-20.
//


import SwiftUI

struct OnboardingButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, minHeight: 44)
                .padding()
                .background(isSelected ? Color.black : Color(uiColor: .systemGray6))
                .foregroundColor(isSelected ? .primary : .primary) // Use .primary to ensure text is visible in both states
                .if(isSelected) { $0.foregroundColor(.white) } // Modifier to make text white only when selected
                .cornerRadius(12)
        }
    }
}

// Helper to conditionally apply modifiers
extension View {
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
