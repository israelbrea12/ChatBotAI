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
                }
        .onDisappear {
                    print("HomeView: .onDisappear - llamando a homeViewModel.stopAllListeners()")
                    homeViewModel.stopAllListeners()
                }
    }
    
    private func successView() -> some View {
            // Loop through each chat
            ForEach(homeViewModel.chats, id: \.id) { chat in
                NavigationLink {
                    // Navigate to ChatLogView for the selected chat
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
                    // HStack for the main chat row content
                    HStack (spacing: 16) {
                        // Check if user details are available
                        if let userId = chat.participants.first(
                            where: { $0 != homeViewModel.currentUser?.id
                            }),
                           let user = homeViewModel.chatUsers[userId] {
                            // Profile Image
                            WebImage(url: URL(string: user.profileImageUrl ?? "")) { phase in
                                switch phase {
                                case .empty:
                                    Image(systemName: "person.fill")
                                        .resizable()
                                        .scaledToFit() // Use scaledToFit for placeholder
                                        .frame(width: 48, height: 48) // Slightly larger image
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
                                    .font(.system(size: 17, weight: .semibold)) // Slightly larger font
                                    .foregroundColor(.primary)

                                Text(chat.lastMessageText ?? "Sin mensajes aún")
                                    .font(.system(size: 15)) // Slightly larger font
                                    .foregroundStyle(Color(.systemGray))
                                    .multilineTextAlignment(.leading)
                                    .lineLimit(1) // Keep it to one line for this design
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        Spacer() // Pushes content to the left and timestamp to the right

                        // Timestamp display
                        if let timestamp = chat.lastMessageTimestamp ?? chat.createdAt {
                            Text(Date(timeIntervalSince1970: timestamp).whatsappFormattedTimeAgo())
                                .font(.system(size: 14, weight: .regular)) // Adjusted font weight
                                .foregroundStyle(Color(.systemGray))
                        } else {
                            Text("Fecha desconocida")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundStyle(Color(.systemGray))
                        }
                    }
                    .padding(.horizontal, 16) // Horizontal padding for the content inside the card
                    .padding(.vertical, 12)   // Vertical padding for the content inside the card
                }
                .frame(maxWidth: .infinity) // Ensure the link takes full width before applying background
                .background(Color(.systemBackground)) // White background for the card
                .cornerRadius(12) // Rounded corners for the card
                .foregroundColor(.primary) // Ensure text color is appropriate
            .swipeActions {
                Action(symbolImage: "trash.fill", tint: .white, background: .red) {
                    resetPosition in
                    resetPosition.toggle()
                }
                Action(symbolImage: "tray.and.arrow.down.fill", tint: .white, background: .green) {
                    resetPosition in
                    resetPosition.toggle()
                }
            }
            .padding(.horizontal)
        }
    }


    private func loadingView() -> some View {
            VStack { // Usamos un VStack para centrar el ProgressView
                Spacer() // Empuja el ProgressView hacia el centro
                ProgressView()
                Spacer() // Empuja el ProgressView hacia el centro
            }
            .frame(maxWidth: .infinity) // Asegura que el VStack ocupe el ancho
            // El truco está en que los Spacers intentarán ocupar todo el alto disponible
            // dentro del ScrollView, haciendo que el contenido del ScrollView sea "alto".
            // Necesitamos darle una altura mínima al contenido del ScrollView,
            // o una altura que coincida con la pantalla.
            // Para asegurar que el ScrollView sepa que su contenido debe ser alto:
            .frame(minHeight: UIScreen.main.bounds.height - 200) // Un valor aproximado para llenar la pantalla
                                                                // Ajusta este valor según sea necesario,
                                                                // considerando barras de navegación, etc.
                                                                // O usa GeometryReader para una mayor precisión si es necesario.
        }

    private func emptyView() -> some View {
        InfoView(message: "No data found")
    }

    private func errorView(errorMsg: String) -> some View {
        InfoView(message: errorMsg)
    }
}
