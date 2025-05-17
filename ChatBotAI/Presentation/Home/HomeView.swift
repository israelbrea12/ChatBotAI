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
    
    @State private var showAlert = false // Esta variable veo bien que esté aquí porque solo sirve para la vista.

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
            print(
                "HomeView: .onAppear - llamando a homeViewModel.setupViewModel()"
            )
            homeViewModel.setupViewModel()
        }
        .onDisappear {
            print(
                "HomeView: .onDisappear - llamando a homeViewModel.stopAllListeners()"
            )
            homeViewModel.stopAllListeners()
        }
    }
    
    private func successView() -> some View {
        // Loop through each chat
        ForEach(homeViewModel.chats, id: \.id) { chat in
            NavigationLink {
                // Navigate to ChatLogView for the selected chat
                ChatLogView(user: getChatPartner(for: chat))
            } label: {
                ChatRowLabelView(chat: chat, homeViewModel: homeViewModel)
            }
            .frame(
                maxWidth: .infinity
            ) // Ensure the link takes full width before applying background
            .background(
                Color(.systemBackground)
            ) // White background for the card
            .cornerRadius(12) // Rounded corners for the card
            .foregroundColor(.primary) // Ensure text color is appropriate
            .alert(isPresented: $showAlert) {
                CustomDialog(
                             title: "Delete Chat",
                             content: "¿Estás seguro de que quieres eliminar este chat? Esto borrará todos los mensajes y no podrás recuperarlos.",
                             image: .init(
                                content:"trash.fill",
                                tint: .red,
                                foreground: .white
                             ),
                             button1: .init(content: "Delete chat", tint: .red, foreground: .white, action: {
                                 folder in
                                 print(folder)
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
        .frame(
            minHeight: UIScreen.main.bounds.height - 200
        ) // Un valor aproximado para llenar la pantalla
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
    
    // Función auxiliar para obtener el usuario compañero de chat
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

// Subestructura para la etiqueta de la fila del chat (el contenido del NavigationLink)
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
                        .lineLimit(1)
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
                        .lineLimit(1)
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
