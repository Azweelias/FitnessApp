import SwiftUI

struct StepView: View {
    @State private var steps: Double = 1200
    var healthStore = HealthStore()
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Today's Steps")
                .font(.headline)
            
            Text("\(Int(steps)) steps")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.blue)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .onAppear {
            // ONLY run HealthKit if NOT in Preview
            #if !targetEnvironment(simulator)
            if !ProcessInfo.processInfo.environment.keys.contains("XCODE_RUNNING_FOR_PREVIEWS") {
                healthStore.requestAuthorization { success in
                    if success {
                        healthStore.fetchStepsToday { steps in
                            DispatchQueue.main.async {
                                self.steps = steps
                            }
                        }
                    }
                }
            }
            #endif
        }
    }
}

#Preview {
    StepView()
}
