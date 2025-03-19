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
    private var sessionManager = SessionManager.shared
    private var cancellables = Set<AnyCancellable>()

    init(signOutUseCase: SignOutUseCase) {
        self.signOutUseCase = signOutUseCase
        
        // 🔥 Nos suscribimos a los cambios en SessionManager
        sessionManager.$currentUser
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                self?.currentUser = user
                self?.state = user != nil ? .success : .empty
            }
            .store(in: &cancellables)
    }
    
    func signOut() {
        Task {
            let result = signOutUseCase.execute(with: ())
            switch result {
            case .success:
                DispatchQueue.main.async {
                    SessionManager.shared.userSession = nil
                    SessionManager.shared.currentUser = nil
                }
            case .failure(let error):
                print("DEBUG: Sign-out error \(error.localizedDescription)")
            }
        }
    }
}
