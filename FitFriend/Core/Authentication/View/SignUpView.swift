//
//  RegisterView.swift
//  SmartHomeAutomation
//
//  Created by Zac Pana on 11/14/24.

import SwiftUI

struct SignUpView: View {
    @State private var email = ""
    @State private var fullName = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.white.opacity(0.8)]), startPoint: .top, endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)
                VStack {
                    Text("Sign-Up Info")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.top, 10)
                    
                    //image
                    Image(systemName: "lock.shield")
                        .resizable()
                        .scaledToFill()
                        .frame(width:80, height:130)
                        .padding(.vertical, 32)
                    
                    // form fields
                    VStack(spacing: 24){
                        inputView(text: $email,
                                  title: "Email Address",
                                  placeholder: "name@example.com")
                        .autocapitalization(.none)
                        
                        inputView(text: $fullName,
                                  title: "Full Name",
                                  placeholder: "John Doe")
                        
                        inputView(text: $password,
                                  title: "Password",
                                  placeholder: "Enter your password",
                                  isSecureField: true)
                        
                        ZStack(alignment: .trailing) {
                            inputView(text: $confirmPassword,
                                      title: "Confirm Password",
                                      placeholder: "Confirm your password",
                                      isSecureField: true)
                            
                            if !password.isEmpty && !confirmPassword.isEmpty {
                                if password == confirmPassword {
                                    Image(systemName: "checkmark.circle.fill")
                                        .imageScale(.large)
                                        .fontWeight(.bold)
                                        .foregroundColor(Color(.systemGreen))
                                } else {
                                    Image(systemName: "xmark.circle.fill")
                                        .imageScale(.large)
                                        .fontWeight(.bold)
                                        .foregroundColor(Color(.systemRed))
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 12)
                    
                    NavigationLink {
                        SignUpView2(email: email, fullName: fullName, password: password)
                    } label: {
                        HStack {
                            Text("Next")
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
                    
                    Button {
                        dismiss()
                    } label: {
                        HStack(spacing: 3) {
                            Image(systemName: "arrow.left")
                                .foregroundColor(.black)
                            Text("Already have an account?")
                                .foregroundColor(.black)
                            Text("Sign in")
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                        }
                        .font(.system(size: 14))
                    }
                }
            }
        }
    }
}

//Validation
extension SignUpView: AuthenticationFormProtocol {
    var formIsValid: Bool {
        return !email.isEmpty
        && email.contains("@")
        && email.contains(".")
        && !password.isEmpty
        && password.count > 5
        && confirmPassword == password
        && !fullName.isEmpty
    }
}

#Preview {
    SignUpView()
}
