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
    
    var initials: String {
        let formatter = PersonNameComponentsFormatter()
        if let components = formatter.personNameComponents(from: fullName) {
            formatter.style = .abbreviated
            return formatter.string(from: components)
        }
            
        return ""
    }
}

extension User {
    static var MOCK_USER = User(id: NSUUID().uuidString, fullName: "Eli Dawarpana", email: "test@gmail.com", height: 72.0, weight: 200.0, age: 26, gender: "Male")
}
