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
            
            Text(LocalizedKeys.Auth.forgotPassword)
                .font(.largeTitle)
                .fontWeight(.heavy)
                .padding(.top, 5)
            
            Text(LocalizedKeys.Auth.resetPasswordLink)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.gray)
                .padding(.top, -5)
            
            VStack(spacing: 25) {
                CustomTF(sfIcon: "at", hint: LocalizedKeys.Placeholder.emailPlaceholder, value: $forgotPasswordViewModel.email)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                
                GradientButton(title: LocalizedKeys.Auth.linkSentTitle, icon: "arrow.right") {
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
        .alert(forgotPasswordViewModel.alertTitle, isPresented: $forgotPasswordViewModel.showAlert) {
            Button(LocalizedKeys.Common.ok) {
                if forgotPasswordViewModel.alertTitle == LocalizedKeys.Auth.linkSentTitle {
                    dismiss()
                }
            }
        } message: {
            Text(forgotPasswordViewModel.alertMessage)
        }
    }
}
