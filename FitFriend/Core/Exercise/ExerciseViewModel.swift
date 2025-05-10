import Foundation
import FirebaseAuth
import FirebaseFirestore

struct ExerciseEntry: Identifiable, Codable {
    @DocumentID var id: String?
    let name: String
    let durationMin: Int
    let calories: Double
    let timestamp: Date
}

@MainActor
class ExerciseViewModel: ObservableObject {
    private let appID = "830f2a4a"
    private let appKey = "5dcc7a001baaddb2e6ddb678196672ee"
    private let appID2 = "180fd0fa"
    private let appKey2 = "8890d7882d41b2cc70db3d14b1dff890"
    private let contentType = "application/json"
    @Published var entries: [ExerciseEntry] = []
    @Published var errorMessage: String?
    
    private var listener: ListenerRegistration?
    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()
    
    /// Start real-time listener for today's entries
    func startListening(for date: Date) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let day = dateFormatter.string(from: date)
        listener?.remove()
        listener = Firestore.firestore()
            .collection("users").document(uid)
            .collection("exercises").document(day)
            .collection("entries")
            .order(by: "timestamp", descending: true)
            .addSnapshotListener { snap, error in
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    return
                }
                self.entries = snap?.documents.compactMap {
                    try? $0.data(as: ExerciseEntry.self)
                } ?? []
            }
    }
    
    /// Logs a new exercise: calls the Syndigo NL API, then writes results to Firestore
    func logExercise(type: String, duration: Int) async {
        guard let user = Auth.auth().currentUser,
              let profile = try? await Firestore.firestore().collection("users").document(user.uid).getDocument(as: User.self)
        else {
            self.errorMessage = "User data unavailable"
            return
        }
        
        // Build the natural-language query
        let nlQuery = "\(type) for \(duration) minutes"
        
        // Prepare payload per Syndigo spec
        let payload: [String: Any] = [
            "query": nlQuery,
            "gender": profile.gender.lowercased(),
            "weight_kg": profile.weight,
            "height_cm": profile.height,
            "age": profile.age
        ]
        
        // Configure request
        guard let url = URL(string: "https://trackapi.nutritionix.com/v2/natural/exercise") else {
            self.errorMessage = "Invalid API URL"
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue(appID, forHTTPHeaderField: "x-app-id")
        request.addValue(appKey, forHTTPHeaderField: "x-app-key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload)
            let (data, _) = try await URLSession.shared.data(for: request)
            
            // Decode response
            struct APIResponse: Decodable {
                struct Item: Decodable {
                    let name: String
                    let duration_min: Int
                    let nf_calories: Double
                }
                let exercises: [Item]
            }
            let api = try JSONDecoder().decode(APIResponse.self, from: data)
            
            // Write each exercise to Firestore
            let uid = user.uid
            let day = dateFormatter.string(from: Date())
            let baseRef = Firestore.firestore()
                .collection("users").document(uid)
                .collection("exercises").document(day)
                .collection("entries")
            
            for item in api.exercises {
                let doc = baseRef.document()
                let entry = ExerciseEntry(
                    id: doc.documentID,
                    name: item.name,
                    durationMin: item.duration_min,
                    calories: item.nf_calories,
                    timestamp: Date()
                )
                try doc.setData(from: entry)
            }
            
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    func deleteEntry(_ entry: ExerciseEntry) async {
            guard let uid   = Auth.auth().currentUser?.uid,
                  let id    = entry.id else { return }
            
            let day = dateFormatter.string(from: Date())
            let docRef = Firestore.firestore()
                .collection("users").document(uid)
                .collection("exercises").document(day)
                .collection("entries")
                .document(id)
            
            do {
                try await docRef.delete()
            } catch {
                self.errorMessage = error.localizedDescription
            }
        }
    
    deinit {
        listener?.remove()
    }
}
