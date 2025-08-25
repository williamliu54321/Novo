//
//  OnboardingContinueButton.swift
//  Novo
//
//  Standardized Continue button for onboarding flow
//

import SwiftUI

struct OnboardingContinueButton: View {
    let title: String
    let action: () -> Void
    
    init(_ title: String = "Continue", action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.black)
                .foregroundColor(.white)
                .cornerRadius(12)
        }
        .padding(.horizontal)
        .padding(.bottom)
    }
}