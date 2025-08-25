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
    @Published var shotFrequency: Int? // Number of days between shots
    @Published var gender: String?
    @Published var currentWeight: Double? // Stored in kg
    @Published var dreamWeight: Double? // Stored in kg  
    @Published var height: Double? // Stored in cm
    @Published var useMetric: Bool = {
        if #available(iOS 16.0, *) {
            return Locale.current.measurementSystem == .metric
        } else {
            return Locale.current.usesMetricSystem
        }
    }()
    @Published var weeklyWeightGoal: Double? // Stored in kg per week
    @Published var toughestDay: String? // Day when cravings hit hardest
    @Published var primarySideEffectConcern: String? // Primary side effect concern
    @Published var sideEffectsConcerns: [String]? // Multiple side effects concerns
    @Published var motivation: String? // User's motivation for reaching their goal

    @Published var name: String = ""
    @Published var fitnessGoal: FitnessGoal = .loseWeight
    @Published var dateOfBirth: Date = Calendar.current.date(byAdding: .year, value: -20, to: .now) ?? Date()
    @Published var activityLevel: ActivityLevel = .sedentary
    @Published var activityLevelString: String? {
        didSet {
            // Convert string selection to ActivityLevel enum
            if let stringValue = activityLevelString {
                let activityMapping: [String: ActivityLevel] = [
                    "Sedentary (mostly inactive, little exercise)": .sedentary,
                    "Lightly Active (light daily activity and movement)": .light,
                    "Active (regular workouts or physical labor)": .moderate,
                    "Very Active (intense exercise or very physical job)": .very
                ]
                activityLevel = activityMapping[stringValue] ?? .sedentary
            }
        }
    }
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
        newUserProfile.gender = self.gender
        newUserProfile.useMetric = self.useMetric
        newUserProfile.onboardingCompletedDate = Date()
        
        // Save weight and height data (stored in metric units)
        if let currentWeight = self.currentWeight {
            newUserProfile.currentWeight = NSNumber(value: currentWeight)
        }
        if let dreamWeight = self.dreamWeight {
            newUserProfile.dreamWeight = NSNumber(value: dreamWeight)
        }
        if let height = self.height {
            newUserProfile.height = NSNumber(value: height)
        }
        
        // Save medication - nil if "I haven't decided" is selected
        if let medication = self.medication, medication != "I haven't decided" {
            newUserProfile.medication = medication
        } else {
            newUserProfile.medication = nil
        }
        
        // Save shot frequency - nil if "Not sure" is selected
        if let frequency = self.shotFrequency, frequency > 0 {
            newUserProfile.shotFrequency = NSNumber(value: frequency)
        } else {
            newUserProfile.shotFrequency = nil
        }
        
        // --- 2. ADD THE SAVING LOGIC FOR THE DOSE ---
        // Save dose - nil if "Not sure yet" (-1.0) is selected
        if let dose = self.dose, dose != -1.0 {
            newUserProfile.dose = NSNumber(value: dose)
        } else {
            newUserProfile.dose = nil
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
