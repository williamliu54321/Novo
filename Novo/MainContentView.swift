import SwiftUI
import CoreData

struct MainContentView: View {
    @State private var showOnboarding = false
    @State private var showPaywall = false
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \UserProfile.onboardingCompletedDate, ascending: false)],
        animation: .default)
    private var userProfiles: FetchedResults<UserProfile>
    
    var hasCompletedOnboarding: Bool {
        userProfiles.first?.onboardingCompletedDate != nil
    }
    
    var body: some View {
        Group {
            if !hasCompletedOnboarding {
                OnboardingFlowView {
                    // After onboarding completion, show paywall
                    showPaywall = true
                }
            } else {
                // Main app after onboarding and paywall
                MainTabView()
            }
        }
        .onAppear {
            checkOnboardingStatus()
        }
        .sheet(isPresented: $showPaywall) {
            // This is where your Superwall paywall would be shown
            PaywallPlaceholderView {
                // After successful subscription or dismissal
                showPaywall = false
            }
        }
    }
    
    private func checkOnboardingStatus() {
        // Check if onboarding has been completed
        if userProfiles.isEmpty {
            showOnboarding = true
        }
    }
}

// Placeholder for Superwall paywall
struct PaywallPlaceholderView: View {
    let onDismiss: () -> Void
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Spacer()
                
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.purple)
                
                Text("Unlock Premium")
                    .font(.largeTitle)
                    .bold()
                
                Text("This is where your Superwall paywall will appear")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 16) {
                    FeatureRow(icon: "chart.line.uptrend.xyaxis", text: "Advanced Analytics")
                    FeatureRow(icon: "bell.badge", text: "Smart Reminders")
                    FeatureRow(icon: "person.2", text: "Community Access")
                    FeatureRow(icon: "sparkles", text: "AI Insights")
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(16)
                .padding(.horizontal)
                
                Spacer()
                
                Button {
                    onDismiss()
                } label: {
                    Text("Continue to App")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.purple)
                        .foregroundColor(.white)
                        .cornerRadius(16)
                }
                .padding(.horizontal)
                
                Button {
                    onDismiss()
                } label: {
                    Text("Maybe Later")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.bottom)
            }
            .navigationBarHidden(true)
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.purple)
                .frame(width: 30)
            
            Text(text)
                .font(.subheadline)
            
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
        }
    }
}

struct MainContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainContentView()
    }
}