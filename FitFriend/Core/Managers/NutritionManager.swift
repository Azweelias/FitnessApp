//
//  NutritionManager.swift
//  FitFriend
//
//  Created by admin on 3/6/25.
//

import Foundation
import FirebaseCore
import FirebaseFirestore

class NutritionManager: ObservableObject {
    private let appID = "830f2a4a"
    private let appKey = "5dcc7a001baaddb2e6ddb678196672ee"
    private let appID2 = "180fd0fa"
    private let appKey2 = "8890d7882d41b2cc70db3d14b1dff890"
    private let contentType = "application/json"
    
    private let baseURL = "https://trackapi.nutritionix.com/v2"
    
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
    
    func getBFoodDetails(id: String)
    async throws -> FoodResponse{
        guard let urlString = URL(string: "\(baseURL)/search/item?nix_item_id=\(id)") else {
            fatalError("Missing URL!") }
        
        
        var request = URLRequest(url: urlString)
        request.httpMethod = "GET"
        request.addValue(appID, forHTTPHeaderField: "x-app-id")
        request.addValue(appKey, forHTTPHeaderField: "x-app-key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard (response as? HTTPURLResponse)?.statusCode == 200
        else {
            if (response as? HTTPURLResponse)?.statusCode == 401 {
                print("API Limit Exceeded for first API Key, switching to second API Key!")
                let decodedData = try await getBFoodDetails2(id: id)
                
                return decodedData
            }
            fatalError("Error fetching data!")
        }
        
        let decodedData = try JSONDecoder().decode(FoodResponse.self, from: data)
        
        return decodedData
        
    }
    
    func getBFoodDetails2(id: String)
    async throws -> FoodResponse{
        guard let urlString = URL(string: "\(baseURL)/search/item?nix_item_id=\(id)") else {
            fatalError("Missing URL!") }
        
        
        var request = URLRequest(url: urlString)
        request.httpMethod = "GET"
        request.addValue(appID2, forHTTPHeaderField: "x-app-id")
        request.addValue(appKey2, forHTTPHeaderField: "x-app-key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard (response as? HTTPURLResponse)?.statusCode == 200
        else {
            if (response as? HTTPURLResponse)?.statusCode == 401 {
                print("API Limit Exceeded on second API key as well!")
                let decodedData = try JSONDecoder().decode(FoodResponse.self, from: data)
                
                return decodedData
            }
            fatalError("Error fetching data!")
        }
        
        let decodedData = try JSONDecoder().decode(FoodResponse.self, from: data)
        
        return decodedData
        
    }
    
    func getCFoodDetails(id: String)
    async throws -> FoodResponse{
        guard let urlString = URL(string: "\(baseURL)/natural/nutrients") else {
            fatalError("Missing URL!") }
        
        
        var request = URLRequest(url: urlString)
        request.httpMethod = "POST"
        request.addValue(appID, forHTTPHeaderField: "x-app-id")
        request.addValue(appKey, forHTTPHeaderField: "x-app-key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body : [String: Any] = [
            "query": id
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            fatalError("Could not serialize JSON body!")
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard (response as? HTTPURLResponse)?.statusCode == 200
        else {
            if (response as? HTTPURLResponse)?.statusCode == 401 {
                print("API Limit Exceeded for first API Key, switching to second API Key!")
                let decodedData = try await getCFoodDetails2(id: id)
                
                return decodedData
            }
            fatalError("Error fetching data!")
        }
        
        let decodedData = try JSONDecoder().decode(FoodResponse.self, from: data)
        
        return decodedData
        
    }
    
    func getCFoodDetails2(id: String)
    async throws -> FoodResponse{
        guard let urlString = URL(string: "\(baseURL)/natural/nutrients") else {
            fatalError("Missing URL!") }
        
        
        var request = URLRequest(url: urlString)
        request.httpMethod = "POST"
        request.addValue(appID2, forHTTPHeaderField: "x-app-id")
        request.addValue(appKey2, forHTTPHeaderField: "x-app-key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body : [String: Any] = [
            "query": id
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            fatalError("Could not serialize JSON body!")
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard (response as? HTTPURLResponse)?.statusCode == 200
        else {
            if (response as? HTTPURLResponse)?.statusCode == 401 {
                print("API Limit Exceeded on second API key as well!")
                let decodedData = try JSONDecoder().decode(FoodResponse.self, from: data)
                
                return decodedData
            }
            fatalError("Error fetching data!")
        }
        
        let decodedData = try JSONDecoder().decode(FoodResponse.self, from: data)
        
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
            if serving_qty == floor(serving_qty) {
                return "\(Int(serving_qty))" // Whole number case (e.g., 2.0 -> "2")
            } else {
                return String(format: "%.2f", serving_qty).replacingOccurrences(of: "\\.?0*$", with: "", options: .regularExpression)
            }
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
            if serving_qty == floor(serving_qty) {
                return "\(Int(serving_qty))" // Whole number case (e.g., 2.0 -> "2")
            } else {
                return String(format: "%.2f", serving_qty).replacingOccurrences(of: "\\.?0*$", with: "", options: .regularExpression)
            }
        }
        
        var fCalories: String {
            return nf_calories == floor(nf_calories) ? "\(Int(nf_calories))" : String(format: "%.1f", nf_calories)
        }
    }
}

// Root structure for decoding the response
struct FoodResponse: Decodable {
    var foods: [Food]
    
    struct Food: Identifiable, Codable {
        var id: String?
        var food_name: String
        var brand_name: String?
        var serving_qty: Double
        var serving_unit: String
        var serving_weight_grams: Double?
        var nf_metric_qty: Double?
        var nf_metric_uom: String?
        var nf_calories: Double
        var nf_total_fat: Double
        var nf_saturated_fat: Double?
        var nf_cholesterol: Double?
        var nf_sodium: Double?
        var nf_total_carbohydrate: Double
        var nf_dietary_fiber: Double?
        var nf_sugars: Double?
        var nf_protein: Double
        var nf_potassium: Double?
        
        var dateAdded: Timestamp?
        var mealTime: String?
        
        var fBrandName: String {
            brand_name ?? "(Generic)"
        }
        
        var fServingQty: String {
            if serving_qty == floor(serving_qty) {
                return "\(Int(serving_qty))" // Whole number case (e.g., 2.0 -> "2")
            } else {
                return String(format: "%.2f", serving_qty).replacingOccurrences(of: "\\.?0*$", with: "", options: .regularExpression)
            }
        }
        
        var fServingWeightGrams: String {
            guard let weight = serving_weight_grams else {
                guard let nfWeight = nf_metric_qty else { return "-" }
                return "\(Int(round(nfWeight))) \(nf_metric_uom ?? "units")"
            }
            return "\(Int(round(weight))) g"
        }
        
        var fCalories: String {
            "\(Int(round(nf_calories)))"
        }
        
        var fTotalFat: String {
            "\(Int(round(nf_total_fat)))"
        }
        
        var fTotalCarb: String {
            "\(Int(round(nf_total_carbohydrate)))"
        }
        
        var fTotalProtein: String {
            "\(Int(round(nf_protein)))"
        }
        
        var fSaturatedFat: String {
            guard let sFat = nf_saturated_fat else { return "-" }
            return "\(Int(round(sFat)))"
        }
        
        var fCholesterol: String {
            guard let weight = nf_cholesterol else { return "-" }
            return "\(Int(round(weight)))"
        }
        
        var fSodium: String {
            guard let weight = nf_sodium else { return "-" }
            return "\(Int(round(weight)))"
        }
        
        var fDietaryFiber: String {
            guard let weight = nf_dietary_fiber else { return "-" }
            return "\(Int(round(weight)))"
        }
        
        var fSugar: String {
            guard let weight = nf_sugars else { return "-" }
            return "\(Int(round(weight)))"
        }
        
        var fPotassium: String {
            guard let weight = nf_potassium else { return "-" }
            return "\(Int(round(weight)))"
        }
    }
}
