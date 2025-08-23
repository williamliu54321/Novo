// In OnboardingViewModel.swift

import Foundation
import CoreData

// Enums for type-safe, clear options
enum FitnessGoal: String, CaseIterable, Identifiable {
    case loseWeight = "Lose Weight"
    case maintainWeight = "Maintain Weight"
    case gainMuscle = "Gain Muscle"
    var id: Self { self }
}

enum ActivityLevel: String, CaseIterable, Identifiable {
    case sedentary = "Sedentary"
    case light = "Lightly Active"
    case moderate = "Moderately Active"
    case very = "Very Active"
    var id: Self { self }
}

// The ViewModel: Brains of the operation
@MainActor // Ensure all UI updates happen on the main thread
class OnboardingViewModel: ObservableObject {
    
    @Published var journeyStatus: String?
    @Published var medication: String?
    @Published var dose: Double? // <-- 1. ADD THE DOSE PROPERTY (as a Double)

    @Published var name: String = ""
    @Published var fitnessGoal: FitnessGoal = .loseWeight
    @Published var dateOfBirth: Date = Calendar.current.date(byAdding: .year, value: -20, to: .now) ?? Date()
    @Published var activityLevel: ActivityLevel = .sedentary
    @Published var hasAgreedToTerms: Bool = false
    
    // MARK: - Validation Logic
    var isNameValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    var isOldEnough: Bool {
        let age = Calendar.current.dateComponents([.year], from: dateOfBirth, to: .now).year ?? 0
        return age >= 13
    }
    
    // MARK: - Saving Logic
    func saveUserProfile(in context: NSManagedObjectContext) {
        let newUserProfile = UserProfile(context: context)
        newUserProfile.id = UUID()
        newUserProfile.name = self.name
        newUserProfile.fitnessGoal = self.fitnessGoal.rawValue
        newUserProfile.dateOfBirth = self.dateOfBirth
        newUserProfile.activityLevel = self.activityLevel.rawValue
        newUserProfile.agreedToTerms = self.hasAgreedToTerms
        newUserProfile.journeyStatus = self.journeyStatus
        newUserProfile.onboardingCompletedDate = Date()
        
        // --- 2. ADD THE SAVING LOGIC FOR THE DOSE ---
        // Safely unwrap the optional Double and assign it.
        if let dose = self.dose {
            newUserProfile.dose = dose
        }
        
        do {
            try context.save()
            print("User Profile Saved Successfully!")
        } catch {
            // In a real app, you should handle this error gracefully.
            print("Failed to save user profile: \(error.localizedDescription)")
        }
    }
}
