//
//  SignUpView2.swift
//  FitFriend
//
//  Created by Zac Pana on 11/14/24.

import SwiftUI

struct SignUpView2: View {
    let email: String
    let fullName: String
    let password: String
    
    @State private var height = ""
    @State private var weight = ""
    @State private var age = ""
    @State private var gender = "Male" // Default selection
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: AuthViewModel

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.white.opacity(0.8)]),
                               startPoint: .top,
                               endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)

                VStack {
                    Text("Personal Health Info")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.top, 10)
                    
                    // Image
                    Image(systemName: "heart.text.clipboard")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 80, height: 130)
                        .padding(.vertical, 32)
                    
                    // Form Fields
                    VStack(spacing: 24) {
                        // Height (Number-only input)
                        inputView(text: $height,
                                  title: "Height (cm)",
                                  placeholder: "Enter your height")
                        .keyboardType(.numberPad)
                        
                        // Weight (Number-only input)
                        inputView(text: $weight,
                                  title: "Weight (kg)",
                                  placeholder: "Enter your weight")
                        .keyboardType(.numberPad)
                        
                        // Age (Number-only input)
                        inputView(text: $age,
                                  title: "Age",
                                  placeholder: "Enter your age (10-120)")
                        .keyboardType(.numberPad)

                        // Gender (Dropdown)
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Gender")
                                .font(.footnote)
                                .fontWeight(.semibold)
                                .foregroundColor(Color(.darkGray))
                            
                            Picker("Select Gender", selection: $gender) {
                                Text("Male").tag("Male")
                                Text("Female").tag("Female")
                            }
                            .pickerStyle(.segmented)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.blue).opacity(0.1))
                            .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 12)
                    
                    // Create Account Button
                    Button {
                        Task {
                            try await viewModel.createUser(
                                withEmail: email,
                                password: password,
                                fullName: fullName,
                                height: Double(height) ?? 0.0,
                                weight: Double(weight) ?? 0.0,
                                age: Int(age) ?? 0,
                                gender: gender
                            )
                        }
                    } label: {
                        HStack {
                            Text("Create Account")
                                .fontWeight(.semibold)
                            Image(systemName: "checkmark.circle")
                        }
                        .foregroundColor(.white)
                        .frame(width: UIScreen.main.bounds.width - 32, height: 48)
                    }
                    .background(Color(.systemBlue))
                    .disabled(!formIsValid)
                    .opacity(formIsValid ? 1.0 : 0.5)
                    .cornerRadius(15)
                    .padding(.top, 24)
                    
                    Spacer()
                    
                    // Back Button
                    Button {
                        dismiss()
                    } label: {
                        HStack(spacing: 3) {
                            Image(systemName: "arrow.left")
                                .foregroundColor(.black)
                            Text("Back to Previous Step")
                                .foregroundColor(.black)
                        }
                        .font(.system(size: 14))
                    }
                }
            }
        }
    }
}

// Validation
extension SignUpView2: AuthenticationFormProtocol {
    var formIsValid: Bool {
        return !height.isEmpty
        && !weight.isEmpty
        && !age.isEmpty
        && Double(height) != nil
        && Double(weight) != nil
        && Int(age) != nil
        && Int(age)! >= 10 && Int(age)! < 120
    }
}

#Preview {
    SignUpView2(email: "test@example.com",
                fullName: "John Doe",
                password: "password123")
}
