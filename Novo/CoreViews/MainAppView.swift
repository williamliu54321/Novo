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
                    
                    // --- Section 2: Body Metrics ---
                    Section(header: Text("Body Metrics")) {
                        ProfileRow(label: "Height", value: formatHeight(userProfile.height, useMetric: userProfile.useMetric))
                        
                        ProfileRow(label: "Current Weight", value: formatWeight(userProfile.currentWeight, useMetric: userProfile.useMetric))
                        
                        ProfileRow(label: "Dream Weight", value: formatWeight(userProfile.dreamWeight, useMetric: userProfile.useMetric))
                        
                        ProfileRow(label: "Unit System", value: (userProfile.useMetric ?? true) ? "Metric" : "Imperial")
                    }
                    
                    // --- Section 3: GLP-1 Journey Information ---
                    Section(header: Text("GLP-1 Journey")) {
                        ProfileRow(label: "Journey Status", value: userProfile.journeyStatus ?? "Not specified")
                        
                        // Show medication name or user-friendly text
                        ProfileRow(label: "Medication", value: userProfile.medication ?? "Not specified")
                        
                        // Show dose with "mg" suffix or user-friendly text
                        ProfileRow(label: "Dose", value: formatDose(userProfile.dose))
                        
                        // Show shot frequency
                        ProfileRow(label: "Shot Frequency", value: formatShotFrequency(userProfile.shotFrequency))
                        
                        // Show gender
                        ProfileRow(label: "Gender", value: userProfile.gender ?? "Not specified")
                    }
                    
                    // --- Section 4: Survey Results ---
                    Section(header: Text("Your Profile")) {
                        ProfileRow(label: "Fitness Goal", value: userProfile.fitnessGoal ?? "Not Provided")
                        ProfileRow(label: "Activity Level", value: userProfile.activityLevel ?? "Not Provided")
                    }
                    
                    // --- Section 5: Account Status ---
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
    
    // Helper function to format dose values
    private func formatDose(_ dose: NSNumber?) -> String {
        guard let dose = dose else { return "Not specified" }
        
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 3
        let doseString = formatter.string(from: NSNumber(value: dose.doubleValue)) ?? "\(dose.doubleValue)"
        return "\(doseString)mg"
    }
    
    // Helper function to format shot frequency values
    private func formatShotFrequency(_ frequency: NSNumber?) -> String {
        guard let frequency = frequency else { return "Not specified" }
        
        let days = frequency.intValue
        if days == 1 {
            return "Every day"
        } else {
            return "Every \(days) days"
        }
    }
    
    // Helper function to format height values
    private func formatHeight(_ height: NSNumber?, useMetric: Bool?) -> String {
        guard let height = height else { return "Not specified" }
        
        let heightValue = height.doubleValue
        let isMetric = useMetric ?? true
        
        if isMetric {
            return String(format: "%.0fcm", heightValue)
        } else {
            let totalInches = heightValue / 2.54 // Convert cm to inches
            let feet = Int(totalInches / 12)
            let inches = Int(totalInches.truncatingRemainder(dividingBy: 12))
            return "\(feet)'\(inches)\""
        }
    }
    
    // Helper function to format weight values
    private func formatWeight(_ weight: NSNumber?, useMetric: Bool?) -> String {
        guard let weight = weight else { return "Not specified" }
        
        let weightValue = weight.doubleValue
        let isMetric = useMetric ?? true
        
        if isMetric {
            return String(format: "%.1fkg", weightValue)
        } else {
            let weightInLbs = weightValue * 2.20462 // Convert kg to lbs
            return String(format: "%.1flbs", weightInLbs)
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
        previewProfile.journeyStatus = "I'm already on a GLP-1"
        previewProfile.medication = "Ozempic®"
        previewProfile.dose = NSNumber(value: 1.25)
        previewProfile.shotFrequency = NSNumber(value: 7)
        previewProfile.gender = "Female"
        previewProfile.height = NSNumber(value: 165.0) // 165cm
        previewProfile.currentWeight = NSNumber(value: 70.0) // 70kg
        previewProfile.dreamWeight = NSNumber(value: 65.0) // 65kg
        previewProfile.useMetric = true
        previewProfile.agreedToTerms = true
        previewProfile.onboardingCompletedDate = Date()
        
        return MainAppView()
            .environment(\.managedObjectContext, context)
    }
}
