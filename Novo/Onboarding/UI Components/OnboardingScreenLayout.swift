//
//  OnboardingScreenLayout.swift
//  Novo
//
//  Created by William Liu on 2025-08-20.
//


import SwiftUI

struct OnboardingScreenLayout<Content: View, Action: View>: View {
    
    // MARK: - Properties
    let progress: Double
    let title: String
    let subtitle: String?
    
    // Using @ViewBuilder allows us to pass in multiple views for the content
    // and action areas using natural closure syntax.
    @ViewBuilder let content: Content
    @ViewBuilder let action: Action

    // MARK: - Initializer
    init(progress: Double, title: String, subtitle: String? = nil, @ViewBuilder content: () -> Content, @ViewBuilder action: () -> Action) {
        self.progress = progress
        self.title = title
        self.subtitle = subtitle
        self.content = content()
        self.action = action()
    }

    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 1. Reusable Header (Progress Bar & Back Button)
            OnboardingHeaderView(progress: progress)

            // 2. Title Area
            VStack(alignment: .leading, spacing: 16) {
                Text(title)
                    .font(.largeTitle).bold()
                    .padding(.top)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal)

            Spacer()
            
            // 3. Custom Content Area (This is where your unique buttons/pickers go)
            content
                .padding(.horizontal)

            Spacer()
            
            // 4. Custom Action Area (This is where the "Continue" button goes)
            action
                .padding([.horizontal, .bottom])
        }
        .navigationBarBackButtonHidden()
    }
}
