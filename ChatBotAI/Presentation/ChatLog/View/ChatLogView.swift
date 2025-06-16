//
//  ChatLogView.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 26/3/25.
//

import SwiftUI
import PhotosUI

struct ChatLogView: View {
    
    @StateObject var chatLogViewModel = Resolver.shared.resolve(
        ChatLogViewModel.self
    )

    @State private var config: MenuConfig = .init(symbolImage: "plus")
    @State private var showingImagePicker = false
    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    @State private var imageDataToPreview: Data? = nil // Para la imagen seleccionada
    @State private var showImagePreviewScreen: Bool = false // Para mostrar la pantalla de preview
    @State private var imagePreviewCaption: String = "" // Para el pie de foto en la preview
    
    let user: User?
    
    var body: some View {
        CustomMenuView(config: $config) {
            NavigationStack {
                ZStack {
                    VStack {
                                    switch chatLogViewModel.state {
                                    // --- MODIFICADO: La lógica de loading/success se simplifica ---
                                    case .initial, .loading:
                                        loadingView()
                                    case .success, .empty: // Unimos success y empty
                                        successView()
                                    case .error(let errorMessage):
                                        errorView(errorMsg: errorMessage)
                                    }
                                }
                    .navigationTitle("\(user?.fullName ?? "")")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar(.hidden, for: .tabBar)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        UIApplication.shared.endEditing()
                    }
                    .toolbarBackground(
                        .visible,
                        for: .navigationBar
                    )
                    .toolbarBackground(
                        .ultraThinMaterial,
                        for: .navigationBar
                    )
                }
            }
            .safeAreaInset(edge: .bottom) {
                BottomBar(
                    chatText: $chatLogViewModel.chatText,
                    viewModel: chatLogViewModel,
                    currentUser: SessionManager.shared.currentUser
                )
            }
            .onAppear {
                if let currentUser = SessionManager.shared.currentUser, let otherUser = user {
                    chatLogViewModel.setupChat(currentUser: currentUser, otherUser: otherUser)
                }
            }
            .onDisappear {
                chatLogViewModel.stopObservingMessages()
            }
            .photosPicker(
                isPresented: $showingImagePicker,
                selection: $selectedPhotoItem,
                matching: .images
            )
            .onChange(of: selectedPhotoItem) { newItem in
                Task {
                    if let item = newItem {
                        do {
                            if let data = try await item.loadTransferable(type: Data.self) {
                                self.imageDataToPreview = data
                                self.showImagePreviewScreen = true
                                self.selectedPhotoItem = nil
                            } else {
                                print("No se pudieron cargar los datos de la imagen seleccionada.")
                            }
                        } catch {
                                print("Error al cargar la imagen: \(error.localizedDescription)")
                        }
                    }
                }
            }
            .fullScreenCover(isPresented: $showImagePreviewScreen) {
                if let dataForPreview = imageDataToPreview {
                    ImagePreviewView(
                        imageData: dataForPreview,
                        caption: $imagePreviewCaption,
                        onCancel: {
                            self.imageDataToPreview = nil
                            self.imagePreviewCaption = ""
                            self.showImagePreviewScreen = false
                        },
                        onSend: { confirmedCaption in
                            chatLogViewModel.sendImageMessage(
                                imageData: dataForPreview,
                                currentUser: SessionManager.shared.currentUser,
                                caption: confirmedCaption
                            )
                            self.imageDataToPreview = nil
                            self.imagePreviewCaption = ""
                            self.showImagePreviewScreen = false
                        }
                    )
                } else {
                    Text("Error al cargar previsualización.")
                        .onAppear {
                            self.showImagePreviewScreen = false
                        }
                }
            }
        } actions: {
            MenuAction(symbolImage: "camera", text: "Camera")
            MenuAction(symbolImage: "photo.on.rectangle.angled", text: "Photos") {
                self.showingImagePicker = true
                self.config.showMenu = false
            }
            MenuAction(symbolImage: "face.smiling", text: "Genmoji")
            MenuAction(symbolImage: "waveform", text: "Audio")
            MenuAction(symbolImage: "apple.logo", text: "App Store")
            MenuAction(symbolImage: "video.badge.waveform", text: "Facetime")
            MenuAction(symbolImage: "suit.heart", text: "Digital Touch")
            MenuAction(symbolImage: "location", text: "Location")
            MenuAction(symbolImage: "music.note", text: "Music")
        }
    }
    
    private func successView() -> some View {
        VStack {
            MessagesView(messages: chatLogViewModel.messages,
                         currentUserId: SessionManager.shared.currentUser?.id)
        }
    }
    
    private func loadingView() -> some View {
        ProgressView("Cargando mensajes...")
    }
    
    private func errorView(errorMsg: String) -> some View {
        InfoView(message: errorMsg)
    }
    
    private func emptyView() -> some View {
        InfoView(message: "No user data found")
    }
    
        @ViewBuilder
        func BottomBar(
            chatText: Binding<String>,
            viewModel: ChatLogViewModel,
            currentUser: User?
        ) -> some View {
            HStack(spacing: 12) {
                MenuSourceButton(config: $config) {
                    Image(systemName: "plus")
                        .font(.title3)
                        .frame(width: 35, height: 35)
                        .background {
                            Circle()
                                .fill(.gray.opacity(0.25))
                                .background(.background, in: .circle)
                        }
                } onTap: {
                    print("Plus Tapped")
                    UIApplication.shared.endEditing()
                }

                TextField("Text Message", text: chatText)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 15)
                    .background {
                        Capsule()
                            .stroke(.gray.opacity(0.3), lineWidth: 1.5)
                    }
                    .onSubmit {
                        viewModel.sendTextMessage(currentUser: currentUser)
                    }

                Button(action: {
                    viewModel.sendTextMessage(currentUser: currentUser)
                }) {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 18))
                        .foregroundColor(chatText.wrappedValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .gray : .blue)
                        .padding(8)
                }
                .disabled(chatText.wrappedValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

            }
            .padding(.horizontal, 15)
            .padding(.vertical, 8)
            .background(.thinMaterial)
        }
}


