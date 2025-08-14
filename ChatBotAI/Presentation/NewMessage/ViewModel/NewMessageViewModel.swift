//
//  NewMessageViewModel.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 20/3/25.
//

import SwiftUI
import Combine

@MainActor
class NewMessageViewModel: ObservableObject {
    
    // MARK: - Publisheds
    @Published var users: [User] = []
    @Published var state: ViewState = .initial
    
    // MARK: - Private vars
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Use Cases
    private let fetchUsersByLanguageUseCase: FetchUsersByLanguageUseCase
    
    // MARK: - Lifecycle functions
    init(fetchUsersByLanguageUseCase: FetchUsersByLanguageUseCase) {
        self.fetchUsersByLanguageUseCase = fetchUsersByLanguageUseCase
    }
    
    // MARK: - Functions
    func fetchMatchingUsers() async {
        guard let currentUserLanguage = SessionManager.shared.currentUser?.learningLanguage, !currentUserLanguage.isEmpty else {
            print("⚠️ El usuario actual no tiene un idioma de aprendizaje configurado.")
            self.state = .empty
            self.users = []
            return
        }
        
        state = .loading
        
        let params = FetchUsersByLanguageParams(language: currentUserLanguage)
        let result = await fetchUsersByLanguageUseCase.execute(with: params)
        
        DispatchQueue.main.async {
            switch result {
            case .success(let users):
                self.users = users.compactMap { $0 }
                self.state = self.users.isEmpty ? .empty : .success
                
                if self.users.isEmpty {
                    print("ℹ️ No se encontraron otros usuarios aprendiendo '\(currentUserLanguage)'.")
                }
                
            case .failure(let error):
                print("❌ Error fetching users: \(error.localizedDescription)")
                self.state = .error(LocalizedKeys.AppError.usersLoadFailed)
            }
        }
    }
}

