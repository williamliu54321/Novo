// RootView.swift
import SwiftUI
import SuperwallKit

struct RootView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    var body: some View {
        if hasCompletedOnboarding {
            MainAppView()
        } else {
            OnboardingFlowView {
                // When onboarding completes, call your Superwall placement.
                // In the dashboard, set the paywall used by "onboarding_complete"
                // to Feature Gating: Gated. Then this closure will run ONLY on
                // successful purchase or restore.
                Superwall.shared.register(placement: "campaign_trigger") {
                    // ⬇️ Fires after purchase/restore; move user into the app.
                    hasCompletedOnboarding = true
                }
            }
        }
    }
}

