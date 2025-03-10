import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
        if let user = viewModel.currentUser {
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
                                    .trim(from: 0, to: 0.7) // Example Progress
                                    .stroke(Color.blue, lineWidth: 10)
                                    .rotationEffect(.degrees(-90))
                                    .frame(width: 150, height: 150)
                                VStack {
                                    Text("800")
                                        .font(.largeTitle)
                                        .fontWeight(.bold)
                                    Text("Remaining calories")
                                        .font(.caption)
                                        .multilineTextAlignment(.center)
                                        .frame(width: 120)
                                }
                            }
                            
                            VStack {
                                miniInfo(title: "Goal", value: "1800", icon: "flag.fill")
                                miniInfo(title: "Food", value: "1000", icon: "fork.knife")
                            }
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
                            NutritionView(title: "Protein", value: "27/29g", progress: 0.93)
                            NutritionView(title: "Fat", value: "40/42g", progress: 0.95)
                            NutritionView(title: "Carbs", value: "32/120g", progress: 0.27)
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
        .padding()
        .frame(maxWidth: .infinity)
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
