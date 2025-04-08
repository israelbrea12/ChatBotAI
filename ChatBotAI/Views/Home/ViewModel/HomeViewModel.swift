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
    @Published var chatUser: User?
    @Published var chats: [Chat] = []
    @Published var chatUsers: [String: User] = [:]
    @Published var isPresentingNewMessageView = false
    @Published var shouldNavigateToChatLogView = false
    
    private let fetchUserUseCase: FetchUserUseCase
    private let createChatUseCase: CreateChatUseCase
    private let fetchUserChatsUseCase: FetchUserChatsUseCase
    private let fetchUserByIdUseCase: FetchUserByIdUseCase
    private let observeNewChatsUseCase: ObserveNewChatsUseCase
    
    private var sessionManager = SessionManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    init(fetchUserUseCase: FetchUserUseCase,
         createChatUseCase: CreateChatUseCase,
         fetchUserChatsUseCase: FetchUserChatsUseCase,
         fetchUserByIdUseCase: FetchUserByIdUseCase,
         observeNewChatsUseCase: ObserveNewChatsUseCase
         
    ) {
        self.fetchUserUseCase = fetchUserUseCase
        self.createChatUseCase = createChatUseCase
        self.fetchUserChatsUseCase = fetchUserChatsUseCase
        self.fetchUserByIdUseCase = fetchUserByIdUseCase
        self.observeNewChatsUseCase = observeNewChatsUseCase
        
        
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
                
                Task {
                    await self.fetchUserChats()
                }
                self.observeNewChats()
                
                
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
        if chats.first(where: { $0.participants.contains(user.id) }) != nil {
            chatUser = user
            isPresentingNewMessageView = false
        } else {
            Task {
                await createChat(with: user)
            }
        }
    }
    
    private func createChat(with user: User) async {
        state = .loading
        let result = await createChatUseCase.execute(
            with: CreateChatParams(userId: user.id)
        )
        
        switch result {
        case .success(_):
            DispatchQueue.main.async {
                print("Chat creado con éxito: \(result)")
                self.isPresentingNewMessageView = false
                self.chatUser = user
                self.shouldNavigateToChatLogView = true
                self.state = .success
            }
            
            await fetchUserChats()
            
        case .failure(let error):
            DispatchQueue.main.async {
                print("Error al crear el chat: \(error.localizedDescription)")
                self.state = 
                    .error(
                        "Error al crear el chat: \(error.localizedDescription)"
                    )
            }
        }
    }
    
    func fetchUserChats() async {
        state = .loading
        let result = await fetchUserChatsUseCase.execute(with: ())

        switch result {
        case .success(let chats):
            DispatchQueue.main.async {
                print("Se obtuvieron \(chats.count) chats")
                self.chats = chats.sorted {
                    ($0.lastMessageTimestamp ?? $0.createdAt ?? 0) > ($1.lastMessageTimestamp ?? $1.createdAt ?? 0)
                }
                Task {
                    await self.fetchChatUsers()
                }
                self.state = .success
            }
        case .failure(let error):
            DispatchQueue.main.async {
                self.state = 
                    .error(
                        "Error al obtener los chats: \(error.localizedDescription)"
                    )
            }
        }
    }
    
    func fetchChatUsers() async {
        let userIds = chats.compactMap {
            $0.participants.first { $0 != currentUser?.id }
        }

        await withTaskGroup(of: (String, User?).self) { group in
            for userId in userIds {
                group.addTask {
                    let result = await self.fetchUserByIdUseCase.execute(
                        with: FetchUserByIdParams(userId: userId)
                    )
                    switch result {
                    case .success(let user):
                        return (userId, user)
                    case .failure(let error):
                        print(
                            "Error fetching user \(userId): \(error.localizedDescription)"
                        )
                        return (userId, nil)
                    }
                }
            }

            for await (userId, user) in group {
                if let user = user {
                    DispatchQueue.main.async {
                        self.chatUsers[userId] = user
                    }
                }
            }
        }
    }
    
    private func fetchUserNewChat(chat: Chat) async {
        guard let otherUserId = chat.participants.first(where: { $0 != currentUser?.id }) else { return }
        let result = await fetchUserByIdUseCase.execute(with: FetchUserByIdParams(userId: otherUserId))
        if case .success(let user) = result {
            DispatchQueue.main.async {
                self.chatUsers[otherUserId] = user
            }
        }
    }
    
    func observeNewChats() {
        observeNewChatsUseCase.execute { [weak self] updatedChat in
            guard let self else { return }

            if let index = self.chats.firstIndex(where: { $0.id == updatedChat.id }) {
                DispatchQueue.main.async {
                    self.chats[index] = updatedChat
                    self.chats.sort {
                        ($0.lastMessageTimestamp ?? $0.createdAt ?? 0) > ($1.lastMessageTimestamp ?? $1.createdAt ?? 0)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.chats.insert(updatedChat, at: 0)
                    Task {
                        await self.fetchUserNewChat(chat: updatedChat)
                    }
                }
            }
        }
    }
}

