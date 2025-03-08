//
//  LoginView.swift
//  SmartHomeAutomation
//
//  Created by Zac Pana on 11/14/24.
//

import SwiftUI
import Foundation

struct SignInEmailView: View {
    @State private var email = ""
    @State private var password = ""
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var showValidationHints = false
    
    var body: some View {
        NavigationStack{
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.white.opacity(0.8)]), startPoint: .top, endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)
                
                VStack{
                    Text("FitFriend")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.top, 10)
                    
                    //image
                    Image(systemName: "figure.run.circle")
                        .resizable()
                        .scaledToFill()
                        .frame(width:80, height:130)
                        .padding(.vertical, 32)
                    
                    // form fields
                    VStack(spacing: 24){
                        // Email field with validation hint
                        VStack(alignment: .leading, spacing: 4) {
                            
                            inputView(text: $email,
                                      title: "Email Address",
                                      placeholder: "name@example.com")
                            .autocapitalization(.none)
                            
                            if showValidationHints {
                                if email.isEmpty {
                                    Text("Email is required")
                                        .font(.caption)
                                        .foregroundColor(.red)
                                } else if !email.contains("@") || !email.contains(".") {
                                    Text("Missing '@' or period symbol")
                                        .font(.caption)
                                        .foregroundColor(.red)
                                }
                            }
                        }
                        
                        // Password field with validation hints
                        VStack (alignment: .leading, spacing: 4) {
                            inputView(text: $password,
                                      title: "Password",
                                      placeholder: "Enter your password",
                                      isSecureField: true)
                            if showValidationHints {
                                if password.isEmpty {
                                    Text("Password cannot be empty")
                                        .font(.caption)
                                        .foregroundColor(.red)
                                } else if password.count <= 5 {
                                    Text("Password must be at least 6 characters")
                                        .font(.caption)
                                        .foregroundColor(.red)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 12)
                    
                    //sign in button
                    Button {
                        Task {
                            try await viewModel.signIn(withEmail: email, password: password)
                        }
                    } label: {
                        HStack {
                            Text("SIGN IN")
                                .fontWeight(.semibold)
                            Image(systemName: "arrow.right")
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
                    
                    //sign up button
                    NavigationLink(){
                        SignUpView()
                            .navigationBarBackButtonHidden(true)
                    } label: {
                        HStack(spacing: 3) {
                            Text("Don't have an account?")
                                .foregroundColor(.black)
                            Text("Sign Up")
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                            Image(systemName: "arrow.right")
                                .foregroundColor(.black)
                        }
                        .font(.system(size: 14))
                    }
                }
            }
            .onAppear {
                // Delay the validation hints by 15 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 15000) {
                    showValidationHints = true
                }
            }
        }
    }
}

//Validation
extension SignInEmailView: AuthenticationFormProtocol {
    var formIsValid: Bool {
        return !email.isEmpty
        && email.contains("@")
        && email.contains(".")
        && !password.isEmpty
        && password.count > 5
    }
}

#Preview {
    SignInEmailView()
}
