import SwiftUI
import FirebaseCore

struct CFoodDetailsView: View {
    let cFoodItem: String
    let mealTime: String
    let selectedDate: Date
    @State var cFoodDetail: FoodResponse.Food?
    @State private var errorMessage: String?
    @State var showNutrition: Bool = false
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: AuthViewModel 

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.cyan.opacity(0.9), Color.white.opacity(0.9)]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            VStack(spacing: 15) {
                if let detail = cFoodDetail {
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
                        
                        Text ("\(detail.fServingQty) \(detail.serving_unit) (\(detail.fServingWeightGrams))")
                            .font(.body)
                    }
                    
                    HStack {
                        Text("Nutrients")
                            .font(.headline)
                            .underline()
                    }
                    .padding(.vertical)
                    
                    HStack() {
                        ZStack {
                            Circle()
                                .fill(Color.gray.opacity(0.5)) // Set the circle's background color to navy
                                .frame(width: 80, height: 80) // Set the size of the circle
                            
                            VStack {
                                Text("\(detail.fCalories)") // Display the calorie count
                                    .font(.headline)
                                    .foregroundColor(.black) // Set the text color to white to contrast with the navy background
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
                await getCFoodDet(cFoodId: cFoodItem) //TODO: Uncomment before demo
            }
            .navigationBarBackButtonHidden(true)
            .toolbar {
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
                                if let detail = cFoodDetail {
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
    }

    // Async data-fetching function
    public func getCFoodDet(cFoodId: String) async {
        do {
            let response = try await NutritionManager().getCFoodDetails(id: cFoodId)
            cFoodDetail = response.foods.first
        } catch {
            print(String(describing: error))
            errorMessage = "An Error Occurred"
        }
    }
}
#Preview {
    CFoodDetailsView(cFoodItem: "orange",
                     mealTime: "Breakfast",
                     selectedDate: Date(),
                     cFoodDetail: previewFoodDetail.foods[1])
    .environmentObject(AuthViewModel())
}
