import SwiftUI

struct SearchFoodView: View {
    @StateObject private var nutritionManager = NutritionManager()
    @State var searchQuery = ""
    @State var searchResults: [SearchResponse.CommonFoodItem] = []
    @State var searchResultsB: [SearchResponse.BrandedFoodItem] = []
    @State var bFoodDetail: FoodResponse.Food?
    @State var isLoading = false
    @State var errorMessage: String?
    @State private var showAddedPopup = false

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.9), Color.white.opacity(0.9)]), startPoint: .top, endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 20) {
                    // Header
                    Text("Food Search")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .padding(.top, 5)
                    
                    // Search Bar
                    HStack(spacing: 12) {
                        TextField("Search for food...", text: $searchQuery)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                            .shadow(radius: 3)
                        
                        Button(action: {
                            Task {
                                await performSearch()
                            }
                        }) {
                            Image(systemName: "magnifyingglass")
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .disabled(searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).count < 3)
                    }
                    
                    // Results Section
                    if isLoading {
                        ProgressView("Loading...")
                            .padding()
                        Spacer()
                    } else {
                        if let errorMessage = errorMessage {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .padding()
                        }
                        
                        VStack {
                            ScrollView {
                                VStack(spacing: 15) {
                                    //branded foods
                                    ForEach(searchResultsB, id: \.food_name) { item in
                                        HStack(spacing: 15) {
                                            VStack(alignment: .leading) {
                                                NavigationLink(destination: FoodDetailsView(bFoodItem: item))
                                                               {
                                                    Text(item.food_name.capitalized)
                                                        .font(.headline)
                                                        .foregroundColor(.blue)
                                                }
                                                Text("\(item.fCalories) cal, \(item.fServingQty) \(item.serving_unit), \(item.brand_name)")
                                                    .font(.subheadline)
                                                    .foregroundColor(.gray)
                                            }
                                            
                                            Spacer()
                                            
                                            Button(action: {
                                                Task {
                                                    showAddedPopup = true
                                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                                                        showAddedPopup = false
                                                    }
                                                }
                                            }) {
                                                Image(systemName: "plus.circle.fill")
                                                    .foregroundColor(.blue)
                                                    .font(.title2)
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                            .disabled(showAddedPopup)
                                        }
                                        .padding()
                                        .background(Color.white)
                                        .cornerRadius(10)
                                    }
                                    //common foods
                                    ForEach(searchResults, id: \.food_name) { item in
                                        HStack(spacing: 15) {
                                            VStack(alignment: .leading) {
                                                Text(item.food_name.capitalized)
                                                    .font(.headline)
                                                    .foregroundColor(.blue)
                                                Text("\(item.fServingQty) \(item.serving_unit), (Generic)")
                                                    .font(.subheadline)
                                                    .foregroundColor(.gray)
                                            }
                                            
                                            Spacer()
                                            
                                            Button(action: {
                                                Task {
                                                    showAddedPopup = true
                                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                                                        showAddedPopup = false
                                                    }
                                                }
                                            }) {
                                                Image(systemName: "plus.circle.fill")
                                                    .foregroundColor(.blue)
                                                    .font(.title2)
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                            .disabled(showAddedPopup)
                                        }
                                        .padding()
                                        .background(Color.white)
                                        .cornerRadius(10)
                                    }
                                }
                                .padding(.top)
                            }
                        }
                    }
                }
                .padding()
                
                // Pop-up Notification
                if showAddedPopup {
                    Text("Item Added!")
                        .padding()
                        .background(Color.gray.opacity(0.5))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .zIndex(1)
                }
            }
        }
    }

    private func performSearch() async {
        isLoading = true
        errorMessage = nil

        do {
            let response = try await nutritionManager.getFoodSearch(searchVal: searchQuery)
            searchResults = response.common
            searchResultsB = response.branded
            if searchResults.isEmpty && searchResultsB.isEmpty {
                errorMessage = "\(searchQuery) not found!"
            }
        } catch {
            errorMessage = String(describing: error)
        }

        isLoading = false
    }
}

#Preview {
    SearchFoodView()
}
