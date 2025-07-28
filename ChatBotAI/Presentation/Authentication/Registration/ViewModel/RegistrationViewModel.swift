//
//  RegistrationViewModel.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 2/4/25.
//

import Foundation
import UIKit
import FirebaseAuth
import Combine

@MainActor
class RegistrationViewModel: ObservableObject {

    // MARK: - Publisheds
    @Published var email = ""
    @Published var fullName = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var isLoading = false
    @Published var image: UIImage?
    @Published var shouldShowImagePicker = false
    
    @Published var emailError: String?
    @Published var fullNameError: String?
    @Published var passwordError: String?
    @Published var confirmPasswordError: String?
    @Published var authenticationError: AppError?
    
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Validation
    var isFormValid: Bool {
        return emailError == nil && fullNameError == nil && passwordError == nil && confirmPasswordError == nil &&
        !email.isEmpty && !fullName.isEmpty && !password.isEmpty && !confirmPassword.isEmpty
    }

    // MARK: - Use Cases
    private let signUpUseCase: SignUpUseCase

    // MARK: - Lifecycle functions
    init(
        signUpUseCase: SignUpUseCase
    ) {
        self.signUpUseCase = signUpUseCase
        clearErrorsOnEdit()
    }

    // MARK: - Functions
    func createUser() async {
        guard validateForm() else { return }
        
        isLoading = true
        let result = await signUpUseCase.execute(
            with: SignUpParam(email: email, fullName: fullName, password: password),
            profileImage: self.image
        )
        isLoading = false
        
        switch result {
        case .success(let user):
            print("DEBUG: Usuario registrado exitosamente: \(user.email ?? "")")
            SessionManager.shared.userSession = Auth.auth().currentUser
            PresenceManager.shared.setupPresence()
            self.resetForm()
        case .failure(let error):
            self.authenticationError = error
            print("DEBUG: Error al registrar usuario: \(error.localizedDescription)")
        }
    }
    
    private func validateForm() -> Bool {
        var isValid = true
        authenticationError = nil
        
        if !email.contains("@") {
            emailError = LocalizedKeys.Validation.emailInvalid
            isValid = false
        }
        
        if fullName.count <= 2 {
            fullNameError = LocalizedKeys.Validation.nameTooShort
            isValid = false
        }
        
        if password.count <= 5 {
            passwordError = LocalizedKeys.Validation.passwordTooShort
            isValid = false
        }
        
        if password != confirmPassword {
            confirmPasswordError = LocalizedKeys.Validation.passwordsDoNotMatch
            isValid = false
        }
        
        return isValid
    }
    
    private func clearErrorsOnEdit() {
        $email
            .dropFirst()
            .sink { [weak self] _ in self?.emailError = nil }
            .store(in: &cancellables)
        
        $fullName
            .dropFirst()
            .sink { [weak self] _ in self?.fullNameError = nil }
            .store(in: &cancellables)
        
        $password
            .dropFirst()
            .sink { [weak self] _ in
                self?.passwordError = nil
                self?.confirmPasswordError = nil }
            .store(in: &cancellables)
        
        $confirmPassword
            .dropFirst()
            .sink { [weak self] _ in self?.confirmPasswordError = nil }
            .store(in: &cancellables)
    }
    
    private func resetForm() {
        email = ""
        fullName = ""
        password = ""
        confirmPassword = ""
        image = nil
    }
}
