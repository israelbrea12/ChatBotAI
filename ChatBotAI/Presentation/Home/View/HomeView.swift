//
//  HomeView.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 12/3/25.
//

import SwiftUI
import SDWebImageSwiftUI

struct HomeView: View {
    
    @StateObject var homeViewModel = Resolver.shared.resolve(HomeViewModel.self)
    
    @State private var internalHideTabBarState: Bool = false
    
    @State private var showAlert = false
    @State private var chatToDelete: Chat? = nil

    var body: some View {
        NavigationStack {
            ScrollView {
                switch homeViewModel.state {
                case .initial, .loading:
                    loadingView()
                case .error(let errorMessage):
                    errorView(errorMsg: errorMessage)
                case .success:
                    successView()
                default:
                    emptyView()
                }
            }
            .background(Color(.systemGray6))
            .navigationTitle("Chats")
            .toolbar{
                ToolbarItem (placement: .topBarTrailing) {
                    Button {
                        // Llamada al ViewModel al método para añadir nuevo chat.
                        homeViewModel.isPresentingNewMessageView = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .resizable()
                            .frame(width: 32, height: 32)
                            .foregroundStyle(.green)
                    }
                    .sheet(
                        isPresented: $homeViewModel.isPresentingNewMessageView
                    ) {
                        NewMessageView { selectedUser in
                            homeViewModel.startNewChat(with: selectedUser)
                            homeViewModel.chatUser = selectedUser
                            homeViewModel.shouldNavigateToChatLogView.toggle()
                        }
                    }

                }
                ToolbarItem (placement: .topBarLeading) {
                    UserProfileView(user: homeViewModel.currentUser)
                }
            }
            .navigationDestination(
                isPresented: $homeViewModel.shouldNavigateToChatLogView
            ) {
                if let chatUser = homeViewModel.chatUser {
                    ChatLogView(user: chatUser)
                }
            }
        }
        .onAppear {
                    print("HomeView: .onAppear - llamando a homeViewModel.setupViewModel()")
                    homeViewModel.setupViewModel()
                    // When HomeView appears, set tab bar based on current navigation state
                    internalHideTabBarState = homeViewModel.shouldNavigateToChatLogView
                }
                .onDisappear {
                    print("HomeView: .onDisappear - llamando a homeViewModel.stopAllListeners()")
                    homeViewModel.stopAllListeners()
                    // No need to manipulate internalHideTabBarState here directly,
                    // as it's driven by navigation or the active tab's preference.
                }
                .onChange(of: homeViewModel.shouldNavigateToChatLogView) { _, isNavigating in
                    print("HomeView: shouldNavigateToChatLogView changed to \(isNavigating)")
                    self.internalHideTabBarState = isNavigating
                }
                .hideFloatingTabBar(internalHideTabBarState)
    }
    
    private func successView() -> some View {
        ForEach(homeViewModel.chats, id: \.id) { chat in
            Button(action: {
                // Set the user for the chat
                homeViewModel.chatUser = getChatPartner(for: chat)
                // Trigger navigation
                homeViewModel.shouldNavigateToChatLogView = true
            }) {
                ChatRowLabelView(chat: chat, homeViewModel: homeViewModel)
            }
            .frame(maxWidth: .infinity)
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .foregroundColor(.primary)
            .alert(isPresented: $showAlert) {
                CustomDialog(
                             title: "Delete Chat",
                             content: "¿Estás seguro de que quieres eliminar este chat? Esto borrará todos los mensajes y no podrás recuperarlos.",
                             image: .init(
                                content:"trash.fill",
                                tint: .red,
                                foreground: .white
                             ),
                             button1: .init(content: "Delete chat", tint: .red, foreground: .white, action: { _ in 
                                 if let chatToDelete = chatToDelete {
                                                     homeViewModel.deleteChat(for: chatToDelete.id)
                                                 }
                                 showAlert.toggle()
                             }),
                             button2: .init(content: "cancel", tint: .blue, foreground: .white, action: { _ in showAlert = false
                             }),
                             addsTextField: false,
                             textFieldHint: "Personal Documents",
                )
                /// Since it's using "if" condition to add view you can  use SwiftUI Transition here!
                .transition(.blurReplace.combined(with: .push(from: .bottom)))
            } background: {
                /// Your background content in view format
                Rectangle()
                    .fill(.primary.opacity(0.35))
            }
            .swipeActions {
                Action(
                    symbolImage: "trash.fill",
                    tint: .white,
                    background: .red
                ) {
                    resetPosition in
                    chatToDelete = chat
                    showAlert.toggle()
                    resetPosition.toggle()
                }
                Action(
                    symbolImage: "tray.and.arrow.down.fill",
                    tint: .white,
                    background: .green
                ) {
                    resetPosition in
                    resetPosition.toggle()
                }
            }
            .padding(.horizontal)
        }
    }


    private func loadingView() -> some View {
        VStack {
            Spacer()
            ProgressView()
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .frame(
            minHeight: UIScreen.main.bounds.height - 200
        )
    }

    private func emptyView() -> some View {
        InfoView(message: "No data found")
    }

    private func errorView(errorMsg: String) -> some View {
        InfoView(message: errorMsg)
    }
    
    private func getChatPartner(for chat: Chat) -> User {
        let partnerId = chat.participants.first {
            $0 != homeViewModel.currentUser?.id
        } ?? ""
        return homeViewModel.chatUsers[partnerId] ?? User(
            id: "", // ID por defecto o un ID único temporal
            fullName: "Desconocido",
            email: nil,
            profileImageUrl: nil
        )
    }
}

struct ChatRowLabelView: View {
    let chat: Chat
    @ObservedObject var homeViewModel: HomeViewModel

    var body: some View {
        HStack (spacing: 16) {
            // Determinar el ID del otro participante
            let otherParticipantId = chat.participants.first(
                where: { $0 != homeViewModel.currentUser?.id
                }) ?? ""
            
            // Obtener los detalles del usuario
            if let user = homeViewModel.chatUsers[otherParticipantId] {
                // Profile Image
                WebImage(
                    url: URL(string: user.profileImageUrl ?? "")
                ) { phase in
                    switch phase {
                    case .empty:
                        Image(systemName: "person.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 48, height: 48)
                            .foregroundColor(Color(.systemGray3))
                            .background(Color(.systemGray5))
                            .clipShape(Circle())
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 48, height: 48)
                            .clipShape(Circle())
                    case .failure:
                        Image(systemName: "person.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 48, height: 48)
                            .foregroundColor(Color(.systemGray3))
                            .background(Color(.systemGray5))
                            .clipShape(Circle())
                    @unknown default:
                        EmptyView()
                    }
                }

                // VStack for user name and last message
                VStack(alignment: .leading, spacing: 4) {
                    Text(user.fullName ?? "Usuario desconocido")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.primary)

                    Text(chat.lastMessageText ?? "Sin mensajes aún")
                        .font(.system(size: 15))
                        .foregroundStyle(Color(.systemGray))
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                // Vista para cuando el usuario no se encuentra (pero el ID existe)
                // o si otherParticipantId está vacío.
                Image(systemName: "person.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 48, height: 48)
                    .foregroundColor(Color(.systemGray3))
                    .background(Color(.systemGray5))
                    .clipShape(Circle())
                VStack(alignment: .leading, spacing: 4) {
                    Text("Usuario desconocido")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.primary)
                    Text(chat.lastMessageText ?? "Sin mensajes aún")
                        .font(.system(size: 15))
                        .foregroundStyle(Color(.systemGray))
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            Spacer() // Pushes content to the left and timestamp to the right

            // Timestamp display
            if let timestamp = chat.lastMessageTimestamp ?? chat.createdAt {
                Text(
                    Date(timeIntervalSince1970: timestamp)
                        .whatsappFormattedTimeAgo()
                )
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(Color(.systemGray))
            } else {
                Text("Fecha desconocida")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(Color(.systemGray))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}
