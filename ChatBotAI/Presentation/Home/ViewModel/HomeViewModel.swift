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
    private let observeUserChatsUseCase: ObserveUserChatsUseCase
    private let deleteUserChatUseCase: DeleteUserChatUseCase
    
    private var sessionManager = SessionManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    init(fetchUserUseCase: FetchUserUseCase,
         createChatUseCase: CreateChatUseCase,
         fetchUserChatsUseCase: FetchUserChatsUseCase,
         fetchUserByIdUseCase: FetchUserByIdUseCase,
         observeUserChatsUseCase: ObserveUserChatsUseCase,
         deleteUserChatUseCase: DeleteUserChatUseCase
         
    ) {
        self.fetchUserUseCase = fetchUserUseCase
        self.createChatUseCase = createChatUseCase
        self.fetchUserChatsUseCase = fetchUserChatsUseCase
        self.fetchUserByIdUseCase = fetchUserByIdUseCase
        self.observeUserChatsUseCase = observeUserChatsUseCase
        self.deleteUserChatUseCase = deleteUserChatUseCase
        
    }
    
    func setupViewModel() {
        print("HomeViewModel: setupViewModel()")
        if sessionManager.userSession != nil {
            if currentUser == nil {
                print("HomeViewModel: currentUser es nil, iniciando fetchCurrentUserAndDependents.")
                Task {
                    await fetchCurrentUserAndDependents() // Esto ya llama a startObservingUserChats
                }
            } else {

                print("HomeViewModel: currentUser ya existe (\(currentUser!.id)). Asegurando que los listeners estén activos.")

                self.startObservingUserChats()
            }
        } else {
            self.state = .empty
            print("HomeViewModel: No hay sesión de usuario al momento de setup.")
            // Considera si cleanupAfterLogout() debería llamarse aquí si no se maneja
            // completamente por el sink de userSession.
        }

        // El sink para cambios de sesión es importante y debe mantenerse
        sessionManager.$userSession
            .dropFirst() // Evita la notificación inicial si ya se manejó arriba
            .receive(on: DispatchQueue.main)
            .sink { [weak self] firebaseUser in
                guard let self = self else { return }
                if firebaseUser != nil {
                    print("HomeViewModel (Sink): Sesión de usuario detectada/cambiada. Recargando datos.")
                    Task {
                        await self.fetchCurrentUserAndDependents()
                    }
                } else {
                    print("HomeViewModel (Sink): Cierre de sesión detectado. Limpiando.")
                    self.cleanupAfterLogout()
                }
            }
            .store(in: &cancellables)
    }

       func stopAllListeners() {
           print("HomeViewModel: stopAllListeners()")
           if let userId = currentUser?.id {
               observeUserChatsUseCase.stop(userId: userId)
           }
       }
       
       private func fetchCurrentUserAndDependents() async {
           self.state = .loading
           let result = await fetchUserUseCase.execute(with: ())
               
           switch result {
           case .success(let user):
               self.currentUser = user
               SessionManager.shared.currentUser = user
               print("HomeViewModel: Usuario actual cargado: \(user?.id ?? "")")

               await self.loadInitialChats()

               self.startObservingUserChats()
               
           case .failure(let error):
               self.state = .error("Error al obtener datos del usuario: \(error.localizedDescription)")
               print(error.localizedDescription)
           }
       }
       
       private func loadInitialChats() async {
           guard let _ = currentUser else {
               self.state = .error("No se puede cargar chats sin un usuario actual.")
               return
           }
           
           let result = await fetchUserChatsUseCase.execute(with: ())

           switch result {
           case .success(let fetchedChats):
               self.chats = fetchedChats.sorted(by: self.sortChats)
               print("HomeViewModel: Chats iniciales cargados: \(self.chats.count)")
               await self.fetchUsersForCurrentChats()
               
               self.state = self.chats.isEmpty ? .empty : .success
               
           case .failure(let error):
               self.state = .error("Error al obtener los chats: \(error.localizedDescription)")
           }
       }
       
       private func startObservingUserChats() {
           guard let userId = currentUser?.id else {
               print("HomeViewModel: No se puede iniciar la observación de chats sin userId.")
               return
           }
           
           print("HomeViewModel: Iniciando observación de chats para el usuario: \(userId)")
           observeUserChatsUseCase.execute(userId: userId) { [weak self] chatEvent in
               guard let self = self else { return }
               print("HomeViewModel: Evento de chat recibido: \(chatEvent.id)")
               self.processChatEvent(chatEvent)
           }
       }
       
    private func processChatEvent(_ chat: Chat) {
        // La tarea para buscar detalles del usuario puede seguir siendo asíncrona
        // Solo busca detalles si el chat no es una señal de eliminación (participantes no vacíos)
        if !chat.participants.isEmpty { // O una condición más explícita si la tienes
            Task {
                await self.fetchUserDetailsForChat(chat)
            }
        }

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            var listChanged = false
            if let index = self.chats.firstIndex(where: { $0.id == chat.id }) {
                // Comprueba si este es el evento "chat eliminado" enviado por ChatDataSourceImpl
                // El indicador es un array de participantes vacío y, opcionalmente, otros campos reseteados.
                if chat.participants.isEmpty && chat.createdAt == 0 && chat.lastMessageText == nil {
                    self.chats.remove(at: index)
                    listChanged = true
                    print("HomeViewModel: Chat \(chat.id) REMOVIDO de la lista.")
                    // Opcionalmente, podrías querer limpiar `chatUsers` si ese usuario ya no participa en ningún otro chat,
                    // pero esto puede ser más complejo de gestionar y podría no ser necesario.
                } else {
                    // Es una actualización de un chat existente (nuevo mensaje, etc.)
                    self.chats[index] = chat
                    listChanged = true
                    print("HomeViewModel: Chat \(chat.id) actualizado en la lista.")
                }
            } else if !chat.participants.isEmpty {
                // Es un chat completamente nuevo (no un marcador de eliminación para un chat que ya no debería estar)
                // Solo añade si tiene participantes, indicando que es un chat válido.
                self.chats.append(chat)
                listChanged = true
                print("HomeViewModel: Nuevo chat \(chat.id) añadido a la lista.")
            }

            if listChanged {
                self.chats.sort(by: self.sortChats)
                
                // Asegúrate de que el estado se actualice correctamente.
                // Si el estado es un error, quizás no quieras cambiarlo a .success o .empty
                // hasta que el error se resuelva.
                if case .error = self.state {
                     // Mantener el estado de error si ya está en error,
                     // o decidir una lógica específica
                     print("HomeViewModel: processChatEvent - Estado actual es error, no se cambiará automáticamente.")
                } else {
                     self.state = self.chats.isEmpty ? .empty : .success
                }
                print("HomeViewModel: processChatEvent finalizado en main thread para chat \(chat.id). Chats count: \(self.chats.count), State: \(self.state)")
            } else {
                print("HomeViewModel: processChatEvent - no se realizaron cambios para chat \(chat.id)")
            }
        }
    }

       private func sortChats(chat1: Chat, chat2: Chat) -> Bool {
           (chat1.lastMessageTimestamp ?? chat1.createdAt ?? 0) > (chat2.lastMessageTimestamp ?? chat2.createdAt ?? 0)
       }
       
       func startNewChat(with userToChatWith: User) {
           guard let currentUserId = self.currentUser?.id else {
               print("HomeViewModel: No hay usuario actual para iniciar un nuevo chat.")
               return
           }

           let existingChat = chats.first(where: {
               $0.participants.contains(userToChatWith.id) && $0.participants.contains(currentUserId)
           })

           if existingChat != nil {
               self.chatUser = userToChatWith
               self.isPresentingNewMessageView = false
               self.shouldNavigateToChatLogView = true
               print("HomeViewModel: Navegando a chat existente con \(userToChatWith.id)")
           } else {
               // Si no existe, crea el chat
               Task {
                   await createNewChatFlow(with: userToChatWith)
               }
           }
       }
       
       private func createNewChatFlow(with userToChatWith: User) async {
           
           let result = await createChatUseCase.execute(
               with: CreateChatParams(userId: userToChatWith.id)
           )
           
           switch result {
           case .success(let newChat):
               
               self.isPresentingNewMessageView = false
               self.chatUser = userToChatWith
               self.shouldNavigateToChatLogView = true
               print("HomeViewModel: Chat creado con \(userToChatWith.id). El observador lo recogerá.")
               
           case .failure(let error):
               print("HomeViewModel: Error al crear el chat: \(error.localizedDescription)")
               self.state = .error("Error al iniciar el chat: \(error.localizedDescription)")
           }
       }

       private func fetchUsersForCurrentChats() async {
           let allParticipantIds = Set(chats.flatMap { $0.participants })
           let idsToFetch = allParticipantIds.filter { $0 != currentUser?.id && chatUsers[$0] == nil }

           guard !idsToFetch.isEmpty else { return }
           
           print("HomeViewModel: Cargando detalles para usuarios: \(idsToFetch)")
           await withTaskGroup(of: (String, User?).self) { group in
               for userId in idsToFetch {
                   group.addTask {
                       return (userId, await self.fetchUserFromUseCase(userId: userId))
                   }
               }
               for await (userId, user) in group {
                   if let user = user {
                       self.chatUsers[userId] = user
                   }
               }
           }
           print("HomeViewModel: Detalles de usuarios para chats actuales cargados.")
       }
       
       private func fetchUserDetailsForChat(_ chat: Chat) async {
           guard let otherUserId = chat.participants.first(where: { $0 != self.currentUser?.id }) else {
               return
           }
           if chatUsers[otherUserId] == nil { // Solo buscar si no lo tenemos
               if let user = await fetchUserFromUseCase(userId: otherUserId) {
                   self.chatUsers[otherUserId] = user
                   print("HomeViewModel: Detalles de usuario \(otherUserId) para chat \(chat.id) cargados.")
               }
           }
       }

       private func fetchUserFromUseCase(userId: String) async -> User? {
           let result = await fetchUserByIdUseCase.execute(with: FetchUserByIdParams(userId: userId))
           switch result {
           case .success(let user):
               return user
           case .failure(let error):
               print("HomeViewModel: Error fetching user \(userId): \(error.localizedDescription)")
               return nil
           }
       }

       private func cleanupAfterLogout() {
           print("HomeViewModel: cleanupAfterLogout()")
           stopAllListeners()
           
           currentUser = nil
           chats = []
           chatUsers = [:]
           chatUser = nil
           state = .initial

           cancellables.forEach { $0.cancel() }
           cancellables.removeAll()
       }
    
    func deleteChat(for chatId: String) {
        guard let currentUserId = currentUser?.id else { return }
        Task {
            let result = await deleteUserChatUseCase.execute(with: DeleteUserChatParams(userId: currentUserId, chatId: chatId))
            switch result {
            case .success:
                print("Chat eliminado exitosamente para usuario: \(currentUserId)")
            case .failure(let error):
                print("Error al eliminar el chat: \(error.localizedDescription)")
            }
        }
    }

}

