//
//  User.swift
//  SmartHomeAutomation
//
//  Created by Zac Pana on 11/14/24.
//

import Foundation

struct User: Identifiable, Codable {
    let id: String
    let fullName: String
    let email: String
    let height: Double
    let weight: Double
    let age: Int
    let gender: String
    let goalCalories: Int
    let carbPercent: Double
    let fatPercent: Double
    let proPercent: Double
    
    var initials: String {
        let formatter = PersonNameComponentsFormatter()
        if let components = formatter.personNameComponents(from: fullName) {
            formatter.style = .abbreviated
            return formatter.string(from: components)
        }
            
        return ""
    }
    var firstName: String {
        let formatter = PersonNameComponentsFormatter()
        if let components = formatter.personNameComponents(from: fullName),
           let givenName = components.givenName {
            return givenName
        }
        
        return ""
    }
}

extension User {
    static var MOCK_USER = User(id: NSUUID().uuidString, fullName: "Eli Dawarpana", email: "test@gmail.com", height: 72.0, weight: 200.0, age: 26, gender: "Male", goalCalories: 2000, carbPercent: 0.45, fatPercent: 0.25, proPercent: 0.3)
}
