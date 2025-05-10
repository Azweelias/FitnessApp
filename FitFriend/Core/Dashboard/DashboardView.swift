import SwiftUI
import FirebaseAuth
import Foundation
import FirebaseFirestore

struct DashboardView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @StateObject var foodViewModel = FoodViewModel()
    @StateObject var hydrationVM = HydrationViewModel()
    @StateObject var exerciseVM = ExerciseViewModel()
    @State private var todaysSteps: Int = 0
    @State private var todaysSleepMinutes: Int = 0
    @State private var weeklyExerciseMinutes: Int = 0
    @State private var weeklyHydrationCups: Int = 0
    private var healthStore = HealthStore()
    let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    
    var body: some View {
        if let user = viewModel.currentUser {
            
            //Variables for Macros, goal macros
            let goalPro = Int(user.proPercent * Double(user.goalCalories)/4)
            let goalCarb = Int(user.carbPercent * Double(user.goalCalories)/4)
            let goalFat = Int(user.fatPercent * Double(user.goalCalories)/9)
            
            //Consumed macros
            let totalProtein = foodViewModel.totalProtein
            let totalCarb = foodViewModel.totalCarbs
            let totalFat = foodViewModel.totalFat
            
            ScrollView {
                VStack(alignment: .leading, spacing: 15) {
                    
                    // Header
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Hello, \(user.firstName)!")
                                .font(.title2)
                                .fontWeight(.bold)
                            Text("\(getDayOfWeek()), \(getDate())")
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        Image(systemName: "bell.fill")
                            .font(.title2)
                            .foregroundColor(.black)
                    }
                    .padding(.horizontal)
                    
                    // Calorie Tracker
                    VStack (spacing: 15){
                        HStack () {
                            Text("Calories")
                                .font(.title3)
                                .fontWeight(.bold)
                            Spacer()
                        }
                        .padding()
                        
                        HStack {
                            ZStack {
                                Circle()
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 10)
                                    .frame(width: 150, height: 150)
                                Circle()
                                    .trim(from: 0, to: progressDouble(user.goalCalories, foodViewModel.totalCalories)) // food div by goal
                                    .stroke(Color.blue, lineWidth: 10)
                                    .rotationEffect(.degrees(-90))
                                    .frame(width: 150, height: 150)
                                VStack {
                                    Text("\(user.goalCalories - foodViewModel.totalCalories)")
                                        .font(.largeTitle)
                                        .fontWeight(.bold)
                                    Text("Remaining calories")
                                        .font(.caption)
                                        .multilineTextAlignment(.center)
                                        .frame(width: 120)
                                }
                            }
                            
                            VStack(alignment: .leading) {
                                miniInfo(title: "Goal", value: "\(user.goalCalories)", icon: "flag.fill")
                                miniInfo(title: "Food", value: "\(foodViewModel.totalCalories)", icon: "fork.knife")
                                let totalExerciseCalories = Int(exerciseVM.entries.reduce(0) { $0 + $1.calories })
                                miniInfo(title: "Exercise", value: "\(totalExerciseCalories)", icon: "figure.run")
                            }
                            .padding(.horizontal)
                        }
                        .padding(.horizontal)
                        
                        Spacer()
                    }
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding()
                    
                    // Nutrition Breakdown
                    
                    Text("Macros:")
                        .font(.headline)
                        .padding(.horizontal)
                    VStack {
                        HStack(spacing: 20) {
                            NutritionView(title: "Protein", value: "\(totalProtein)/\(goalPro)g", progress: progressDouble(goalPro, totalProtein))
                            NutritionView(title: "Fat", value: "\(totalFat)/\(goalFat)g", progress: progressDouble(goalFat, totalFat))
                            NutritionView(title: "Carbs", value: "\(totalCarb)/\(goalCarb)g", progress: progressDouble(goalCarb, totalCarb))
                        }
                        .padding()
                    }
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    // Weekly Averages
                    VStack(alignment: .leading, spacing: 10) {
                        Text("This week's total:")
                            .font(.headline)
                        HStack(spacing: 15) {
                            StatBox(title: "Steps", value: "\(todaysSteps) Steps", icon: "figure.walk")
                            StatBox(title: "Sleep", value: "\(todaysSleepMinutes/60)h \(todaysSleepMinutes%60)m", icon: "moon.zzz.fill")
                        }
                        HStack(spacing: 15) {
                            StatBox(
                                  title: "Exercise",
                                  value: "\(weeklyExerciseMinutes) min",
                                  icon: "figure.run"
                                )
                            StatBox(title: "Hydration", value: "\(weeklyHydrationCups) cup\(weeklyHydrationCups == 1 ? "" : "s")", icon: "drop.fill")
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.top)
            .onAppear(){
                foodViewModel.startListening(for: Date())
                hydrationVM.startListening(for: Date())
                exerciseVM.startListening(for: Date())
                fetchTodaysSteps()
                fetchTodaySleep()
                fetchWeeklyExercise()
                fetchWeeklyHydration()
            }
            .onDisappear(){
                foodViewModel.stopListening()
            }
            .onReceive(timer) { _ in
                fetchTodaysSteps()
            }
        }
    }
    /// Fetch total exercise minutes from Monday 00:00 this week → now
    private func fetchWeeklyExercise() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let calendar = Calendar.current
        let now = Date()
        
        // 1. Compute this week’s Monday at midnight
        let comps = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)
        guard let monday = calendar.date(from: comps) else { return }
        
        // 2. Prepare date formatter
        let dateFmt = DateFormatter()
        dateFmt.dateFormat = "yyyy-MM-dd"
        
        // 3. Launch async work
        Task {
            var totalMins = 0
            
            // 4. Determine how many days between Monday and today
            let dayCount = (calendar.dateComponents([.day], from: monday, to: now).day ?? 0)
            
            // 5. Loop each day
            for offset in 0...dayCount {
                guard let dayDate = calendar.date(byAdding: .day, value: offset, to: monday) else { continue }
                let dayString = dateFmt.string(from: dayDate)
                
                // 6. Query that day’s entries subcollection
                let snap = try await Firestore.firestore()
                    .collection("users").document(uid)
                    .collection("exercises").document(dayString)
                    .collection("entries")
                    .getDocuments()
                
                // 7. Decode and sum durations
                let dayTotal = snap.documents
                    .compactMap { try? $0.data(as: ExerciseEntry.self) }
                    .reduce(0) { $0 + $1.durationMin }
                
                totalMins += dayTotal
            }
            
            // 8. Push result back to main thread
            DispatchQueue.main.async {
                self.weeklyExerciseMinutes = totalMins
            }
        }
    }


    /// Fetch total hydration cups for Monday → now
    private func fetchWeeklyHydration() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let cal = Calendar.current
        let now = Date()

        // Monday of current week at midnight
        let comps = cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)
        guard let monday = cal.date(from: comps) else { return }

        let ref = Firestore.firestore()
            .collection("users").document(uid)
            .collection("hydration")

        ref.getDocuments { snap, _ in
            guard let docs = snap?.documents else { return }
            let dateFmt = DateFormatter()
            dateFmt.dateFormat = "yyyy-MM-dd"

            let total = docs.reduce(0) { sum, doc in
                // doc ID is "yyyy-MM-dd"
                guard
                  let date = dateFmt.date(from: doc.documentID),
                  date >= monday && date <= now,
                  let cups = doc.data()["cups"] as? Int
                else { return sum }
                return sum + cups
            }
            DispatchQueue.main.async {
                weeklyHydrationCups = total
            }
        }
    }
    
    private func progressDouble(_ goal: Int, _ currAmt: Int) -> Double {
        if goal == 0 { return 0.0 } // Avoid division by zero
        else if currAmt > goal { return 1.0 }
        return min(Double(currAmt) / Double(goal), 1.0)
    }
    
    private func progPro(_ goalCal: Int, _ food: Int) -> String {
        
        return ""
    }
    
    private func fetchTodaysSteps() {
        healthStore.requestAuthorization { success in
            if success {
                healthStore.fetchStepsToday { steps in
                    DispatchQueue.main.async {
                        self.todaysSteps = Int(steps)
                    }
                }
            }
        }
    }
    
    private func fetchTodaySleep() {
        healthStore.requestAuthorization { success in
            if success {
                healthStore.fetchWeeklySleep { minutes in
                    DispatchQueue.main.async {
                        self.todaysSleepMinutes = Int(minutes)
                    }
                }
            }
        }
    }
    
}

// Custom View Components
struct NutritionView: View {
    let title: String
    let value: String
    let progress: CGFloat

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.footnote)
                .fontWeight(.bold)
            ProgressView(value: progress)
                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
            Text(value)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
    }
}

struct StatBox: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                HStack {
                    Image(systemName: icon)
                        .foregroundColor(.blue)
                    Text(title)
                        .font(.footnote)
                        .foregroundColor(.gray)
                }
                Text(value)
                    .font(.headline)
                    .fontWeight(.bold)
            }
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct miniInfo: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .resizable()
                .foregroundColor(.blue)
                .frame(width: 26, height: 30)
            VStack(alignment: .leading) {
                Text(title)
                    .font(.footnote)
                    .foregroundColor(.gray)
                Text(value)
                    .font(.headline)
                    .fontWeight(.bold)
            }
        }
        .padding(.horizontal)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

func getDayOfWeek() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE" // "EEEE" represents the full day name (e.g., Monday)
        return formatter.string(from: Date())
    }

func getDate() -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMMM d"
    return formatter.string(from: Date())
}

#Preview {
    DashboardView()
        .environmentObject(AuthViewModel())
}
