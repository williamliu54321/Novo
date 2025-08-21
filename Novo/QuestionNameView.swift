//
//  QuestionNameView.swift
//  Novo
//
//  Created by William Liu on 2025-08-20.
//


//
//  OnboardingQuestionViews.swift
//  YourAppName
//
//  Created by William Liu on 2025-08-16.
//
//  This file consolidates all of the individual UI views used
//  during the multi-step onboarding process.
//

import SwiftUI

// MARK: - Step 1: Name

struct QuestionNameView: View {
    @EnvironmentObject var viewModel: OnboardingViewModel

    var body: some View {
        VStack(spacing: 20) {
            Text("What's your name?")
                .font(.largeTitle).fontWeight(.bold)
            
            TextField("Your Name", text: $viewModel.name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            NavigationLink("Next", value: OnboardingStep.goal)
                .buttonStyle(.borderedProminent)
                .disabled(!viewModel.isNameValid)
        }
        .padding()
        .navigationTitle("Step 1 of 5")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Step 2: Goal

struct QuestionGoalView: View {
    @EnvironmentObject var viewModel: OnboardingViewModel

    var body: some View {
        VStack(spacing: 30) {
            Text("What's your primary goal?")
                .font(.largeTitle).fontWeight(.bold).multilineTextAlignment(.center)
            
            Picker("Fitness Goal", selection: $viewModel.fitnessGoal) {
                ForEach(FitnessGoal.allCases) { goal in
                    Text(goal.rawValue).tag(goal)
                }
            }
            .pickerStyle(.wheel)
            .frame(height: 150)
            .padding(.horizontal)
            
            NavigationLink("Next", value: OnboardingStep.dateOfBirth)
                .buttonStyle(.borderedProminent)
        }
        .padding()
        .navigationTitle("Step 2 of 5")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Step 3: Date of Birth

struct QuestionDOBView: View {
    @EnvironmentObject var viewModel: OnboardingViewModel

    var body: some View {
        VStack(spacing: 20) {
            Text("When were you born?")
                .font(.largeTitle).fontWeight(.bold).multilineTextAlignment(.center)
            
            DatePicker("Birthdate", selection: $viewModel.dateOfBirth, in: ...Date(), displayedComponents: .date)
                .datePickerStyle(.graphical)
            
            if !viewModel.isOldEnough {
                Text("You must be at least 13 years old.")
                    .font(.caption).foregroundColor(.red)
            }
            
            NavigationLink("Next", value: OnboardingStep.activity)
                .buttonStyle(.borderedProminent)
                .disabled(!viewModel.isOldEnough)
        }
        .padding()
        .navigationTitle("Step 3 of 5")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Step 4: Activity Level

struct QuestionActivityView: View {
    @EnvironmentObject var viewModel: OnboardingViewModel

    var body: some View {
        VStack(spacing: 30) {
            VStack {
                Text("How would you describe your activity level?")
                    .font(.largeTitle).fontWeight(.bold).multilineTextAlignment(.center)
                Text("(Excluding intentional exercise)")
                    .font(.subheadline).foregroundColor(.secondary)
            }
            
            Picker("Activity Level", selection: $viewModel.activityLevel) {
                ForEach(ActivityLevel.allCases) { level in
                    Text(level.rawValue).tag(level)
                }
            }
            .pickerStyle(.wheel)
            .frame(height: 150)
            .padding(.horizontal)
            
            NavigationLink("Next", value: OnboardingStep.terms)
                .buttonStyle(.borderedProminent)
        }
        .padding()
        .navigationTitle("Step 4 of 5")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Step 5: Terms & Conditions

struct QuestionTermsView: View {
    @EnvironmentObject var viewModel: OnboardingViewModel
    // This `onComplete` closure is provided by the OnboardingFlowView coordinator
    var onComplete: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Last Step!")
                .font(.largeTitle).fontWeight(.bold)
            Text("Please review our terms and conditions before proceeding.")
                .font(.subheadline).foregroundColor(.secondary).multilineTextAlignment(.center)
            
            // In a real app, you would link to your terms and privacy policy here
            
            Toggle("I agree to the terms and conditions", isOn: $viewModel.hasAgreedToTerms)
            
            Button("Finish Setup") {
                onComplete()
            }
            .buttonStyle(.borderedProminent)
            .disabled(!viewModel.hasAgreedToTerms)
        }
        .padding()
        .navigationTitle("Step 5 of 5")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
    }
}
