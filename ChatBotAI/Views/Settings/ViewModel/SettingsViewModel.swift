//
//  SettingsViewModel.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 12/3/25.
//

import Foundation
import FirebaseAuth
import Combine

@MainActor
class SettingsViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var state: ViewState = .initial
    
    private let signOutUseCase: SignOutUseCase
    private let fetchUserUseCase: FetchUserUseCase
    private var sessionManager = SessionManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    init(signOutUseCase: SignOutUseCase, fetchUserUseCase: FetchUserUseCase) {
        self.signOutUseCase = signOutUseCase
        self.fetchUserUseCase = fetchUserUseCase
        
        Task {
            await fetchUser()
        }
        
        sessionManager.$userSession
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                Task {
                    await self?.fetchUser()
                }
            }
            .store(in: &cancellables)
        
        Task {
            await fetchUser()
        }
    
    }
    
    func signOut() {
        Task {
            let result = signOutUseCase.execute(with: ())
            switch result {
            case .success:
                DispatchQueue.main.async {
                    SessionManager.shared.userSession = nil
                    self.currentUser = nil
                }
            case .failure(let error):
                print("DEBUG: Sign-out error \(error.localizedDescription)")
            }
        }
    }
    
    func fetchUser() async {
        state = .loading
        let result = await fetchUserUseCase.execute(with: ())
        switch result {
        case .success(let user):
            DispatchQueue.main.async {
                self.currentUser = user
                self.state = .success
            }
        case .failure(let error):
            DispatchQueue.main.async {
                self.state = .error(error.localizedDescription)
            }
        }
    }
}
