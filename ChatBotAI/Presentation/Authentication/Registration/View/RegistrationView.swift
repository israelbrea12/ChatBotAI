//
//  RegistrationView.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 13/3/25.
//

import SwiftUI

struct SignUpView: View {
    @StateObject var registrationViewModel = Resolver.shared.resolve(RegistrationViewModel.self)
    @Binding var showSignup: Bool
    
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                ZStack {
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 15) {
                            Button(action: {
                                showSignup = false
                            }, label: {
                                Image(systemName: "arrow.left")
                                    .font(.title2)
                                    .foregroundStyle(.gray)
                            })
                            .padding(.top, 10)
                            
                            Text(LocalizedKeys.Auth.signupTitle)
                                .font(.largeTitle)
                                .fontWeight(.heavy)
                                .padding(.top, 10)
                            
                            Text(LocalizedKeys.Auth.signupToContinue)
                                .font(.callout)
                                .fontWeight(.semibold)
                                .foregroundStyle(.gray)
                                .padding(.top, -5)
                            
                            VStack(spacing: 25) {
                                ImagePickerView(image: $registrationViewModel.image)
                                    .padding(.top)
                                
                                CustomTF(sfIcon: "at", hint: LocalizedKeys.Placeholder.emailPlaceholder, value: $registrationViewModel.email, error: registrationViewModel.emailError)
                                                    
                                CustomTF(sfIcon: "person", hint: LocalizedKeys.Placeholder.fullnamePlaceholder, value: $registrationViewModel.fullName, error: registrationViewModel.fullNameError)
                                                
                                CustomTF(sfIcon: "lock", hint: LocalizedKeys.Placeholder.passwordPlaceholder, isPassword: true, value: $registrationViewModel.password, error: registrationViewModel.passwordError)
                                                
                                CustomTF(sfIcon: "lock.fill", hint: LocalizedKeys.Placeholder.confirmPasswordPlaceholder, isPassword: true, value: $registrationViewModel.confirmPassword, error: registrationViewModel.confirmPasswordError)
                                
                                if let error = registrationViewModel.authenticationError {
                                    Text(error.localizedDescription)
                                        .font(.caption)
                                        .foregroundStyle(.red)
                                        .frame(maxWidth: .infinity, alignment: .trailing)
                                }
                                
                                GradientButton(title: LocalizedKeys.Auth.signupTitle, icon: "arrow.right") {
                                    Task { await registrationViewModel.createUser() }
                                }
                                .hSpacing(.trailing)
                                .disabled(!registrationViewModel.isFormValid)
                                .opacity(registrationViewModel.isFormValid ? 1 : 0.6)
                            }
                            .padding(.top, 20)
                            
                            Spacer(minLength: 0)
                            
                            HStack(spacing: 6) {
                                Text(LocalizedKeys.Auth.alreadyHaveAccount)
                                    .foregroundStyle(.gray)
                                
                                Button(LocalizedKeys.Auth.loginTitle) {
                                    showSignup = false
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
            }
            .padding(.vertical, 15)
            .padding(.horizontal, 25)
            .toolbar(.hidden, for: .navigationBar)
            .fullScreenCover(isPresented: $registrationViewModel.shouldShowImagePicker) {
                ImagePickerView(image: $registrationViewModel.image)
            }
            
            if registrationViewModel.isLoading {
                LoadingView(message: LocalizedKeys.LoadingState.creatingAccount)
                    .ignoresSafeArea()
            }
        }
    }
}
