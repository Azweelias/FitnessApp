import SwiftUI
import FirebaseAuth
import FirebaseFirestore

class FoodViewModel: ObservableObject {
    @Published var foodEntries: [FoodResponse.Food] = []
    @Published var selectedFood: FoodResponse.Food?
    @Published var totalCalories: Int = 0
    @Published var totalProtein: Int = 0
    @Published var totalFat: Int = 0
    @Published var totalCarbs: Int = 0
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private var listener: ListenerRegistration?

    /// Listens for real-time changes in food entries for a given date
    func startListening(for date: Date) {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        let startTimestamp = Timestamp(date: startOfDay)
        let endTimestamp = Timestamp(date: endOfDay)

        let query = Firestore.firestore()
            .collection("users").document(userID)
            .collection("foods")
            .whereField("dateAdded", isGreaterThanOrEqualTo: startTimestamp)
            .whereField("dateAdded", isLessThan: endTimestamp)

        // Remove previous listener (if any) to avoid duplicates
        listener?.remove()
        
        listener = query.addSnapshotListener { snapshot, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Error fetching food entries: \(error.localizedDescription)"
                }
                return
            }

            guard let documents = snapshot?.documents else { return }

            let fetchedEntries = documents.compactMap { document in
                try? document.data(as: FoodResponse.Food.self)
            }

            DispatchQueue.main.async {
                self.foodEntries = fetchedEntries
                self.totalCalories = Int(fetchedEntries.reduce(0) { $0 + $1.nf_calories })
                self.totalProtein = Int(fetchedEntries.reduce(0) { $0 + $1.nf_protein })
                self.totalFat = Int(fetchedEntries.reduce(0) { $0 + $1.nf_total_fat })
                self.totalCarbs = Int(fetchedEntries.reduce(0) { $0 + $1.nf_total_carbohydrate })
            }
        }
    }

    /// Stop listening for real-time updates
    func stopListening() {
        listener?.remove()
        listener = nil
    }
    
    func fetchFoodDetails(foodID: String) async throws {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        let foodRef = Firestore.firestore()
            .collection("users").document(userID)
            .collection("foods")
            .document(foodID)
        
        let document = try await foodRef.getDocument()
        
        if let food = try document.data(as: FoodResponse.Food?.self) {
            DispatchQueue.main.async {
                self.selectedFood = food
            }
        } else {
            DispatchQueue.main.async {
                self.errorMessage = "Food not found!"
            }
        }
    }
}
