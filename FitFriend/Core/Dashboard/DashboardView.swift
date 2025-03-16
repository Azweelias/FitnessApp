import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @StateObject var foodViewModel = FoodViewModel()
    
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
                            StatBox(title: "Steps", value: "13,456 Steps", icon: "figure.walk")
                            StatBox(title: "Sleep", value: "8h 46m", icon: "moon.zzz.fill")
                        }
                        HStack(spacing: 15) {
                            StatBox(title: "Exercise", value: "460 min", icon: "figure.run")
                            StatBox(title: "Hydration", value: "4 cup(s)", icon: "drop.fill")
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.top)
            .onAppear(){
                foodViewModel.startListening(for: Date())
            }
            .onDisappear(){
                foodViewModel.stopListening()
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
        .padding()
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
