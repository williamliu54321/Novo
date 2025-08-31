import SwiftUI

struct SymptomTrackingView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var dataManager = DataManager.shared
    
    @State private var selectedSymptoms: Set<String> = []
    @State private var severities: [String: Int] = [:]
    @State private var notes = ""
    
    let commonSymptoms = [
        ("Nausea", "face.smiling.inverse"),
        ("Fatigue", "battery.25"),
        ("Headache", "head.profile.arrow.forward.and.visionpro"),
        ("Dizziness", "tornado"),
        ("Constipation", "tortoise.fill"),
        ("Diarrhea", "hare.fill"),
        ("Heartburn", "flame.fill"),
        ("Injection site reaction", "bandage.fill"),
        ("Decreased appetite", "fork.knife"),
        ("Stomach pain", "bolt.heart.fill")
    ]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Select Symptoms")) {
                    ForEach(commonSymptoms, id: \.0) { symptom, icon in
                        SymptomRow(
                            symptom: symptom,
                            icon: icon,
                            isSelected: selectedSymptoms.contains(symptom),
                            severity: severities[symptom] ?? 1
                        ) { selected, severity in
                            if selected {
                                selectedSymptoms.insert(symptom)
                                severities[symptom] = severity
                            } else {
                                selectedSymptoms.remove(symptom)
                                severities.removeValue(forKey: symptom)
                            }
                        }
                    }
                }
                
                Section(header: Text("Additional Notes")) {
                    ZStack(alignment: .topLeading) {
                        TextEditor(text: $notes)
                            .frame(minHeight: 80)
                        
                        if notes.isEmpty {
                            Text("Any additional symptoms or notes...")
                                .foregroundColor(.secondary.opacity(0.7))
                                .padding(.horizontal, 5)
                                .padding(.top, 8)
                                .allowsHitTesting(false)
                        }
                    }
                }
                
                if !selectedSymptoms.isEmpty {
                    Section(header: Text("Summary")) {
                        ForEach(Array(selectedSymptoms), id: \.self) { symptom in
                            HStack {
                                Text(symptom)
                                    .font(.subheadline)
                                Spacer()
                                SeverityBadge(severity: severities[symptom] ?? 1)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Track Symptoms")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveSymptoms()
                    }
                    .fontWeight(.bold)
                    .disabled(selectedSymptoms.isEmpty && notes.isEmpty)
                }
            }
        }
    }
    
    private func saveSymptoms() {
        for symptom in selectedSymptoms {
            let severity = severities[symptom] ?? 1
            dataManager.logSymptom(type: symptom, severity: severity, notes: nil)
        }
        
        if !notes.isEmpty && selectedSymptoms.isEmpty {
            dataManager.logSymptom(type: "Other", severity: 1, notes: notes)
        }
        
        dismiss()
    }
}

struct SymptomRow: View {
    let symptom: String
    let icon: String
    let isSelected: Bool
    let severity: Int
    let onToggle: (Bool, Int) -> Void
    
    @State private var localSeverity: Int
    
    init(symptom: String, icon: String, isSelected: Bool, severity: Int, onToggle: @escaping (Bool, Int) -> Void) {
        self.symptom = symptom
        self.icon = icon
        self.isSelected = isSelected
        self.severity = severity
        self.onToggle = onToggle
        self._localSeverity = State(initialValue: severity)
    }
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(isSelected ? .purple : .gray)
                    .frame(width: 24)
                
                Text(symptom)
                    .foregroundColor(isSelected ? .primary : .secondary)
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .purple : .gray)
                    .font(.title3)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                onToggle(!isSelected, localSeverity)
            }
            
            if isSelected {
                VStack(spacing: 4) {
                    HStack {
                        Text("Mild")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("Severe")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack(spacing: 8) {
                        ForEach(1...5, id: \.self) { level in
                            Circle()
                                .fill(level <= localSeverity ? severityColor(localSeverity) : Color.gray.opacity(0.3))
                                .frame(width: 24, height: 24)
                                .overlay(
                                    Text("\(level)")
                                        .font(.caption2)
                                        .foregroundColor(level <= localSeverity ? .white : .gray)
                                )
                                .onTapGesture {
                                    localSeverity = level
                                    onToggle(true, level)
                                }
                        }
                    }
                }
                .padding(.top, 4)
            }
        }
        .padding(.vertical, 4)
    }
    
    private func severityColor(_ severity: Int) -> Color {
        switch severity {
        case 1...2: return .green
        case 3: return .yellow
        case 4...5: return .red
        default: return .gray
        }
    }
}

struct SeverityBadge: View {
    let severity: Int
    
    var severityText: String {
        switch severity {
        case 1: return "Mild"
        case 2: return "Light"
        case 3: return "Moderate"
        case 4: return "Strong"
        case 5: return "Severe"
        default: return "Unknown"
        }
    }
    
    var severityColor: Color {
        switch severity {
        case 1...2: return .green
        case 3: return .yellow
        case 4...5: return .red
        default: return .gray
        }
    }
    
    var body: some View {
        Text(severityText)
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(severityColor.opacity(0.2))
            .foregroundColor(severityColor)
            .cornerRadius(8)
    }
}