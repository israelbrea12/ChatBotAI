//
//  LoginViewModel.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 2/4/25.
//

import Foundation
import FirebaseCore
import GoogleSignIn
import FirebaseAuth
import Combine

@MainActor
class LoginViewModel: ObservableObject {
    
    // MARK: - Publisheds
    @Published var currentUser: User?
    @Published var state: ViewState = .success
    @Published var isLoading = false
    @Published var image: UIImage?
    @Published var shouldShowImagePicker = false
    @Published var email = ""
    @Published var password = ""
    
    @Published var emailError: String?
    @Published var passwordError: String?
    @Published var authenticationError: AppError?
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Validation
    var isFormValid: Bool {
        return emailError == nil && passwordError == nil && !email.isEmpty && !password.isEmpty
    }
    
    // MARK: - Use Cases
    private let signInUseCase: SignInUseCase
    private let signInWithGoogleUseCase: SignInWithGoogleUseCase
    private let signInWithAppleUseCase: SignInWithAppleUseCase
    
    // MARK: - Lifecycle functions
    init(
        signInUseCase: SignInUseCase,
        signInWithGoogleUseCase: SignInWithGoogleUseCase,
        signInWithAppleUseCase: SignInWithAppleUseCase
    ) {
        self.signInUseCase = signInUseCase
        self.signInWithGoogleUseCase = signInWithGoogleUseCase
        self.signInWithAppleUseCase = signInWithAppleUseCase
        clearErrorsOnEdit()
    }
    
    // MARK: - Functions
    func signIn() async {
        guard validateForm() else { return }
        
        isLoading = true
        let result = await signInUseCase.execute(with: SignInParam(email: email, password: password))
        isLoading = false
        
        switch result {
        case .success(let user):
            self.currentUser = user
            SessionManager.shared.userSession = Auth.auth().currentUser
            PresenceManager.shared.setupPresence()
            self.resetForm()
        case .failure(let error):
            self.authenticationError = error
            print("DEBUG: Sign-in error \(error.localizedDescription)")
        }
    }
    
    func signInWithGoogle() async {
        let result = await signInWithGoogleUseCase.execute()
        switch result {
        case .success(let user):
            DispatchQueue.main.async {
                PresenceManager.shared.setupPresence()
                self.currentUser = user
            }
        case .failure(let error):
            print("DEBUG: Error signing in with Google: \(error.localizedDescription)")
        }
    }
    
    func signInWithApple() async {
        let result = await signInWithAppleUseCase.execute()
        switch result {
        case .success(let user):
            DispatchQueue.main.async {
                PresenceManager.shared.setupPresence()
                self.currentUser = user
            }
        case .failure(let error):
            print("DEBUG: Error signing in with Google: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Private functions
    private func clearErrorsOnEdit() {
        $email
            .dropFirst()
            .sink { [weak self] _ in self?.emailError = nil }
            .store(in: &cancellables)
        
        $password
            .dropFirst()
            .sink { [weak self] _ in self?.passwordError = nil }
            .store(in: &cancellables)
    }
    
    private func validateForm() -> Bool {
        var isValid = true
        authenticationError = nil
        
        if !email.contains("@") {
            emailError = LocalizedKeys.Validation.emailInvalid
            isValid = false
        }
        
        if password.count <= 5 {
            passwordError = LocalizedKeys.Validation.passwordTooShort
            isValid = false
        }
        
        return isValid
    }
    
    private func resetForm() {
        email = ""
        password = ""
    }
}

