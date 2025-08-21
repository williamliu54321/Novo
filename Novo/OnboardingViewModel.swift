//
//  FitnessGoal.swift
//  Testing
//
//  Created by William Liu on 2025-08-16.
//


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


    @Published var name: String = ""
    @Published var fitnessGoal: FitnessGoal = .loseWeight
    @Published var dateOfBirth: Date = Calendar.current.date(byAdding: .year, value: -20, to: .now) ?? Date()
    @Published var activityLevel: ActivityLevel = .sedentary
    @Published var hasAgreedToTerms: Bool = false
    
    // MARK: - Validation Logic
    // The view can use these to enable/disable navigation
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
        newUserProfile.onboardingCompletedDate = Date()
        
        do {
            try context.save()
            print("User Profile Saved Successfully!")
        } catch {
            // In a real app, you should handle this error gracefully.
            // For example, by publishing an error state and showing an alert.
            print("Failed to save user profile: \(error.localizedDescription)")
        }
    }
}
