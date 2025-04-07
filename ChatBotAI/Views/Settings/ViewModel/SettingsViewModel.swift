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
    @Published var currentUser: User?
    @Published var state: ViewState = .initial
    
    private let deleteAccountUseCase: DeleteAccountUseCase
    private let signOutUseCase: SignOutUseCase
    private let fetchUserUseCase: FetchUserUseCase
    private let stopObservingChatsUseCase: StopObservingChatsUseCase
    private var sessionManager = SessionManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    init(signOutUseCase: SignOutUseCase,
         fetchUserUseCase: FetchUserUseCase,
         deleteAccountUseCase: DeleteAccountUseCase,
         stopObservingChatsUseCase: StopObservingChatsUseCase
    ) {
        self.signOutUseCase = signOutUseCase
        self.fetchUserUseCase = fetchUserUseCase
        self.deleteAccountUseCase = deleteAccountUseCase
        self.stopObservingChatsUseCase = stopObservingChatsUseCase
        
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
    
    func signOut() {
        Task {
            let result = signOutUseCase.execute(with: ())
            switch result {
            case .success:
                _ = await stopObservingChatsUseCase.execute(with: ())
                
                DispatchQueue.main.async {
                    SessionManager.shared.userSession = nil
                    SessionManager.shared.currentUser = nil
                }
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
                self.currentUser = user
                self.state = .success
            }
        case .failure(let error):
            DispatchQueue.main.async {
                self.state = .error("Error al cargar pantalla settings: \(error), intente más tarde. \(error.localizedDescription)")
            }
        }
    }
    
    func deleteAccount() async {
            let result = await deleteAccountUseCase.execute(with: ())
            switch result {
            case .success:
                DispatchQueue.main.async {
                    SessionManager.shared.userSession = nil
                    SessionManager.shared.currentUser = nil
                }
            case .failure(let error):
                print("DEBUG: Error deleting account \(error.localizedDescription)")
            }
        }

}
