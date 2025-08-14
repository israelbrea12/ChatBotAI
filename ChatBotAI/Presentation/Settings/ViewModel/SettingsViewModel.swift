//
//  SettingsViewModel.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 12/3/25.
//

import Foundation
import FirebaseAuth
import Combine
import FirebaseDatabaseInternal

@MainActor
class SettingsViewModel: ObservableObject {
    
    // MARK: - Publisheds
    @Published var currentUser: User?
    @Published var state: ViewState = .initial
    
    // MARK: - Private vars
    private var sessionManager = SessionManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Use Cases
    private let deleteAccountUseCase: DeleteAccountUseCase
    private let signOutUseCase: SignOutUseCase
    private let fetchUserUseCase: FetchUserUseCase
    
    // MARK: - Lifecycle functions
    init(signOutUseCase: SignOutUseCase,
         fetchUserUseCase: FetchUserUseCase,
         deleteAccountUseCase: DeleteAccountUseCase
    ) {
        self.signOutUseCase = signOutUseCase
        self.fetchUserUseCase = fetchUserUseCase
        self.deleteAccountUseCase = deleteAccountUseCase
        
        sessionManager.$currentUser
            .receive(on: DispatchQueue.main)
            .assign(to: \.currentUser, on: self)
            .store(in: &cancellables)
        
        sessionManager.$userSession
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                if user != nil {
                    Task {
                        await self?.fetchUser()
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Functions
    func signOut() {
        
        PresenceManager.shared.goOffline()
        
        Task {
            let result = signOutUseCase.execute(with: ())
            switch result {
            case .success:
                DispatchQueue.main.async {
                    SessionManager.shared.userSession = nil
                    SessionManager.shared.currentUser = nil
                }
                print("Sesión cerrada. Usuario: \(String(describing: SessionManager.shared.userSession))")
            case .failure(let error):
                print("DEBUG: Sign-out error \(error.localizedDescription)")
            }
        }
    }
    
    func fetchUser() async {
        guard let _ = sessionManager.userSession else {
            print("DEBUG: No hay sesión activa, no se puede cargar el usuario")
            return
        }
        
        let result = await fetchUserUseCase.execute(with: ())
        
        switch result {
        case .success(let user):
            DispatchQueue.main.async {
                self.sessionManager.currentUser = user
                self.state = .success
            }
        case .failure(let error):
            DispatchQueue.main.async {
                self.state = .error(LocalizedKeys.AppError.loadingSettings)
            }
        }
    }
    
    func deleteAccount() async {
        
        PresenceManager.shared.goOffline()
        
        let result = await deleteAccountUseCase.execute(with: ())
        
        switch result {
        case .success:
            DispatchQueue.main.async {
                SessionManager.shared.userSession = nil
                SessionManager.shared.currentUser = nil
            }
        case .failure(let error):
            print("DEBUG: Error deleting account from ViewModel: \(error.localizedDescription)")
        }
    }
}
