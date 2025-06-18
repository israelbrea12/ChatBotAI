//
//  ForgotPasswordView.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 18/6/25.
//


// MARK: ForgotPasswordView.swift

import SwiftUI

struct ForgotPasswordView: View {
    @State private var emailID: String = ""
    // Deberías tener un ViewModel para esta lógica también
    // @StateObject var forgotPasswordVM = ...
    
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
                CustomTF(sfIcon: "at", hint: "Email ID", value: $emailID)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                
                GradientButton(title: "Send Link", icon: "arrow.right") {
                    // Aquí va tu lógica para enviar el email de recuperación
                    // Task {
                    //     await viewModel.sendPasswordResetLink(to: emailID)
                    // }
                    // Una vez enviado, cerramos la vista
                    dismiss()
                }
                .hSpacing(.trailing)
                .disableWithOpacity(emailID.isEmpty)
            }
            .padding(.top, 20)
            
            Spacer()
        }
        .padding(.vertical, 15)
        .padding(.horizontal, 25)
        .interactiveDismissDisabled()
    }
}
