//
//  ForgotPasswordViewModel.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 4/7/25.
//


import Foundation
import Combine

@MainActor
class ForgotPasswordViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var email: String = ""
    @Published var isLoading: Bool = false
    @Published var showAlert: Bool = false
    @Published var alertTitle: String = ""
    @Published var alertMessage: String = ""
    
    // MARK: - Use Case
    private let sendPasswordResetUseCase: SendPasswordResetUseCase
    
    init(sendPasswordResetUseCase: SendPasswordResetUseCase) {
        self.sendPasswordResetUseCase = sendPasswordResetUseCase
    }
    
    // MARK: - Functions
    func sendPasswordResetLink() async {
        isLoading = true
        let result = await sendPasswordResetUseCase.execute(with: SendPasswordResetParams(email: email))
        isLoading = false
        
        switch result {
        case .success:
            self.alertTitle = LocalizedKeys.Auth.linkSentTitle
            self.alertMessage = LocalizedKeys.Auth.linkSentMessage
            self.showAlert = true
        case .failure(let error):
            self.alertTitle = "Error"
            self.alertMessage = error.localizedDescription
            print("DEBUG: Error sending Password Reset Link: \(error.localizedDescription)")
            self.showAlert = true
        }
    }
}
