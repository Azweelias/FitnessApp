import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct FoodLogView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var selectedDate = Date()
    @State private var timeStamp = Timestamp(date: Date())
    @State var foodEntries: [FoodResponse.Food] = []
    @State private var showingSearchView = false
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State var totalCal: Int = 0

    var body: some View {
        NavigationStack {
            VStack {
                // Date Picker
                HStack {
                    Button(action: {
                        selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) ?? selectedDate
                        Task { await fetchFoodEntries() }
                        timeStamp = Timestamp(date: selectedDate)
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundStyle(Color.black)
                    }
                    Spacer()
                    Text(formattedDate(selectedDate))
                        .font(.title2)
                        .fontWeight(.bold)
                    Spacer()
                    Button(action: {
                        selectedDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) ?? selectedDate
                        Task { await fetchFoodEntries() }
                        timeStamp = Timestamp(date: selectedDate)
                    }) {
                        Image(systemName: "chevron.right")
                            .foregroundStyle(Color.black)
                    }
                }
                .padding()
                //
                DailyTotalBarView(gCals: 1800, tCals: 1000)

                if isLoading {
                    ProgressView("Loading...")
                        .padding(.vertical, 270)
                } else if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                } else {
                    // Food Log
                    List {
                        if foodEntries.isEmpty {
                            Text("No food entries found for this date.")
                                .foregroundColor(.gray)
                        } else {
                            ForEach(foodEntries, id: \ .dateAdded) { entry in
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text("\(entry.food_name)")
                                            .font(.headline)
                                        Text("\(entry.fServingQty) \(entry.serving_unit)")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
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
                NavigationLink(destination: SearchFoodView(mealTime: "Breakfast", timeStamp: timeStamp)) {
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
            .task {
                await fetchFoodEntries()
            }
        }
    }

    private func fetchFoodEntries() async {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        isLoading = true
        errorMessage = nil

        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: selectedDate)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        let startTimestamp = Timestamp(date: startOfDay)
        let endTimestamp = Timestamp(date: endOfDay)

        do {
            let snapshot = try await Firestore.firestore()
                .collection("users").document(userID)
                .collection("foods")
                .whereField("dateAdded", isGreaterThanOrEqualTo: startTimestamp)
                .whereField("dateAdded", isLessThan: endTimestamp)
                .getDocuments()

            self.foodEntries = snapshot.documents.compactMap { document in
                try? document.data(as: FoodResponse.Food.self)
            }
        } catch {
            errorMessage = "Error fetching food entries: \(error.localizedDescription)"
        }

        isLoading = false
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
