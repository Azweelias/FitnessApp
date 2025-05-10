//
//  AuthViewModel.swift
//  SmartHomeAutomation
//
// This view model is responsible for handling all validation of email and password checking as well as
// connecting to the firebase user authenticator and database as well as signing in/out and deleting accounts

import Foundation
import FirebaseAuth
import FirebaseFirestore

protocol AuthenticationFormProtocol {
    var formIsValid: Bool { get }
}

@MainActor
class AuthViewModel: ObservableObject {
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User?
    
    init() {
        self.userSession = Auth.auth().currentUser
        
        Task {
            await fetchUser()
        }
    }
    
    func signIn(withEmail email: String, password: String) async throws {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.userSession = result.user
            await fetchUser()
        } catch {
            print("DEBUG: Failed to log in with error \(error.localizedDescription)")
        }
    }
    
    func createUser(withEmail email: String, password: String, fullName: String, height: Double, weight: Double, age: Int, gender: String) async throws {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.userSession = result.user
            
            let user = User(
                id: result.user.uid,
                fullName: fullName,
                email: email,
                height: height,
                weight: weight,
                age: age,
                gender: gender,
                goalCalories: 2000,
                carbPercent: 0.45,
                fatPercent: 0.25,
                proPercent: 0.3                
            )
            
            let encodedUser = try Firestore.Encoder().encode(user)
            let userRef = Firestore.firestore().collection("users").document(user.id)
            try await userRef.setData(encodedUser)
            
            await fetchUser()
        } catch {
            print("DEBUG: Failed to create user with error \(error.localizedDescription)")
            throw error
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            self.userSession = nil
            self.currentUser = nil
        } catch {
            print("DEBUG: Failed to sign out with error \(error.localizedDescription)")
        }
    }
    
    func deleteAccount() {
        
    }
    
    func fetchUser() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        Firestore.firestore().collection("users").document(uid).addSnapshotListener { snapshot, error in
            if let error = error {
                print("DEBUG: Error fetching user updates: \(error.localizedDescription)")
                return
            }
            
            guard let snapshot = snapshot else { return }
            self.currentUser = try? snapshot.data(as: User.self)
        }
    }

    
    func addFoodToUser(food: FoodResponse.Food) async throws {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        // Create a reference to a new food document (Firestore will automatically generate a unique ID)
        let foodRef = Firestore.firestore().collection("users").document(uid).collection("foods").document()
        
        // Add the document ID to the food object before saving
        var foodWithID = food
        foodWithID.id = foodRef.documentID  // Assuming `FoodResponse.Food` has an optional `id` field
        
        do {
            // Set data with the ID included
            try foodRef.setData(from: foodWithID, merge: true)
            print("Food successfully added to Firestore with date!")
        } catch {
            print("Error adding food to Firestore: \(String(describing: error))")
            throw error
        }
    }
    
        /// Update password in FirebaseAuth
        func updatePassword(to newPassword: String) async throws {
            guard let user = Auth.auth().currentUser else {
                throw NSError(domain: "Auth", code: 0, userInfo: [NSLocalizedDescriptionKey: "No current user"])
            }
            try await user.updatePassword(to: newPassword)
        }

        /// Update numeric profile fields in Firestore
        func updateProfile(
            height: Double,
            weight: Double,
            age: Int,
            goalCalories: Int,
            carbPercent: Double,
            fatPercent: Double,
            proPercent: Double
        ) async throws {
            guard let uid = Auth.auth().currentUser?.uid else {
                throw NSError(domain: "Auth", code: 0, userInfo: [NSLocalizedDescriptionKey: "No current user"])
            }
            let data: [String: Any] = [
                "height": height,
                "weight": weight,
                "age": age,
                "goalCalories": goalCalories,
                "carbPercent": carbPercent,
                "fatPercent": fatPercent,
                "proPercent": proPercent
            ]
            let ref = Firestore.firestore().collection("users").document(uid)
            try await ref.updateData(data)
            await fetchUser()    // refresh local copy
        }

}
