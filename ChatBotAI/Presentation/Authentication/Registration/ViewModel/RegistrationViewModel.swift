//
//  RegistrationViewModel.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 2/4/25.
//

import Foundation
import UIKit
import FirebaseAuth

@MainActor
class RegistrationViewModel: ObservableObject {
    
    // MARK: - Publisheds
    @Published var currentUser: User?
    @Published var state: ViewState = .success
    @Published var isLoading = false
    @Published var image: UIImage?
    @Published var shouldShowImagePicker = false
    
    // MARK: - Use Cases
    private let signUpUseCase: SignUpUseCase

    // MARK: - Lifecycle functions
    init(
        signUpUseCase: SignUpUseCase
    ) {
        self.signUpUseCase = signUpUseCase
    }
    
    // MARK: - Functions
    func createUser(withEmail email: String, password: String, fullName: String) async {
        DispatchQueue.main.async { self.isLoading = true }
        let result = await signUpUseCase.execute(
            with: SignUpParam(email: email, fullName: fullName, password: password),
            profileImage: self.image
        )
        switch result {
        case .success(let user):
            DispatchQueue.main.async {
                DispatchQueue.main.async { self.isLoading = false }
                SessionManager.shared.userSession = Auth.auth().currentUser
                self.currentUser = user
                SessionManager.shared.currentUser = user
            }
        case .failure(let error):
            DispatchQueue.main.async { self.isLoading = false }
            print("DEBUG: Error al registrar usuario: \(error.localizedDescription)")
        }
    }
}
