import Foundation
import FirebaseAuth
import FirebaseFirestore

@MainActor
class HydrationViewModel: ObservableObject {
    @Published var cups: Int = 0
    private var listener: ListenerRegistration?
    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()
    private let dailyGoalCups = 8

    /// Start real-time listener
    func startListening(for date: Date) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let dateString = dateFormatter.string(from: date)
        let docRef = Firestore.firestore()
            .collection("users")
            .document(uid)
            .collection("hydration")
            .document(dateString)

        listener?.remove()
        listener = docRef.addSnapshotListener { snap, _ in
            self.cups = snap?.data()?["cups"] as? Int ?? 0
        }
    }

    /// Add one cup (8oz)
    func addCup() async {
        await updateCups(by: +1)
    }
    /// Remove one cup (down to 0)
    func removeCup() async {
        await updateCups(by: -1)
    }

    private func updateCups(by delta: Int) async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let dateString = dateFormatter.string(from: Date())
        let newCups = max(0, cups + delta)
        // Update local first for UI snappiness
        self.cups = newCups

        let docRef = Firestore.firestore()
            .collection("users")
            .document(uid)
            .collection("hydration")
            .document(dateString)
        do {
            try await docRef.setData(["cups": newCups], merge: true)
        } catch {
            print("Hydration write failed:", error)
        }
    }

    deinit {
        listener?.remove()
    }
}
