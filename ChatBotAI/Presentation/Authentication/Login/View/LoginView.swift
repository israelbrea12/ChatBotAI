//
//  LoginView.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 13/3/25.
//

// MARK: LoginView.swift

import SwiftUI
import GoogleSignIn
import GoogleSignInSwift

struct LoginView: View {
    @StateObject var loginViewModel = Resolver.shared.resolve(LoginViewModel.self)
    @Binding var showSignup: Bool
    
    @State private var showForgotPasswordView: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 15) {
                    Spacer(minLength: 0)
                    
                    Text("Login")
                        .font(.largeTitle)
                        .fontWeight(.heavy)
                    
                    Text("Please sign in to continue")
                        .font(.callout)
                        .fontWeight(.semibold)
                        .foregroundStyle(.gray)
                        .padding(.top, -5)
                    
                    VStack(spacing: 25) {
                        CustomTF(sfIcon: "at", hint: "Email Address", value: $loginViewModel.email, error: loginViewModel.emailError)
                        
                        CustomTF(sfIcon: "lock", hint: "Password", isPassword: true, value: $loginViewModel.password, error: loginViewModel.passwordError)
                            .padding(.top, 5)
                        
                        Button("Forgot Password?") {
                            showForgotPasswordView.toggle()
                        }
                        .font(.callout)
                        .tint(.appBlue)
                        .hSpacing(.trailing)
                        
                        if let error = loginViewModel.authenticationError {
                            Text(error.localizedDescription)
                                .font(.caption)
                                .foregroundStyle(.red)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                        }

                        GradientButton(title: "Login", icon: "arrow.right") {
                            Task { await loginViewModel.signIn() }
                        }
                        .hSpacing(.trailing)
                        .disabled(!loginViewModel.isFormValid)
                        .opacity(loginViewModel.isFormValid ? 1 : 0.6)
                    }
                    .padding(.top, 20)
                    
                    orDivider()
                    
                    socialLoginButtons()

                    Spacer(minLength: 0)
                    
                    HStack(spacing: 6) {
                        Text("Don't have an account?")
                            .foregroundStyle(.gray)
                        
                        Button("SignUp") {
                            showSignup.toggle()
                        }
                        .fontWeight(.bold)
                        .tint(.appBlue)
                    }
                    .font(.callout)
                    .hSpacing()
                }
                .frame(minHeight: geometry.size.height)
            }
        }
        .padding(.vertical, 15)
        .padding(.horizontal, 25)
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $showForgotPasswordView) {
            ForgotPasswordView()
                .presentationDetents([.height(300)])
                .presentationCornerRadius(30)
        }
    }
    
    @ViewBuilder
    private func orDivider() -> some View {
        HStack {
            VStack { Divider() }
            Text("or")
                .foregroundStyle(.gray)
            VStack { Divider() }
        }
        .padding(.top, 20)
    }
    
    @ViewBuilder
    private func socialLoginButtons() -> some View {
        VStack(spacing: 12) {
            
            // Boton de Google
            Button {
                Task {
                    await loginViewModel.signInWithGoogle()
                }
            } label: {
                HStack {
                    Image("google_icon")
                        .resizable()
                        .frame(width: 20, height: 20)
                    Text("Sign in with Google")
                        .fontWeight(.semibold)
                }
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color(.systemGray6))
                .cornerRadius(10)
            }
            
            // Botón de Apple
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
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.black)
                .cornerRadius(10)
            }
        }
        .padding(.top, 15)
    }
}
