import Foundation
import CoreData
import SwiftUI

// MARK: - Simple Data Manager for the app
class SimpleDataManager: ObservableObject {
    static let shared = SimpleDataManager()
    
    @Published var todayWeight: Double?
    @Published var todayCalories: Int = 0
    @Published var todayProtein: Int = 0
    @Published var todayWater: Int = 0
    @Published var todaySteps: Int = 0
    @Published var currentStreak: Int = 7
    @Published var weeklyWeightChange: Double = -2.3
    @Published var totalWeightChange: Double = -5.8
    
    // Mock current user profile data
    @Published var currentUserProfile: UserProfile?
    
    private let container: NSPersistentContainer
    private let viewContext: NSManagedObjectContext
    
    init() {
        self.container = PersistenceController.shared.container
        self.viewContext = container.viewContext
        loadUserProfile()
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
    
    func logWeight(_ weight: Double) {
        todayWeight = weight
        // Here you would normally save to Core Data
        print("Logged weight: \(weight)")
    }
    
    func logNutrition(calories: Int, protein: Int, water: Int) {
        todayCalories += calories
        todayProtein += protein
        todayWater += water
        print("Logged nutrition - Calories: \(calories), Protein: \(protein), Water: \(water)")
    }
    
    func logDose(dose: Double, site: String, painLevel: Int, notes: String?) {
        currentStreak += 1
        print("Logged dose: \(dose)mg at \(site), pain level: \(painLevel)")
    }
    
    func logSymptom(type: String, severity: Int, notes: String?) {
        print("Logged symptom: \(type), severity: \(severity)")
    }
}

// MARK: - User Profile Extensions
extension UserProfile {
    var nextShotDate: Date {
        guard let lastShot = lastShotDate,
              let frequency = shotFrequency else {
            return Calendar.current.date(byAdding: .day, value: 3, to: Date()) ?? Date()
        }
        return Calendar.current.date(byAdding: .day, value: Int(frequency), to: lastShot) ?? Date()
    }
    
    var daysUntilNextShot: Int {
        let days = Calendar.current.dateComponents([.day], from: Date(), to: nextShotDate).day ?? 3
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

// MARK: - Simple Tracking Views

struct SimpleWeightTrackingView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var dataManager = SimpleDataManager.shared
    @State private var weight: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section("Log Weight") {
                    HStack {
                        TextField("Weight", text: $weight)
                            .keyboardType(.decimalPad)
                        Text("lbs")
                            .foregroundColor(.secondary)
                    }
                }
                
                Section("Current Stats") {
                    if let currentWeight = dataManager.todayWeight {
                        HStack {
                            Text("Today's Weight")
                            Spacer()
                            Text("\(String(format: "%.1f", currentWeight)) lbs")
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    HStack {
                        Text("Total Change")
                        Spacer()
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.down")
                                .font(.caption)
                                .foregroundColor(.green)
                            Text("\(String(format: "%.1f", abs(dataManager.totalWeightChange))) lbs")
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Weight Tracking")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        if let weightValue = Double(weight) {
                            dataManager.logWeight(weightValue)
                        }
                        dismiss()
                    }
                    .fontWeight(.bold)
                    .disabled(weight.isEmpty)
                }
            }
        }
    }
}

struct SimpleDoseTrackingView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var dataManager = SimpleDataManager.shared
    @State private var dose: String = "0.5"
    @State private var injectionSite = "Stomach - Upper Left"
    @State private var painLevel: Double = 0
    @State private var notes = ""
    
    let injectionSites = ["Stomach - Upper Left", "Stomach - Upper Right", "Thigh - Left", "Thigh - Right"]
    
    var body: some View {
        NavigationView {
            Form {
                Section("Dose Information") {
                    HStack {
                        TextField("Dose", text: $dose)
                            .keyboardType(.decimalPad)
                        Text("mg")
                            .foregroundColor(.secondary)
                    }
                    
                    Picker("Injection Site", selection: $injectionSite) {
                        ForEach(injectionSites, id: \.self) { site in
                            Text(site).tag(site)
                        }
                    }
                }
                
                Section("Pain Level") {
                    VStack {
                        HStack {
                            Text("Pain Level")
                            Spacer()
                            Text("\(Int(painLevel))")
                        }
                        Slider(value: $painLevel, in: 0...10, step: 1)
                    }
                }
                
                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 60)
                }
            }
            .navigationTitle("Log Dose")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        if let doseValue = Double(dose) {
                            dataManager.logDose(dose: doseValue, site: injectionSite, painLevel: Int(painLevel), notes: notes.isEmpty ? nil : notes)
                        }
                        dismiss()
                    }
                    .fontWeight(.bold)
                }
            }
        }
    }
}

struct SimpleNutritionTrackingView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var dataManager = SimpleDataManager.shared
    @State private var calories = ""
    @State private var protein = ""
    @State private var water = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section("Quick Add") {
                    HStack {
                        Image(systemName: "flame.fill")
                            .foregroundColor(.orange)
                        TextField("Calories", text: $calories)
                            .keyboardType(.numberPad)
                    }
                    
                    HStack {
                        Text("P")
                            .foregroundColor(.red)
                            .font(.bold(.caption)())
                        TextField("Protein (g)", text: $protein)
                            .keyboardType(.numberPad)
                    }
                    
                    HStack {
                        Image(systemName: "drop.fill")
                            .foregroundColor(.cyan)
                        TextField("Water (oz)", text: $water)
                            .keyboardType(.numberPad)
                    }
                }
                
                Section("Today's Total") {
                    HStack {
                        Text("Calories")
                        Spacer()
                        Text("\(dataManager.todayCalories)")
                            .foregroundColor(.orange)
                    }
                    
                    HStack {
                        Text("Protein")
                        Spacer()
                        Text("\(dataManager.todayProtein)g")
                            .foregroundColor(.red)
                    }
                    
                    HStack {
                        Text("Water")
                        Spacer()
                        Text("\(dataManager.todayWater) oz")
                            .foregroundColor(.cyan)
                    }
                }
            }
            .navigationTitle("Nutrition")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let caloriesInt = Int(calories) ?? 0
                        let proteinInt = Int(protein) ?? 0
                        let waterInt = Int(water) ?? 0
                        
                        dataManager.logNutrition(calories: caloriesInt, protein: proteinInt, water: waterInt)
                        dismiss()
                    }
                    .fontWeight(.bold)
                }
            }
        }
    }
}

struct SimpleSymptomTrackingView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var dataManager = SimpleDataManager.shared
    @State private var selectedSymptoms: Set<String> = []
    @State private var notes = ""
    
    let commonSymptoms = ["Nausea", "Fatigue", "Headache", "Dizziness", "Constipation", "Decreased appetite"]
    
    var body: some View {
        NavigationView {
            Form {
                Section("Common Symptoms") {
                    ForEach(commonSymptoms, id: \.self) { symptom in
                        HStack {
                            Text(symptom)
                            Spacer()
                            if selectedSymptoms.contains(symptom) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.purple)
                            } else {
                                Image(systemName: "circle")
                                    .foregroundColor(.gray)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if selectedSymptoms.contains(symptom) {
                                selectedSymptoms.remove(symptom)
                            } else {
                                selectedSymptoms.insert(symptom)
                            }
                        }
                    }
                }
                
                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 80)
                }
            }
            .navigationTitle("Track Symptoms")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        for symptom in selectedSymptoms {
                            dataManager.logSymptom(type: symptom, severity: 2, notes: notes.isEmpty ? nil : notes)
                        }
                        dismiss()
                    }
                    .fontWeight(.bold)
                    .disabled(selectedSymptoms.isEmpty && notes.isEmpty)
                }
            }
        }
    }
}