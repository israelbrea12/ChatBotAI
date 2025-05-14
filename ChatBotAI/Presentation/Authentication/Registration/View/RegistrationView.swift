//
//  RegistrationView.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 13/3/25.
//

import SwiftUI

struct RegistrationView: View {
    
    @StateObject var registrationViewModel = Resolver.shared.resolve(RegistrationViewModel.self)
    
    @State private var email = ""
    @State private var fullName = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            NavigationStack {
                VStack {
                    // form fields
                    VStack(spacing: 24) {
                        ImagePickerView(image: $registrationViewModel.image)
                            .padding(.top)

                        InputView(text: $email,
                                  title: "Email Address",
                                  placeholder: "name@example.com")
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .keyboardType(.emailAddress)
                        
                        InputView(text: $fullName,
                                  title: "Full Name",
                                  placeholder: "Enter your name")
                        .disableAutocorrection(true)
                                                
                        
                        InputView(text: $password,
                                  title: "Password",
                                  placeholder: "Enter your password",
                                  isSecureField: true)
                        .textInputAutocapitalization(.never)
                        
                        ZStack(alignment: .trailing) {
                            InputView(text: $confirmPassword,
                                      title: "Confirm Password",
                                      placeholder: "Confirm your password",
                                      isSecureField: true)
                            .textInputAutocapitalization(.never)
                            
                            if !password.isEmpty && !confirmPassword.isEmpty {
                                if password == confirmPassword {
                                    Image(systemName: "checkmark.circle.fill")
                                        .imageScale(.large)
                                        .fontWeight(.bold)
                                        .foregroundStyle(Color(.systemGreen))
                                } else {
                                    Image(systemName: "xmark.circle.fill")
                                        .imageScale(.large)
                                        .fontWeight(.bold)
                                        .foregroundStyle(Color(.systemRed))
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 12)
                    
                    Button {
                        Task {
                            await registrationViewModel
                                .createUser(
                                    withEmail: email,
                                    password: password,
                                    fullName: fullName
                                )
                        }
                    } label: {
                        HStack {
                            Text("Sign up")
                                .fontWeight(.semibold)
                            Image(systemName: "arrow.right")
                        }
                        .foregroundStyle(.white)
                        .frame(width: UIScreen.main.bounds.width - 32, height: 48)
                    }
                    .background(Color(.systemBlue))
                    .disabled(!formIsValid)
                    .opacity(formIsValid ? 1.0 : 0.5)
                    .cornerRadius(10)
                    .padding(.top, 40)
                    
                    Spacer()
                    
                    Button {
                        dismiss()
                    } label: {
                        HStack(spacing: 3) {
                            Text("Already have an account?")
                            Text("Sign in")
                                .fontWeight(.bold)
                        }
                        .font(.system(size: 14))
                    }
                }
                .onAppear {
                    registrationViewModel.image = nil
                    registrationViewModel.isLoading = false
                }
                .fullScreenCover(isPresented: $registrationViewModel.shouldShowImagePicker, onDismiss: nil) {
                    ImagePickerView(image: $registrationViewModel.image)
                }
            }
            
            // Pantalla de carga en el centro de la vista
            if registrationViewModel.isLoading {
                ZStack {
                    Color.black.opacity(0.3)
                        .edgesIgnoringSafeArea(.all)
                    
                    VStack {
                        ProgressView("Creating Account...")
                            .progressViewStyle(CircularProgressViewStyle())
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color.white))
                            .shadow(radius: 5)
                    }
                    .frame(maxWidth: 200)
                    .padding()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}

// MARK: - AuthenticationForm Protocol

extension RegistrationView: AuthenticationFormProtocol {
    var formIsValid: Bool {
        return !email.isEmpty
        && email.contains("@")
        && !password.isEmpty
        && password.count > 5
        && confirmPassword == password
        && !fullName.isEmpty
    }
}

#Preview {
    RegistrationView()
}
