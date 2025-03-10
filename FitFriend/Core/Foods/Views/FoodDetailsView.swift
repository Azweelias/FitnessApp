import SwiftUI

struct FoodDetailsView: View {
    let bFoodItem: SearchResponse.BrandedFoodItem
    @State private var bFoodDetail: FoodResponse.Food?
    @State private var errorMessage: String?
    @State var showNutrition: Bool = false

    var body: some View {
        VStack(spacing: 20) {
            if let detail = bFoodDetail {
                Text(detail.food_name)
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("\(detail.fCalories) cal")
                    .font(.title2)
                    .foregroundColor(.black)

                Text("\(detail.fServingQty) \(detail.serving_unit) (\(detail.fServingWeightGrams) g)")
                    .font(.body)

                Text("Brand: \(detail.brand_name)")
                    .font(.subheadline)
                    .foregroundColor(.black)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Nutrients:")
                        .font(.headline)
                    Text("Carbs: \(detail.fTotalCarb) g")
                    Text("Protein: \(detail.fTotalProtein) g")
                    Text("Fats: \(detail.fTotalFat) g")
                }
                .padding()
                .background(Color.gray.opacity(0.5))
                .cornerRadius(10)
                
            } else if let errorMessage = errorMessage {
                Text("Error: \(errorMessage)")
                    .foregroundColor(.red)
            } else {
                ProgressView("Loading...")
            }

            Spacer()
        }
        .padding()
        .navigationTitle("Food Details")
        .task {
            await getBFoodDet(bFoodId: bFoodItem.nix_item_id)
        }
    }

    // Async data-fetching function
    private func getBFoodDet(bFoodId: String) async {
        do {
            let response = try await NutritionManager().getBFoodDetails(id: bFoodId)
            bFoodDetail = response.foods.first
        } catch {
            errorMessage = String(describing: error)
        }
    }
}
