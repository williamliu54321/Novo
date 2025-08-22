//
//  RootView.swift
//  Novo
//
//  Created by William Liu on 2025-08-20.
//


import SwiftUI
import Superwall // <-- Import Superwall

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
                self.hasCompletedOnboarding = true
            }
        }
    }
}
