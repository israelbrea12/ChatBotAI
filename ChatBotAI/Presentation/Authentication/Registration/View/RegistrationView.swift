//
//  RegistrationView.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 13/3/25.
//

import SwiftUI

struct RegistrationView: View {
    
    @StateObject var registrationViewModel = Resolver.shared.resolve(RegistrationViewModel.self)
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            NavigationStack {
                VStack {
                    // form fields
                    VStack(spacing: 24) {
                        ImagePickerView(image: $registrationViewModel.image)
                            .padding(.top)
                        
                        InputView(text: $registrationViewModel.email, // Bind to ViewModel
                                  title: "Email Address",
                                  placeholder: "name@example.com")
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .keyboardType(.emailAddress)
                        
                        InputView(text: $registrationViewModel.fullName, // Bind to ViewModel
                                  title: "Full Name",
                                  placeholder: "Enter your name")
                        .disableAutocorrection(true)
                        
                        InputView(text: $registrationViewModel.password, // Bind to ViewModel
                                  title: "Password",
                                  placeholder: "Enter your password",
                                  isSecureField: true)
                        .textInputAutocapitalization(.never)
                        
                        ZStack(alignment: .trailing) {
                            InputView(text: $registrationViewModel.confirmPassword, // Bind to ViewModel
                                      title: "Confirm Password",
                                      placeholder: "Confirm your password",
                                      isSecureField: true)
                            .textInputAutocapitalization(.never)
                            
                            if !registrationViewModel.password.isEmpty && !registrationViewModel.confirmPassword.isEmpty {
                                if registrationViewModel.password == registrationViewModel.confirmPassword {
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
                            await registrationViewModel.createUser() // ViewModel usa sus propias propiedades
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
                    .disabled(!registrationViewModel.formIsValid) // Ahora el ViewModel lo expone
                    .opacity(registrationViewModel.formIsValid ? 1.0 : 0.5)
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
                    // Si el ViewModel maneja los estados de los campos de texto, no necesitas resetear aquí
                    registrationViewModel.image = nil
                    registrationViewModel.isLoading = false
                }
                // Aquí el fullScreenCover está bien si ImagePickerView es un componente común
                .fullScreenCover(isPresented: $registrationViewModel.shouldShowImagePicker, onDismiss: nil) {
                    ImagePickerView(image: $registrationViewModel.image)
                }
            }
            
            // Pantalla de carga, puedes hacerla un componente reutilizable si la usas en otros sitios
            if registrationViewModel.isLoading {
                LoadingView(message: "Creating Account...") // Ejemplo de componente reutilizable
            }
        }
    }
}

#Preview {
    RegistrationView()
}
