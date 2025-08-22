//
//  OnboardingStep.swift
//  Novo
//
//  Created by William Liu on 2025-08-21.
//


import Foundation

// Define the discrete steps of our flow in its own file
// so it can be accessed by any view in the app.
enum OnboardingStep: Hashable {
    case journeyStart
    case name, goal, dateOfBirth, activity, terms
    case medication, dose
}