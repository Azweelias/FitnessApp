import SwiftUI

struct DBFoodDetailView: View {
    @StateObject var foodViewModel = FoodViewModel()
    var foodEntry: String
    @State private var foodDetail: FoodResponse.Food?
    @State private var errorMessage: String?

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.cyan.opacity(0.9), Color.white.opacity(0.9)]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            VStack(spacing: 15) {
                if let detail = foodDetail {
                    // Display the food details like you did in FoodDetailsView
                    HStack {
                        VStack(alignment: .leading) {
                            Text(detail.food_name.capitalized)
                                .font(.headline)
                                .fontWeight(.bold)
                            Text("\(detail.fBrandName)")
                                .font(.subheadline)
                                .foregroundColor(.black)
                        }
                        Spacer()
                    }

                    HStack {
                        Text("Serving Size")
                            .font(.title3)
                        Spacer()
                        Text("\(detail.fServingQty) \(detail.serving_unit) (\(detail.fServingWeightGrams))")
                            .font(.body)
                    }

                    // Nutrient details
                    HStack {
                        Text("Nutrients")
                            .font(.headline)
                            .underline()
                    }
                    .padding(.vertical)

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
                    
                    HStack {
                        Text("Nutrition Info:")
                            .fontWeight(.semibold)
                            .underline()
                        Spacer()
                    }
                    .padding(.vertical)

                    // More nutritional info
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
            .task {
                // Fetch detailed food data using FoodViewModel's fetchFoodDetails
                await fetchFoodDetail(foodID: foodEntry)
            }
        }
    }

    private func fetchFoodDetail(foodID: String) async {
        do {
            // Fetch food details from Firestore using the FoodViewModel's fetchFoodDetails function
            try await foodViewModel.fetchFoodDetails(foodID: foodID)
            if let fetchedFoodDetail = foodViewModel.selectedFood {  // Assuming the foodViewModel has a foodDetail property
                foodDetail = fetchedFoodDetail
            } else {
                errorMessage = "Food details not found."
            }
        } catch {
            errorMessage = "An error occurred while fetching food details."
        }
    }
}
#Preview {
    DBFoodDetailView(foodEntry: "RhUAzD7TZetctXOX30uJ")
}
