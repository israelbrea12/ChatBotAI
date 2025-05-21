//
//  ChatLogView.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 26/3/25.
//

import SwiftUI

struct ChatLogView: View {
    
    @StateObject var chatLogViewModel = Resolver.shared.resolve(
        ChatLogViewModel.self
    )
    
    let user: User?
    
    var body: some View {
        NavigationStack {
            ZStack {
                switch chatLogViewModel.state {
                case .initial,
                        .loading:
                    loadingView()
                    
                case .success:
                    successView()
                    
                case .error(let errorMessage):
                    errorView(errorMsg: errorMessage)
                    
                case .empty:
                    emptyView()
                }
            }
            .navigationTitle("\(user?.fullName ?? "")")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden, for: .tabBar)
        }
        .onAppear {
            if let currentUser = SessionManager.shared.currentUser, let otherUser = user {
                chatLogViewModel.setupChat(currentUser: currentUser, otherUser: otherUser)
            }
        }
        .onDisappear {
            chatLogViewModel.stopObservingMessages()
        }
    }
    
    private func successView() -> some View {
        VStack {
            MessagesView(messages: chatLogViewModel.messages,
                         currentUserId: SessionManager.shared.currentUser?.id)
            Spacer()
            ChatLogBottomBar(chatText: $chatLogViewModel.chatText,
                             onSendMessage: {chatLogViewModel.sendMessage(currentUser: user)})
                .background(Color.white.ignoresSafeArea())
        }
        .background(Color.clear) // Fondo necesario para detectar gestos
            .onTapGesture {
                UIApplication.shared.endEditing()
            }
    }
    
    private func loadingView() -> some View {
        ProgressView()
    }
    
    private func errorView(errorMsg: String) -> some View {
        InfoView(message: errorMsg)
    }
    
    private func emptyView() -> some View {
        InfoView(message: "No user data found")
    }
}


