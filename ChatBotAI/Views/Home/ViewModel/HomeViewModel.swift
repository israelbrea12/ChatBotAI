//
//  HomeViewModel.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 12/3/25.
//

import Foundation
import Combine

@MainActor
final class HomeViewModel: ObservableObject {
    
    @Published var currentUser: User?
    @Published var state: ViewState = .initial
    @Published var isPresentingNewMessageView = false
    
    private let fetchUserUseCase: FetchUserUseCase
    private var sessionManager = SessionManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    init(fetchUserUseCase: FetchUserUseCase) {
        self.fetchUserUseCase = fetchUserUseCase
        
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
    
    func fetchUser() async {
        state = .success
        let result = await fetchUserUseCase.execute(with: ())
            
        switch result {
        case .success(let user):
            DispatchQueue.main.async {
                self.currentUser = user
                self.state = .success
                SessionManager.shared.currentUser = self.currentUser
            }
        case .failure(let error):
            DispatchQueue.main.async {
                self.state = .success
                print(error.localizedDescription)
            }
        }
    }
    
    func startNewChat(with user: User) {
        print("Iniciando chat con \(user.fullName ?? "")")
        isPresentingNewMessageView = false
        // Aquí podrías manejar la lógica para crear un nuevo chat en Firestore
    }
}

