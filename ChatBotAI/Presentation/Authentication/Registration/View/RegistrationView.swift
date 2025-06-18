//
//  RegistrationView.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 13/3/25.
//

// MARK: SignUpView.swift

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
                            
                            Text("Sign Up")
                                .font(.largeTitle)
                                .fontWeight(.heavy)
                                .padding(.top, 10)
                            
                            Text("Please sign up to continue")
                                .font(.callout)
                                .fontWeight(.semibold)
                                .foregroundStyle(.gray)
                                .padding(.top, -5)
                            
                            VStack(spacing: 25) {
                                ImagePickerView(image: $registrationViewModel.image)
                                    .padding(.top)
                                
                                CustomTF(sfIcon: "at", hint: "Email Address", value: $registrationViewModel.email)
                                    .keyboardType(.emailAddress)
                                    .textInputAutocapitalization(.never)
                                
                                CustomTF(sfIcon: "person", hint: "Full Name", value: $registrationViewModel.fullName)
                                
                                CustomTF(sfIcon: "lock", hint: "Password", isPassword: true, value: $registrationViewModel.password)
                                
                                CustomTF(sfIcon: "lock.fill", hint: "Confirm Password", isPassword: true, value: $registrationViewModel.confirmPassword)
                                
                                GradientButton(title: "Sign Up", icon: "arrow.right") {
                                    Task {
                                        await registrationViewModel.createUser()
                                    }
                                }
                                .hSpacing(.trailing)
                                .disableWithOpacity(!registrationViewModel.formIsValid)
                            }
                            .padding(.top, 20)
                            
                            Spacer(minLength: 0)
                            
                            HStack(spacing: 6) {
                                Text("Already have an account?")
                                    .foregroundStyle(.gray)
                                
                                Button("Login") {
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
                .padding(.vertical, 15)
                .padding(.horizontal, 25)
            }
            .toolbar(.hidden, for: .navigationBar)
            .fullScreenCover(isPresented: $registrationViewModel.shouldShowImagePicker) {
                ImagePickerView(image: $registrationViewModel.image)
            }
            
            if registrationViewModel.isLoading {
                LoadingView(message: "Creating Account...")
                    .ignoresSafeArea()
            }
        }
    }
}
