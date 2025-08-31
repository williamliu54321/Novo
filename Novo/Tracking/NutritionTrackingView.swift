import SwiftUI

struct NutritionTrackingView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var dataManager = DataManager.shared
    
    @State private var selectedMealType = "Lunch"
    @State private var calories = ""
    @State private var protein = ""
    @State private var carbs = ""
    @State private var fat = ""
    @State private var water = ""
    @State private var mealDescription = ""
    @State private var isQuickAdd = true
    
    let mealTypes = ["Breakfast", "Lunch", "Dinner", "Snack"]
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    Picker("Entry Type", selection: $isQuickAdd) {
                        Text("Quick Add").tag(true)
                        Text("Full Meal").tag(false)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                if isQuickAdd {
                    quickAddSection
                } else {
                    fullMealSection
                }
                
                Section(header: Text("Today's Summary")) {
                    HStack {
                        Label("\(dataManager.todayCalories)", systemImage: "flame.fill")
                            .foregroundColor(.orange)
                        Text("calories")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Label("\(dataManager.todayProtein)g", systemImage: "p.square.fill")
                            .foregroundColor(.red)
                        Text("protein")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Label("\(dataManager.todayWater) oz", systemImage: "drop.fill")
                            .foregroundColor(.cyan)
                        Text("water")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Nutrition")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveNutrition()
                    }
                    .fontWeight(.bold)
                    .disabled(!canSave)
                }
            }
        }
    }
    
    private var quickAddSection: some View {
        Group {
            Section(header: Text("Quick Add")) {
                HStack {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.orange)
                        .frame(width: 20)
                    TextField("Calories", text: $calories)
                        .keyboardType(.numberPad)
                }
                
                HStack {
                    Image(systemName: "drop.fill")
                        .foregroundColor(.cyan)
                        .frame(width: 20)
                    TextField("Water (oz)", text: $water)
                        .keyboardType(.numberPad)
                }
            }
        }
    }
    
    private var fullMealSection: some View {
        Group {
            Section(header: Text("Meal Information")) {
                Picker("Meal Type", selection: $selectedMealType) {
                    ForEach(mealTypes, id: \.self) { meal in
                        Text(meal).tag(meal)
                    }
                }
                
                TextField("Description (optional)", text: $mealDescription)
            }
            
            Section(header: Text("Nutrition Facts")) {
                HStack {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.orange)
                        .frame(width: 20)
                    TextField("Calories", text: $calories)
                        .keyboardType(.numberPad)
                }
                
                HStack {
                    Text("P")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.red)
                        .frame(width: 20)
                    TextField("Protein (g)", text: $protein)
                        .keyboardType(.numberPad)
                }
                
                HStack {
                    Text("C")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.blue)
                        .frame(width: 20)
                    TextField("Carbs (g)", text: $carbs)
                        .keyboardType(.numberPad)
                }
                
                HStack {
                    Text("F")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.green)
                        .frame(width: 20)
                    TextField("Fat (g)", text: $fat)
                        .keyboardType(.numberPad)
                }
                
                HStack {
                    Image(systemName: "drop.fill")
                        .foregroundColor(.cyan)
                        .frame(width: 20)
                    TextField("Water (oz)", text: $water)
                        .keyboardType(.numberPad)
                }
            }
        }
    }
    
    private var canSave: Bool {
        !calories.isEmpty || !water.isEmpty
    }
    
    private func saveNutrition() {
        let caloriesInt = Int(calories) ?? 0
        let proteinInt = Int(protein) ?? 0
        let carbsInt = Int(carbs) ?? 0
        let fatInt = Int(fat) ?? 0
        let waterInt = Int(water) ?? 0
        
        dataManager.logNutrition(
            calories: caloriesInt,
            protein: proteinInt,
            carbs: carbsInt,
            fat: fatInt,
            water: waterInt,
            mealType: isQuickAdd ? nil : selectedMealType,
            description: mealDescription.isEmpty ? nil : mealDescription
        )
        
        dismiss()
    }
}