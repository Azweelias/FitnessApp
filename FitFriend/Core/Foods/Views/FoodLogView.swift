import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct FoodLogView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @StateObject var foodViewModel = FoodViewModel()
    @State private var selectedDate = Date()
    @State private var showDatePopup = false
    
    // Computed properties to group food entries by mealTime
    private var breakfastItems: [FoodResponse.Food] {
        foodViewModel.foodEntries.filter { $0.mealTime?.lowercased() == "breakfast" }
    }
    
    private var lunchItems: [FoodResponse.Food] {
        foodViewModel.foodEntries.filter { $0.mealTime?.lowercased() == "lunch" }
    }
    
    private var dinnerItems: [FoodResponse.Food] {
        foodViewModel.foodEntries.filter { $0.mealTime?.lowercased() == "dinner" }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    // Date Picker Row
                    HStack {
                        Button(action: {
                            selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) ?? selectedDate
                            foodViewModel.startListening(for: selectedDate)
                        }) {
                            Image(systemName: "chevron.left")
                                .foregroundStyle(Color.blue)
                        }
                        Spacer()
                        // Tapping this button shows a custom small pop-up calendar.
                        Button(action: {
                            showDatePopup = true
                        }) {
                            Text(formattedDate(selectedDate))
                                .font(.title2)
                                .fontWeight(.bold)
                            Image(systemName: "chevron.down")
                        }
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
                        // Food Log List with Sections for Breakfast, Lunch, and Dinner
                        List {
                            Section(header: Text("Breakfast").font(.headline)) {
                                if breakfastItems.isEmpty {
                                    Text("No food entries found for Breakfast.")
                                        .foregroundColor(.gray)
                                } else {
                                    ForEach(breakfastItems, id: \.id) { entry in
                                        NavigationLink(destination: DBFoodDetailView(foodEntry: entry.id ?? "")) {
                                            FoodEntryRow(entry: entry)
                                        }
                                    }
                                    .onDelete { indexSet in
                                        for index in indexSet {
                                            let entry = breakfastItems[index]
                                            foodViewModel.deleteFoodEntry(food: entry)
                                        }
                                    }
                                }
                            }
                            
                            Section(header: Text("Lunch").font(.headline)) {
                                if lunchItems.isEmpty {
                                    Text("No food entries found for Lunch.")
                                        .foregroundColor(.gray)
                                } else {
                                    ForEach(lunchItems, id: \.id) { entry in
                                        NavigationLink(destination: DBFoodDetailView(foodEntry: entry.id ?? "")) {
                                            FoodEntryRow(entry: entry)
                                        }
                                    }
                                    .onDelete { indexSet in
                                        for index in indexSet {
                                            let entry = lunchItems[index]
                                            foodViewModel.deleteFoodEntry(food: entry)
                                        }
                                    }
                                }
                            }
                            
                            Section(header: Text("Dinner").font(.headline)) {
                                if dinnerItems.isEmpty {
                                    Text("No food entries found for Dinner.")
                                        .foregroundColor(.gray)
                                } else {
                                    ForEach(dinnerItems, id: \.id) { entry in
                                        NavigationLink(destination: DBFoodDetailView(foodEntry: entry.id ?? "")) {
                                            FoodEntryRow(entry: entry)
                                        }
                                    }
                                    .onDelete { indexSet in
                                        for index in indexSet {
                                            let entry = dinnerItems[index]
                                            foodViewModel.deleteFoodEntry(food: entry)
                                        }
                                    }
                                }
                            }
                        }
                        .listStyle(.insetGrouped)
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
                // Custom small pop-up calendar overlay
                if showDatePopup {
                    // Centered pop-up card for date selection
                    VStack(spacing: 20) {
                        DatePicker(
                            "Select Date",
                            selection: $selectedDate,
                            displayedComponents: [.date]
                        )
                        .datePickerStyle(GraphicalDatePickerStyle())
                        .labelsHidden()
                        .padding()
                        
                        Button("Done") {
                            showDatePopup = false
                            foodViewModel.startListening(for: selectedDate)
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 20)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        
                        Spacer()
                    }
                    .frame(width: 330, height: 400)
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(radius: 8)
                    .zIndex(1)
                    .position(x: 200,y: 220)
                }
            }
        }
    }
    
    // Helper function to format the date string
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

// A reusable view for displaying a food entry row. This removes duplicate code from our sections.
struct FoodEntryRow: View {
    let entry: FoodResponse.Food
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(entry.food_name.capitalized)
                    .font(.headline)
                HStack {
                    Text("\(entry.fBrandName),")
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

#Preview {
    FoodLogView()
        .environmentObject(AuthViewModel())
}
