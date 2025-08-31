import Foundation
import CoreData
import SwiftUI

// MARK: - Core Data Extensions

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

// MARK: - Data Models

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

// MARK: - Data Manager

class DataManager: ObservableObject {
    static let shared = DataManager()
    
    private let container: NSPersistentContainer
    private let viewContext: NSManagedObjectContext
    
    @Published var currentUserProfile: UserProfile?
    @Published var todayWeight: Double?
    @Published var todayCalories: Int = 0
    @Published var todayProtein: Int = 0
    @Published var todayWater: Int = 0
    @Published var todaySteps: Int = 0
    @Published var currentStreak: Int = 0
    @Published var weeklyWeightChange: Double = 0
    @Published var totalWeightChange: Double = 0
    
    init() {
        self.container = PersistenceController.shared.container
        self.viewContext = container.viewContext
        loadUserProfile()
        refreshTodayStats()
    }
    
    func loadUserProfile() {
        let request: NSFetchRequest<UserProfile> = UserProfile.fetchRequest()
        request.fetchLimit = 1
        
        do {
            let profiles = try viewContext.fetch(request)
            currentUserProfile = profiles.first
        } catch {
            print("Error loading user profile: \(error)")
        }
    }
    
    func refreshTodayStats() {
        let today = Calendar.current.startOfDay(for: Date())
        
        todayWeight = fetchTodayWeight()
        
        let nutrition = fetchTodayNutrition()
        todayCalories = nutrition.calories
        todayProtein = nutrition.protein
        todayWater = nutrition.water
        
        todaySteps = fetchTodaySteps()
        currentStreak = calculateStreak()
        weeklyWeightChange = calculateWeeklyWeightChange()
        totalWeightChange = calculateTotalWeightChange()
    }
    
    private func fetchTodayWeight() -> Double? {
        let request: NSFetchRequest<WeightEntry> = WeightEntry.fetchRequest()
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        
        request.predicate = NSPredicate(format: "date >= %@ AND date < %@", today as NSDate, tomorrow as NSDate)
        request.fetchLimit = 1
        request.sortDescriptors = [NSSortDescriptor(keyPath: \WeightEntry.date, ascending: false)]
        
        do {
            let entries = try viewContext.fetch(request)
            return entries.first?.weight
        } catch {
            print("Error fetching today's weight: \(error)")
            return nil
        }
    }
    
    private func fetchTodayNutrition() -> (calories: Int, protein: Int, water: Int) {
        let request: NSFetchRequest<NutritionEntry> = NutritionEntry.fetchRequest()
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        
        request.predicate = NSPredicate(format: "date >= %@ AND date < %@", today as NSDate, tomorrow as NSDate)
        
        do {
            let entries = try viewContext.fetch(request)
            let totalCalories = entries.reduce(0) { $0 + Int($1.calories) }
            let totalProtein = entries.reduce(0) { $0 + Int($1.protein) }
            let totalWater = entries.reduce(0) { $0 + Int($1.water) }
            return (totalCalories, totalProtein, totalWater)
        } catch {
            print("Error fetching today's nutrition: \(error)")
            return (0, 0, 0)
        }
    }
    
    private func fetchTodaySteps() -> Int {
        let request: NSFetchRequest<ActivityEntry> = ActivityEntry.fetchRequest()
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        
        request.predicate = NSPredicate(format: "date >= %@ AND date < %@", today as NSDate, tomorrow as NSDate)
        
        do {
            let entries = try viewContext.fetch(request)
            return entries.reduce(0) { $0 + Int($1.steps) }
        } catch {
            print("Error fetching today's steps: \(error)")
            return 0
        }
    }
    
    private func calculateStreak() -> Int {
        guard let profile = currentUserProfile else { return 0 }
        
        let request: NSFetchRequest<DoseEntry> = DoseEntry.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \DoseEntry.date, ascending: false)]
        request.predicate = NSPredicate(format: "userProfile == %@", profile)
        
        do {
            let doses = try viewContext.fetch(request)
            guard !doses.isEmpty else { return 0 }
            
            var streak = 1
            var lastDate = Calendar.current.startOfDay(for: doses[0].date)
            let frequency = Int(profile.shotFrequency?.int32Value ?? 7)
            
            for i in 1..<doses.count {
                let currentDate = Calendar.current.startOfDay(for: doses[i].date)
                let daysBetween = Calendar.current.dateComponents([.day], from: currentDate, to: lastDate).day ?? 0
                
                if daysBetween <= frequency + 1 {
                    streak += 1
                    lastDate = currentDate
                } else {
                    break
                }
            }
            
            return streak
        } catch {
            print("Error calculating streak: \(error)")
            return 0
        }
    }
    
    private func calculateWeeklyWeightChange() -> Double {
        let request: NSFetchRequest<WeightEntry> = WeightEntry.fetchRequest()
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        
        request.predicate = NSPredicate(format: "date >= %@", weekAgo as NSDate)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \WeightEntry.date, ascending: true)]
        
        do {
            let entries = try viewContext.fetch(request)
            guard let first = entries.first, let last = entries.last else { return 0 }
            return last.weight - first.weight
        } catch {
            print("Error calculating weekly change: \(error)")
            return 0
        }
    }
    
    private func calculateTotalWeightChange() -> Double {
        guard let startWeight = currentUserProfile?.startWeight?.doubleValue else { return 0 }
        
        let request: NSFetchRequest<WeightEntry> = WeightEntry.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \WeightEntry.date, ascending: false)]
        request.fetchLimit = 1
        
        do {
            let entries = try viewContext.fetch(request)
            guard let currentWeight = entries.first?.weight else { return 0 }
            return currentWeight - startWeight
        } catch {
            print("Error calculating total change: \(error)")
            return 0
        }
    }
    
    func logDose(dose: Double, site: String, painLevel: Int, notes: String?) {
        let entry = DoseEntry(context: viewContext)
        entry.id = UUID()
        entry.date = Date()
        entry.dose = dose
        entry.injectionSite = site
        entry.painLevel = Int16(painLevel)
        entry.notes = notes
        entry.userProfile = currentUserProfile
        
        currentUserProfile?.lastShotDate = Date()
        currentUserProfile?.dose = NSNumber(value: dose)
        
        saveContext()
        refreshTodayStats()
    }
    
    func logWeight(_ weight: Double) {
        let entry = WeightEntry(context: viewContext)
        entry.id = UUID()
        entry.date = Date()
        entry.weight = weight
        entry.userProfile = currentUserProfile
        
        currentUserProfile?.currentWeight = NSNumber(value: weight)
        
        saveContext()
        refreshTodayStats()
    }
    
    func logNutrition(calories: Int, protein: Int, carbs: Int, fat: Int, water: Int, mealType: String?, description: String?) {
        let entry = NutritionEntry(context: viewContext)
        entry.id = UUID()
        entry.date = Date()
        entry.calories = Int32(calories)
        entry.protein = Int32(protein)
        entry.carbs = Int32(carbs)
        entry.fat = Int32(fat)
        entry.water = Int32(water)
        entry.mealType = mealType
        entry.mealDescription = description
        entry.userProfile = currentUserProfile
        
        saveContext()
        refreshTodayStats()
    }
    
    func logSymptom(type: String, severity: Int, notes: String?) {
        let entry = SymptomEntry(context: viewContext)
        entry.id = UUID()
        entry.date = Date()
        entry.symptomType = type
        entry.severity = Int16(severity)
        entry.notes = notes
        entry.userProfile = currentUserProfile
        
        saveContext()
    }
    
    func logActivity(steps: Int, exerciseMinutes: Int, caloriesBurned: Int, activityType: String?) {
        let entry = ActivityEntry(context: viewContext)
        entry.id = UUID()
        entry.date = Date()
        entry.steps = Int32(steps)
        entry.exerciseMinutes = Int32(exerciseMinutes)
        entry.caloriesBurned = Int32(caloriesBurned)
        entry.activityType = activityType
        entry.userProfile = currentUserProfile
        
        saveContext()
        refreshTodayStats()
    }
    
    func getWeightHistory(days: Int = 30) -> [WeightEntry] {
        let request: NSFetchRequest<WeightEntry> = WeightEntry.fetchRequest()
        let startDate = Calendar.current.date(byAdding: .day, value: -days, to: Date())!
        
        request.predicate = NSPredicate(format: "date >= %@", startDate as NSDate)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \WeightEntry.date, ascending: true)]
        
        do {
            return try viewContext.fetch(request)
        } catch {
            print("Error fetching weight history: \(error)")
            return []
        }
    }
    
    func getDoseHistory(limit: Int = 10) -> [DoseEntry] {
        let request: NSFetchRequest<DoseEntry> = DoseEntry.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \DoseEntry.date, ascending: false)]
        request.fetchLimit = limit
        
        do {
            return try viewContext.fetch(request)
        } catch {
            print("Error fetching dose history: \(error)")
            return []
        }
    }
    
    private func saveContext() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                print("Error saving context: \(error)")
            }
        }
    }
}