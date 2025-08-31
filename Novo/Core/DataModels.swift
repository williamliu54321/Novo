import Foundation
import CoreData

extension UserProfile {
    var nextShotDate: Date {
        guard let lastShot = lastShotDate,
              let frequency = shotFrequency else {
            return Date()
        }
        return Calendar.current.date(byAdding: .day, value: Int(frequency), to: lastShot) ?? Date()
    }
    
    var daysUntilNextShot: Int {
        let days = Calendar.current.dateComponents([.day], from: Date(), to: nextShotDate).day ?? 0
        return max(0, days)
    }
    
    func calculateBMI() -> Double? {
        guard let weight = currentWeight?.doubleValue,
              let height = height?.doubleValue,
              height > 0 else { return nil }
        
        if useMetric {
            return weight / pow(height / 100, 2)
        } else {
            return (weight / pow(height, 2)) * 703
        }
    }
}

class DoseEntry: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var date: Date
    @NSManaged var dose: Double
    @NSManaged var injectionSite: String
    @NSManaged var painLevel: Int16
    @NSManaged var notes: String?
    @NSManaged var userProfile: UserProfile?
}

class WeightEntry: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var date: Date
    @NSManaged var weight: Double
    @NSManaged var userProfile: UserProfile?
}

class NutritionEntry: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var date: Date
    @NSManaged var calories: Int32
    @NSManaged var protein: Int32
    @NSManaged var carbs: Int32
    @NSManaged var fat: Int32
    @NSManaged var water: Int32
    @NSManaged var mealType: String?
    @NSManaged var mealDescription: String?
    @NSManaged var userProfile: UserProfile?
}

class SymptomEntry: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var date: Date
    @NSManaged var symptomType: String
    @NSManaged var severity: Int16
    @NSManaged var notes: String?
    @NSManaged var userProfile: UserProfile?
}

class ActivityEntry: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var date: Date
    @NSManaged var steps: Int32
    @NSManaged var exerciseMinutes: Int32
    @NSManaged var caloriesBurned: Int32
    @NSManaged var activityType: String?
    @NSManaged var userProfile: UserProfile?
}