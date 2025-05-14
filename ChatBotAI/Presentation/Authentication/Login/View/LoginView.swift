//
//  LoginView.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 13/3/25.
//

import SwiftUI
import GoogleSignIn
import GoogleSignInSwift

struct LoginView: View {
    @StateObject var loginViewModel = Resolver.shared.resolve(LoginViewModel.self)
    
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        NavigationStack {
            VStack {
                // image
                Image("logo_firebase")
                    .resizable()
                    .scaledToFit()
                    .padding(32)
                
                // form fields
                VStack(spacing: 24) {
                    InputView(text: $email,
                              title: "Email Address",
                              placeholder: "name@example.com")
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    
                    InputView(text: $password,
                              title: "Password", placeholder: "Enter your password",
                              isSecureField: true)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)

                }
                .padding(.horizontal, 24)
                .padding(.top, 40)
                
                // sign in button
                Button {
                    Task {
                        await loginViewModel.signIn(withEmail: email, password: password)
                    }
                } label: {
                    HStack {
                        Text("Sign in")
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
                .padding(.top, 24)
                
                HStack {
                    Divider()
                        .frame(maxWidth: .infinity, maxHeight: 1)
                        .background(Color(.systemGray5))
                    Text("or")
                        .foregroundColor(.gray)
                        .padding(.horizontal, 8)
                    Divider()
                        .frame(maxWidth: .infinity, maxHeight: 1)
                        .background(Color(.systemGray5))
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)

                Button {
                    Task {
                        await loginViewModel.signInWithGoogle()
                    }
                } label: {
                    HStack {
                        Image("google_icon") // Asegúrate de agregar un icono de Google
                            .resizable()
                            .frame(width: 20, height: 20)
                        Text("Sign in with Google")
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.black)
                    .frame(width: UIScreen.main.bounds.width - 32, height: 38)
                }
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.top, 12)

                Button {
                    Task {
                            await loginViewModel.signInWithApple()
                        }
                                } label: {
                                    HStack {
                                        Image(systemName: "applelogo")
                                        Text("Sign in with Apple")
                                            .fontWeight(.semibold)
                                    }
                                    .foregroundColor(.white)
                                    .frame(width: UIScreen.main.bounds.width - 32, height: 38)
                                }
                                .background(Color.black)
                                .cornerRadius(10)
                                .padding(.top, 12)
                
                Spacer()
                
                // sign up button
                NavigationLink {
                    RegistrationView()
                        .navigationBarBackButtonHidden(true)
                } label: {
                    HStack(spacing: 3) {
                        Text("Don't have an account?")
                        Text("Sign up")
                            .fontWeight(.bold)
                    }
                    .font(.system(size: 14))
                }
                
            }
        }
        
    }
}

// MARK: - AuthenticationForm Protocol

extension LoginView: AuthenticationFormProtocol {
    var formIsValid: Bool {
        return !email.isEmpty
        && email.contains("@")
        && !password.isEmpty
        && password.count > 5
    }
}

#Preview {
    LoginView()
}
