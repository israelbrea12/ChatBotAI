//
//  SettingsViewModel.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 12/3/25.
//

import Foundation
import Combine

@MainActor
class SettingsViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var state: ViewState = .success
    
    private let fetchUserUseCase: FetchUserUseCase
    private let signOutUseCase: SignOutUseCase
    
    init(fetchUserUseCase: FetchUserUseCase, signOutUseCase: SignOutUseCase) {
        self.fetchUserUseCase = fetchUserUseCase
        self.signOutUseCase = signOutUseCase
        
        Task {
            await fetchUser()
        }
    }
    
    func fetchUser() async {
        state = .loading
        let result = await fetchUserUseCase.execute(with: ())
        
        switch result {
        case .success(let user):
            self.currentUser = user
            state = .success
        case .failure(let error):
            state = .error(error.localizedDescription)
        }
    }
    
    func signOut() {
        state = .loading
        let result = signOutUseCase.execute(with: ())
        
        switch result {
        case .success:
            DispatchQueue.main.async {
                self.currentUser = nil
                self.state = .success
            }
        case .failure(let error):
            state = .error(error.localizedDescription)
        }
    }
}
