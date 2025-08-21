//
//  MainAppView.swift
//  Testing
//
//  Created by William Liu on 2025-08-16.
//
import SwiftUI

struct MainAppView: View {
    @Environment(\.managedObjectContext) private var viewContext

    // This fetch request finds the UserProfile object that was saved.
    // We add a sort descriptor to ensure we get a consistent result.
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \UserProfile.onboardingCompletedDate, ascending: true)],
        animation: .default)
    private var profiles: FetchedResults<UserProfile>

    var body: some View {
        NavigationView {
            // Safely unwrap the fetched profile. In a single-user app,
            // we can expect one to exist after onboarding is complete.
            if let userProfile = profiles.first {
                
                // A Form provides a clean, standard iOS list format for settings or profiles.
                Form {
                    // --- Section 1: Personal Details ---
                    Section(header: Text("Personal Details")) {
                        ProfileRow(label: "Name", value: userProfile.name ?? "Not Provided")
                        
                        // Use a formatter to display the Date object in a friendly way.
                        ProfileRow(label: "Date of Birth", value: userProfile.dateOfBirth?.formatted(date: .long, time: .omitted) ?? "Not Provided")
                    }
                    
                    // --- Section 2: Survey Results ---
                    Section(header: Text("Your Profile")) {
                        ProfileRow(label: "Fitness Goal", value: userProfile.fitnessGoal ?? "Not Provided")
                        ProfileRow(label: "Activity Level", value: userProfile.activityLevel ?? "Not Provided")
                    }
                    
                    // --- Section 3: Account Status ---
                    Section(header: Text("Account")) {
                        // Use a ternary operator to convert the Boolean to a user-friendly string.
                        ProfileRow(label: "Agreed to Terms", value: userProfile.agreedToTerms ? "Yes" : "No")
                        
                        ProfileRow(label: "Onboarding Complete", value: userProfile.onboardingCompletedDate?.formatted(date: .numeric, time: .shortened) ?? "N/A")
                    }
                }
                .navigationTitle("Welcome, \(userProfile.name ?? "User")!")
                
            } else {
                // This is a fallback view, shown if the profile hasn't loaded yet.
                VStack {
                    Text("Loading Your Profile...")
                    ProgressView()
                }
                .navigationTitle("Dashboard")
            }
        }
    }
}

// MARK: - Reusable Helper View

/// A small, reusable view to keep the main Form clean and consistent.
private struct ProfileRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
            Spacer()
            Text(value)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.trailing)
        }
    }
}

// MARK: - SwiftUI Preview

struct MainAppView_Previews: PreviewProvider {
    static var previews: some View {
        // This code sets up a temporary, in-memory Core Data store
        // so you can preview this view without running the full app.
        let controller = PersistenceController(inMemory: true)
        let context = controller.container.viewContext
        
        // Create a fake UserProfile to display in the preview.
        let previewProfile = UserProfile(context: context)
        previewProfile.id = UUID()
        previewProfile.name = "Jane Appleseed"
        previewProfile.dateOfBirth = Calendar.current.date(from: .init(year: 1992, month: 10, day: 23))
        previewProfile.fitnessGoal = "Gain Muscle"
        previewProfile.activityLevel = "Moderately Active"
        previewProfile.agreedToTerms = true
        previewProfile.onboardingCompletedDate = Date()
        
        return MainAppView()
            .environment(\.managedObjectContext, context)
    }
}
