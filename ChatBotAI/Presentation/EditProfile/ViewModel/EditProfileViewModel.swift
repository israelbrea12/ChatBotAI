//
//  EditProfileViewModel.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 19/7/25.
//

import Foundation
import UIKit
import Combine

@MainActor
class EditProfileViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var fullName: String
    @Published var email: String
    @Published var profileImageUrl: String?
    @Published var selectedImage: UIImage?
    @Published var learningLanguage: Language
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    let dismissAction = PassthroughSubject<Void, Never>()
    
    // MARK: - Use Cases
    private let updateUserUseCase: UpdateUserUseCase
    
    init(user: User, updateUserUseCase: UpdateUserUseCase) {
        self.fullName = user.fullName ?? LocalizedKeys.DefaultValues.defaultFullName
        self.email = user.email ?? LocalizedKeys.DefaultValues.defaultEmail
        self.profileImageUrl = user.profileImageUrl
        self.updateUserUseCase = updateUserUseCase
        self.learningLanguage = Language(rawValue: user.learningLanguage ?? "en") ?? .english
    }
    
    func saveChanges() async {
        isLoading = true
        errorMessage = nil
        
        let params = UpdateUserParams(
            fullName: fullName,
            profileImage: selectedImage,
            learningLanguage: learningLanguage.rawValue
        )
        
        let result = await updateUserUseCase.execute(with: params)
        
        isLoading = false
        
        switch result {
        case .success(let updatedUser):
            SessionManager.shared.currentUser = updatedUser
            
            dismissAction.send()
        case .failure(let error):
            self.errorMessage = LocalizedKeys.AppError.editingAccount
        }
    }
}
