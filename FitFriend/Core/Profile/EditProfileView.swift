import SwiftUI

struct EditProfileView: View {
    @EnvironmentObject private var authVM: AuthViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var height         = ""
    @State private var weight         = ""
    @State private var age            = ""
    @State private var goalCalories   = ""
    @State private var carbPercent    = ""
    @State private var fatPercent     = ""
    @State private var proPercent     = ""
    @State private var newPassword    = ""
    @State private var confirmPassword = ""
    @State private var errorMessage   : String?

    private var formIsValid: Bool {
        guard
            let h = Double(height), h > 0,
            let w = Double(weight), w > 0,
            let a = Int(age), a > 0,
            let g = Int(goalCalories), g > 0,
            let cp = Double(carbPercent),
            let fp = Double(fatPercent),
            let pp = Double(proPercent),
            abs((cp + fp + pp) - 1.0) < 0.01
        else { return false }

        if !newPassword.isEmpty {
            return newPassword == confirmPassword && newPassword.count >= 6
        }
        return true
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Body Metrics") {
                    inputView(text: $height,       title: "Height (cm)",         placeholder: "e.g. 170")
                    inputView(text: $weight,       title: "Weight (kg)",         placeholder: "e.g. 65")
                    inputView(text: $age,          title: "Age",                 placeholder: "e.g. 30")
                }

                Section("Nutrition Goals") {
                    inputView(text: $goalCalories, title: "Daily Calories Goal",  placeholder: "e.g. 2000")
                    inputView(text: $carbPercent,  title: "Carb % (0–1)",        placeholder: "e.g. 0.45")
                    inputView(text: $fatPercent,   title: "Fat % (0–1)",         placeholder: "e.g. 0.25")
                    inputView(text: $proPercent,   title: "Protein % (0–1)",     placeholder: "e.g. 0.30")
                }

                Section("Change Password") {
                    SecureField("New Password",          text: $newPassword)
                    SecureField("Confirm New Password",  text: $confirmPassword)
                }

                if let msg = errorMessage {
                    Text(msg).foregroundColor(.red)
                }

                Button("Save Changes") {
                    Task {
                        do {
                            // 1️⃣ Update Firestore profile fields
                            try await authVM.updateProfile(
                                height: Double(height)!,
                                weight: Double(weight)!,
                                age: Int(age)!,
                                goalCalories: Int(goalCalories)!,
                                carbPercent: Double(carbPercent)!,
                                fatPercent: Double(fatPercent)!,
                                proPercent: Double(proPercent)!
                            )
                            // 2️⃣ Update password if provided
                            if !newPassword.isEmpty {
                                try await authVM.updatePassword(to: newPassword)
                            }
                            dismiss()
                        } catch {
                            errorMessage = error.localizedDescription
                        }
                    }
                }
                .disabled(!formIsValid)
            }
            .navigationTitle("Edit Profile")
            .onAppear {
                // Populate fields from currentUser
                if let user = authVM.currentUser {
                    height       = String(user.height)
                    weight       = String(user.weight)
                    age          = String(user.age)
                    goalCalories = String(user.goalCalories)
                    carbPercent  = String(user.carbPercent)
                    fatPercent   = String(user.fatPercent)
                    proPercent   = String(user.proPercent)
                }
            }
        }
    }
}

#Preview {
    EditProfileView()
        .environmentObject(AuthViewModel())
}
// Reuse your existing inputView
// Make sure inputView is imported or in scope
