import SwiftUI

struct ExerciseTabView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @StateObject private var vm = ExerciseViewModel()
    
    @State private var selectedType = "Running"
    @State private var duration = 30
    
    private let types = ["Running", "Cycling", "Swimming", "Yoga", "Walking", "Rowing"]
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            VStack(spacing: 24) {
                
                Text("Exercise Log")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .padding(.top, 20)
                
                VStack(spacing: 16) {
                    // Type Picker
                    Picker("Type", selection: $selectedType) {
                        ForEach(types, id: \.self) { t in
                            Text(t).tag(t)
                        }
                    }
                    .pickerStyle(.menu)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    
                    // Duration Stepper
                    HStack {
                        Text("Duration: \(duration) min")
                            .foregroundColor(.black)
                        Spacer()
                        Stepper("", value: $duration, in: 5...180, step: 5)
                            .labelsHidden()
                            .tint(.blue)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    
                    // Log Button
                    Button {
                        Task { await vm.logExercise(type: selectedType, duration: duration) }
                    } label: {
                        Text("Log Exercise")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, minHeight: 50)
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal)
                
                Divider().background(Color.white.opacity(0.3)).padding(.vertical)
                
                Text("Todays Exercise Log")
                    .font(.headline)
                
                // Today’s entries
                List {
                    ForEach(vm.entries) { entry in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(entry.name)
                                    .foregroundColor(.black)
                                    .font(.headline)
                                Text("\(entry.durationMin) min • \(Int(entry.calories)) cal")
                                    .font(.subheadline)
                                    .foregroundColor(.black)
                            }
                            Spacer()
                            Text(entry.timestamp, style: .time)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .listRowBackground(Color.white)
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            let entry = vm.entries[index]
                            Task {
                                await vm.deleteEntry(entry)
                            }
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .background(Color.gray.opacity(0.2))
                
                Spacer()
            }
        }
        .onAppear {
            vm.startListening(for: Date())
        }
    }
}

#Preview {
    ExerciseTabView()
        .environmentObject(AuthViewModel())
}
