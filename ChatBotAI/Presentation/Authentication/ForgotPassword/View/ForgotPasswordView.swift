//
//  ForgotPasswordView.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 18/6/25.
//

import SwiftUI

struct ForgotPasswordView: View {
    
    @StateObject var forgotPasswordViewModel = Resolver.shared.resolve(ForgotPasswordViewModel.self)
    
    @Environment(\.dismiss) private var dismiss
        
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Button(action: {
                dismiss()
            }, label: {
                Image(systemName: "xmark")
                    .font(.title2)
                    .foregroundStyle(.gray)
            })
            .padding(.top, 10)
            
            Text("Forgot Password?")
                .font(.largeTitle)
                .fontWeight(.heavy)
                .padding(.top, 5)
            
            Text("Please enter your Email ID so that we can send the reset link.")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.gray)
                .padding(.top, -5)
            
            VStack(spacing: 25) {
                // Vincula el CustomTF con el email del ViewModel
                CustomTF(sfIcon: "at", hint: "Email ID", value: $forgotPasswordViewModel.email)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                
                // Llama a la función del ViewModel
                GradientButton(title: "Send Link", icon: "arrow.right") {
                    Task {
                        await forgotPasswordViewModel.sendPasswordResetLink()
                    }
                }
                .hSpacing(.trailing)
                .disableWithOpacity(forgotPasswordViewModel.email.isEmpty || forgotPasswordViewModel.isLoading)
            }
            .padding(.top, 20)
            
            Spacer()
        }
        .padding(.vertical, 15)
        .padding(.horizontal, 25)
        .interactiveDismissDisabled()
        // Alerta para mostrar el resultado al usuario
        .alert(forgotPasswordViewModel.alertTitle, isPresented: $forgotPasswordViewModel.showAlert) {
            Button("OK") {
                if forgotPasswordViewModel.alertTitle == "Enlace Enviado" {
                    dismiss()
                }
            }
        } message: {
            Text(forgotPasswordViewModel.alertMessage)
        }
    }
}
