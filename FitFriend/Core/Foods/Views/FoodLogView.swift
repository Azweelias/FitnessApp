import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct FoodLogView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @StateObject var foodViewModel = FoodViewModel()
    @State private var selectedDate = Date()
    
    var body: some View {
        NavigationStack {
            VStack {
                // Date Picker
                HStack {
                    Button(action: {
                        selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) ?? selectedDate
                        foodViewModel.startListening(for: selectedDate)
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundStyle(Color.blue)
                    }
                    Spacer()
                    Text(formattedDate(selectedDate))
                        .font(.title2)
                        .fontWeight(.bold)
                    Spacer()
                    Button(action: {
                        selectedDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) ?? selectedDate
                        foodViewModel.startListening(for: selectedDate)
                    }) {
                        Image(systemName: "chevron.right")
                            .foregroundStyle(Color.blue)
                    }
                }
                .padding()

                // Daily Total Bar View
                DailyTotalBarView(gCals: viewModel.currentUser?.goalCalories ?? 2000, tCals: foodViewModel.totalCalories)
                    .offset(y: 7)

                if foodViewModel.isLoading {
                    ProgressView("Loading...")
                        .padding(.vertical, 270)
                } else if let errorMessage = foodViewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                } else {
                    // Food Log
                    List {
                        if foodViewModel.foodEntries.isEmpty {
                            Text("No food entries found for this date.")
                                .foregroundColor(.gray)
                        } else {
                            ForEach(foodViewModel.foodEntries, id: \.dateAdded) { entry in
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text("\(entry.food_name)")
                                            .font(.headline)
                                        HStack {
                                            Text("\(entry.brand_name),")
                                                .font(.subheadline)
                                                .foregroundColor(.gray)
                                            Text("\(entry.fServingQty) \(entry.serving_unit)")
                                                .font(.subheadline)
                                                .foregroundColor(.gray)
                                        }
                                    }
                                    Spacer()
                                    Text("\(entry.fCalories) cal")
                                        .fontWeight(.bold)
                                }
                            }
                        }
                    }
                }

                // Add Food Button
                NavigationLink(destination: SearchFoodView(mealTime: "Breakfast", SelectedDate: selectedDate)) {
                    Text("Add Food")
                        .foregroundColor(.blue)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(radius: 3)
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .onAppear {
                foodViewModel.startListening(for: selectedDate)
            }
            .onDisappear {
                foodViewModel.stopListening()
            }
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let calendar = Calendar.current

        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInTomorrow(date) {
            return "Tomorrow"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM d, yyyy"
            return formatter.string(from: date)
        }
    }
}


struct FoodEntry: Identifiable, Codable {
    @DocumentID var id: String?
    let foodName: String
    let servingSize: Double
    let servingUnit: String
    let calories: Int
    let dateAdded: String
}

#Preview {
    FoodLogView()
        .environmentObject(AuthViewModel())
}
