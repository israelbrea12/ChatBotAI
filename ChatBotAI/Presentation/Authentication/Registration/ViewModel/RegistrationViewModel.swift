//
//  RegistrationViewModel.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 2/4/25.
//

import Foundation
import UIKit
import FirebaseAuth // Solo para User, pero idealmente se mapea a un UserEntity/UserModel

@MainActor
class RegistrationViewModel: ObservableObject {

    // MARK: - Publisheds
    @Published var currentUser: User?
    @Published var email = ""
    @Published var fullName = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var isLoading = false
    @Published var image: UIImage?
    @Published var shouldShowImagePicker = false
    @Published var authenticationError: AppError? // Para manejar y mostrar errores al usuario

    // MARK: - Validation
    // Computed property para la validación del formulario
    var formIsValid: Bool {
        return !email.isEmpty
        && email.contains("@")
        && !password.isEmpty
        && password.count > 5
        && confirmPassword == password
        && !fullName.isEmpty
    }

    // MARK: - Use Cases
    private let signUpUseCase: SignUpUseCase

    // MARK: - Lifecycle functions
    init(
        signUpUseCase: SignUpUseCase
    ) {
        self.signUpUseCase = signUpUseCase
    }

    // MARK: - Functions
    func createUser() async {
        guard formIsValid else {
            authenticationError = AppError.validationError("Formulario inválido. Por favor, revisa tus datos.")
            return
        }

        isLoading = true
        
        let result = await signUpUseCase.execute(
            with: SignUpParam(email: email, fullName: fullName, password: password),
            profileImage: self.image
        )

        switch result {
        case .success(let user):
            print("DEBUG: Usuario registrado exitosamente: \(user.email ?? "")")
            DispatchQueue.main.async {
                self.isLoading = false
                SessionManager.shared.userSession = Auth.auth().currentUser
                self.currentUser = user
                SessionManager.shared.currentUser = user
            }
            authenticationError = nil

        case .failure(let error):
            print("DEBUG: Error al registrar usuario: \(error.localizedDescription)")
            authenticationError = AppError.unknownError(error.localizedDescription)
            isLoading = false // @MainActor
        }
    }
}
