//
//  ContentView.swift
//  FitFriend
//
//  Created by admin on 3/4/25.
//

import SwiftUI

struct SearchFoodView: View {
    @StateObject private var nutritionManager = NutritionManager()
    @State var searchQuery = ""
    @State var searchResults: [SearchResponse.CommonFoodItem] = []
    @State var isLoading = false
    @State var errorMessage: String?

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.black.opacity(0.8)]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                HStack(spacing: 20) {
                    TextField("Search for food...", text: $searchQuery)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 280, height: 30)
                    
                    Button(action: {
                        Task {
                            await performSearch()
                        }
                    }) {
                        Image(systemName: "magnifyingglass")
                            
                            .scaledToFit()
                            .frame(width: 35, height: 35)
                            .background(Color.white)
                            .foregroundColor(.black)
                            .cornerRadius(12)
                    }
                    .padding()
                    .frame(width: 9, height: 10)
                    .disabled(searchQuery.isEmpty)
                }
                
                VStack {
                    if isLoading {
                        ProgressView("Loading...")
                            .padding()
                    }
                    
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding()
                    }
                    
                    List(searchResults, id: \.food_name) { item in
                        HStack(spacing: 20) {
                            VStack(alignment: .leading) {
                                Text(item.food_name.capitalized)
                                    .font(.headline)
                                Text("\(item.fServingQty) \(item.serving_unit)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                Task {
                                    print("\(item.food_name) Added!")
                                }
                            }) {
                                Image(systemName: "plus.circle.fill")
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        
                    }
                    .cornerRadius(8)
                    .background(LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.black.opacity(0.8)]), startPoint: .top, endPoint: .bottom)
                        .edgesIgnoringSafeArea(.all))
                }
            }
            .padding()
        }
    }

    private func performSearch() async {
        isLoading = true
        errorMessage = nil

        do {
            let response = try await nutritionManager.getFoodSearch(searchVal: searchQuery)
            searchResults = response.common
        } catch {
            errorMessage = String(describing: error)
        }

        isLoading = false
    }
}

#Preview {
    SearchFoodView()
}
