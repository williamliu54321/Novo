//
//  OnboardingJourneyStartView.swift
//  Novo
//
//  Created by William Liu on 2025-08-20.
//
import SwiftUI

struct OnboardingJourneyStartView: View {
    @EnvironmentObject var viewModel: OnboardingViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Use our new reusable header
            // --- ADD THIS HEADER ---
            // We pass the progress for this step (e.g., 10% done).
            OnboardingHeaderView(progress: 0.1)

            // Main content
            VStack(alignment: .leading, spacing: 16) {
                Text("Ready to feel like you again?")
                    .font(.largeTitle).bold()
                    .padding(.top)
                
                Text("Where are you with your GLP-1 journey?")
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal)

            Spacer()
            
            // The two selection buttons
            VStack(spacing: 12) {
                OnboardingSelectionButton(
                    iconName: "sparkles",
                    title: "I'm already on a GLP-1",
                    isSelected: viewModel.journeyStatus == "current"
                ) {
                    viewModel.journeyStatus = "current"
                }
                
                OnboardingSelectionButton(
                    iconName: "play.fill",
                    title: "I'm about to start a GLP-1",
                    isSelected: viewModel.journeyStatus == "starting"
                ) {
                    viewModel.journeyStatus = "starting"
                }
            }
            .padding(.horizontal)

            Spacer()
            
            // The continue button
            NavigationLink(value: OnboardingStep.medication) {
                Text("Continue")
                    .font(.headline).fontWeight(.bold)
                    .frame(maxWidth: .infinity, minHeight: 44)
                    .padding()
                    .background(viewModel.journeyStatus == nil ? Color(uiColor: .systemGray3) : Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(16)
            }
            .disabled(viewModel.journeyStatus == nil)
            .padding([.horizontal, .bottom])
        }
        .navigationBarBackButtonHidden() // Hide the default back button
    }
}
