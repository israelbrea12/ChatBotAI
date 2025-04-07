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
    }
    
    private func successView() -> some View {
        ForEach(homeViewModel.chats, id: \.id) { chat in
            VStack {
                NavigationLink {
                    ChatLogView(
                        user: homeViewModel
                            .chatUsers[chat.participants.first { $0 != homeViewModel.currentUser?.id } ?? ""] ?? User(
                                id: "",
                                fullName: "Desconocido",
                                email: nil,
                                profileImageUrl: nil
                            )
                    )
                } label: {
                    HStack (spacing: 16) {
                        if let userId = chat.participants.first(
                            where: { $0 != homeViewModel.currentUser?.id
                            }),
                           let user = homeViewModel.chatUsers[userId] {
                            WebImage(url: URL(string: user.profileImageUrl ?? "")) { phase in
                                switch phase {
                                case .empty:
                                    Image(systemName: "person.fill")
                                        .resizable()
                                        .frame(width: 44, height: 44)
                                        .foregroundColor(.gray)
                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 44, height: 44)
                                        .clipShape(Circle())
                                case .failure:
                                    Image(systemName: "person.fill")
                                        .resizable()
                                        .frame(width: 44, height: 44)
                                        .foregroundColor(.gray)
                                @unknown default:
                                    EmptyView()
                                }
                            }

                            VStack(alignment: .leading) {
                                Text(user.fullName ?? "Usuario desconocido")
                                    .font(.system(size: 16, weight: .bold))
                                Text(chat.lastMessageText ?? "Sin mensajes aún")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(Color(.lightGray))
                            }
                        }
                        Spacer()

                        if let timestamp = chat.lastMessageTimestamp ?? chat.createdAt {
                            Text(Date(timeIntervalSince1970: timestamp).whatsappFormattedTimeAgo())
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(Color(.gray))
                        } else {
                            Text("Fecha desconocida")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(Color(.gray))
                        }
                    }
                }
                .foregroundColor(.primary)
                Divider()
                    .padding(.vertical, 8)
            }
            .padding(.horizontal)
        }
    }


    private func loadingView() -> some View {
        ProgressView()
    }

    private func emptyView() -> some View {
        InfoView(message: "No data found")
    }

    private func errorView(errorMsg: String) -> some View {
        InfoView(message: errorMsg)
    }
}
