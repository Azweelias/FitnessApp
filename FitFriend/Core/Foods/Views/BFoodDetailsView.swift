import SwiftUI
import FirebaseCore

struct BFoodDetailsView: View {
    let bFoodItem: String
    let mealTime: String
    let selectedDate: Date
    @State var bFoodDetail: FoodResponse.Food?
    @State private var errorMessage: String?
    @State var showNutrition: Bool = false

    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: AuthViewModel   // Inject AuthViewModel

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.cyan.opacity(0.9), Color.white.opacity(0.9)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 15) {
                if let detail = bFoodDetail {
                    // Food Name and Brand Info
                    HStack {
                        VStack(alignment: .leading) {
                            Text(detail.food_name.capitalized)
                                .font(.headline)
                                .fontWeight(.bold)
                            
                            Text(detail.fBrandName)
                                .font(.subheadline)
                                .foregroundColor(.black)
                        }
                        Spacer()
                    }
                    
                    // Serving Size Info
                    HStack {
                        Text("Serving Size")
                            .font(.title3)
                        
                        Spacer()
                        
                        Text("\(detail.fServingQty) \(detail.serving_unit) (\(detail.fServingWeightGrams))")
                            .font(.body)
                    }
                    
                    // Nutrients Title
                    HStack {
                        Text("Nutrients")
                            .font(.headline)
                            .underline()
                    }
                    .padding(.vertical)
                    
                    // Calorie Circle & Macro Nutrients
                    HStack {
                        ZStack {
                            Circle()
                                .fill(Color.gray.opacity(0.5))
                                .frame(width: 80, height: 80)
                            
                            VStack {
                                Text("\(detail.fCalories)")
                                    .font(.headline)
                                    .foregroundColor(.black)
                                    .bold()
                                Text("cal")
                                    .font(.subheadline)
                                    .foregroundColor(.black)
                            }
                        }
                        
                        Spacer()
                        
                        VStack {
                            Text("\(detail.fTotalCarb) g")
                                .fontWeight(.semibold)
                            Text("Carbs")
                                .font(.caption)
                        }
                        
                        Spacer()
                        
                        VStack {
                            Text("\(detail.fTotalFat) g")
                                .fontWeight(.semibold)
                            Text("Fat")
                                .font(.caption)
                        }
                        
                        Spacer()
                        
                        VStack {
                            Text("\(detail.fTotalProtein) g")
                                .fontWeight(.semibold)
                            Text("Protein")
                                .font(.caption)
                        }
                    }
                    
                    // Nutrition Info Title
                    HStack {
                        Text("Nutrition Info:")
                            .fontWeight(.semibold)
                            .underline()
                        Spacer()
                    }
                    .padding(.vertical)
                    
                    // Nutrient Details
                    NutrInfoRowView(label: "Saturated Fats", nutrInfo: detail.fSaturatedFat, unit: "g")
                    NutrInfoRowView(label: "Cholesterol", nutrInfo: detail.fCholesterol, unit: "mg")
                    NutrInfoRowView(label: "Dietary Fiber", nutrInfo: detail.fDietaryFiber, unit: "g")
                    NutrInfoRowView(label: "Sugar", nutrInfo: detail.fSugar, unit: "g")
                    NutrInfoRowView(label: "Sodium", nutrInfo: detail.fSodium, unit: "mg")
                    NutrInfoRowView(label: "Potassium", nutrInfo: detail.fPotassium, unit: "mg")
                } else if let errorMessage = errorMessage {
                    Text("Error: \(errorMessage)")
                        .foregroundColor(.red)
                } else {
                    ProgressView("Loading...")
                }
                
                Spacer()
            }
            .padding()
        }
        .task {
            await getBFoodDet(bFoodId: bFoodItem) //TODO uncomment
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            // Leading: Back Button & Title
            ToolbarItem(placement: .topBarLeading) {
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: "chevron.left")
                                .foregroundStyle(Color.black)
                            Text("Results")
                                .foregroundStyle(Color.black)
                        }
                    }
                    
                    Text("Food Details")
                        .foregroundStyle(Color.black)
                        .font(.title)
                        .fontWeight(.bold)
                        .padding()
                    
                    Button(action: {
                        Task {
                            if let detail = bFoodDetail {
                                do {
                                    // Update the food's mealTime and dateAdded based on the passed values.
                                    var foodToAdd = detail
                                    foodToAdd.mealTime = mealTime
                                    if selectedDate == Date() {
                                        foodToAdd.dateAdded = Timestamp(date: Date())
                                    } else {
                                        foodToAdd.dateAdded = Timestamp(date: selectedDate)
                                    }
                                    try await viewModel.addFoodToUser(food: foodToAdd)
                                    // Optionally, you may provide confirmation or dismiss the view.
                                } catch {
                                    errorMessage = "Failed to add food: \(error.localizedDescription)"
                                }
                            }
                        }
                    }) {
                        Image(systemName: "plus")
                            .foregroundStyle(Color.blue)
                    }
                    .padding(.leading)
                }
                .padding(.bottom)
            }
        }
    }

    // Fetch the food detail asynchronously and assign mealTime and dateAdded
    public func getBFoodDet(bFoodId: String) async {
        do {
            let response = try await NutritionManager().getBFoodDetails(id: bFoodId)
            bFoodDetail = response.foods.first
        } catch {
            print(String(describing: error))
            errorMessage = "An Error Occurred"
        }
    }
}

#Preview {
    BFoodDetailsView(
        bFoodItem: "2238121706c68498234d2778",
        mealTime: "Breakfast",
        selectedDate: Date(),
        bFoodDetail: previewFoodDetail.foods[0]
    )
    .environmentObject(AuthViewModel())
}
