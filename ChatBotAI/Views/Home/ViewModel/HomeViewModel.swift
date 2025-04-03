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
    @Published var shouldNavigateToChatLogView = false
    @Published var chatUser: User?
    
    private let fetchUserUseCase: FetchUserUseCase
    private let createChatUseCase: CreateChatUseCase
    
    private var sessionManager = SessionManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    init(fetchUserUseCase: FetchUserUseCase, createChatUseCase: CreateChatUseCase) {
        self.fetchUserUseCase = fetchUserUseCase
        self.createChatUseCase = createChatUseCase
        
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
                self.state = 
                    .error("El error es: \(error.localizedDescription)")
                print(error.localizedDescription)
            }
        }
    }
    
    func startNewChat(with user: User) {
        Task {
            await self.createChat(with: user)
        }
    }
    
    private func createChat(with user: User) async {
        state = .loading
        let result = await createChatUseCase.execute(with: CreateChatParams(userId: user.id))
        
        switch result {
        case .success(let chat):
            DispatchQueue.main.async {
                print("Chat creado con éxito: \(result)")
                self.isPresentingNewMessageView = false
                self.chatUser = user
                self.shouldNavigateToChatLogView = true
                self.state = .success
            }
        case .failure(let error):
            DispatchQueue.main.async {
                print("Error al crear el chat: \(error.localizedDescription)")
                self.state = .error("Error al crear el chat: \(error.localizedDescription)")
            }
        }
    }
}

