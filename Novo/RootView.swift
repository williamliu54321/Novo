//
//  RootView.swift
//  Novo
//
//  Created by William Liu on 2025-08-20.
//


import SwiftUI

// This is your main routing view. It decides what the user sees upon launch.
struct RootView: View {
    // @AppStorage is a property wrapper that reads and writes from UserDefaults.
    // It's the perfect tool for persisting simple state like a "first launch" flag.
    // We give it a unique key and a default value of `false`.
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false

    var body: some View {
        // The core logic of the router:
        // If the user has completed onboarding, show the main app.
        if hasCompletedOnboarding {
            MainAppView()
        } else {
            // Otherwise, show the onboarding flow.
            // We provide the `onComplete` callback here. This is the code
            // that will be executed when the OnboardingFlowView says it's done.
            OnboardingFlowView {
                // When the onboarding flow completes, we set our persistent
                // flag to true. This will cause this ContentView to re-render
                // and the `if` condition will now be true, showing MainAppView.
                self.hasCompletedOnboarding = true
            }
        }
    }
}
