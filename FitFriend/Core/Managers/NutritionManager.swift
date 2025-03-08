//
//  NutritionManager.swift
//  FitFriend
//
//  Created by admin on 3/6/25.
//

import Foundation

class NutritionManager: ObservableObject {
    private let appID = "830f2a4a"
    private let appKey = "5dcc7a001baaddb2e6ddb678196672ee"
    private let contentType = "application/json"
    
    private let baseURL = "https://trackapi.nutritionix.com/v2"
    private let nutritionExt = "/natural/nutrients"
    
    func getFoodSearch(searchVal: String)
    async throws -> SearchResponse{
        guard let urlString = URL(string: "\(baseURL)/search/instant") else {
            fatalError("Missing URL!") }
        
        
        var request = URLRequest(url: urlString)
        request.httpMethod = "POST"
        request.addValue(appID, forHTTPHeaderField: "x-app-id")
        request.addValue(appKey, forHTTPHeaderField: "x-app-key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body : [String: Any] = [
            "query": searchVal
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            fatalError("Could not serialize JSON body!")
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {fatalError("Error fetching data!") }
        
        let decodedData = try JSONDecoder().decode(SearchResponse.self, from: data)
        
        return decodedData
        
    }
}

struct SearchResponse: Decodable {
    var common: [CommonFoodItem]
    var branded: [BrandedFoodItem]
    
    struct CommonFoodItem: Decodable { //use food_name and baseurl /natural/nutrients for common
        var serving_qty: Double
        var serving_unit: String
        var food_name: String
        
        var fServingQty: String {
                return serving_qty == floor(serving_qty) ? "\(Int(serving_qty))" : String(format: "%.1f", serving_qty)
            }
    }
    struct BrandedFoodItem: Decodable { //use nix_item_id and baseurl/search/item for branded
        var serving_unit: String
        var serving_qty: Double
        var brand_name: String
        var nix_item_id: String
        var nf_calories: Double
        var food_name: String
        
        var fServingQty: String {
            return serving_qty == floor(serving_qty) ? "\(Int(serving_qty))" : String(format: "%.1f", serving_qty)
        }
        
        var fCalories: String {
            return nf_calories == floor(nf_calories) ? "\(Int(nf_calories))" : String(format: "%.1f", nf_calories)
        }
    }
}
