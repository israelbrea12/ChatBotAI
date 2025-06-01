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
    // NUEVOS ESTADOS PARA EL IMAGE PICKER
    @State private var showingImagePicker = false
    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    
    
    let user: User?
    
    var body: some View {
        CustomMenuView(config: $config) {
            /// Your Root View
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
                .contentShape(Rectangle()) // Permite que los taps se detecten en cualquier parte vacía
                .onTapGesture {
                    UIApplication.shared.endEditing()
                }
                
                if chatLogViewModel.isUploadingImage {
                    ProgressView("Enviando imagen...")
                        .padding()
                        .background(Color.black.opacity(0.7))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .safeAreaInset(edge: .bottom) {
                // Pasamos el binding de chatText, el viewModel y el usuario actual
                BottomBar(
                    chatText: $chatLogViewModel.chatText,
                    viewModel: chatLogViewModel,
                    currentUser: SessionManager.shared.currentUser // El usuario que envía el mensaje
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
            
            // MODIFICADOR PhotosPicker
            .photosPicker(
                isPresented: $showingImagePicker,
                selection: $selectedPhotoItem,
                matching: .images // Solo imágenes
            )
            .onChange(of: selectedPhotoItem) { newItem in // Cambiado de _ a newItem
                Task {
                    if let item = newItem { // Usa el newItem renombrado
                        do {
                            if let data = try await item.loadTransferable(type: Data.self) {
                                // Llama a la función del ViewModel para enviar la imagen
                                // Podrías añadir una UI para escribir un pie de foto aquí si quisieras
                                chatLogViewModel.sendImageMessage(imageData: data, currentUser: SessionManager.shared.currentUser, caption: "")
                                selectedPhotoItem = nil // Resetea para la próxima selección
                            } else {
                                print("No se pudieron cargar los datos de la imagen seleccionada.")
                                // Opcional: mostrar error al usuario
                            }
                        } catch {
                            print("Error al cargar la imagen: \(error.localizedDescription)")
                            // Opcional: mostrar error al usuario
                        }
                    }
                }
            }
        } actions: {
            /// Sample Action's
            MenuAction(symbolImage: "camera", text: "Camera")
            MenuAction(symbolImage: "photo.on.rectangle.angled", text: "Photos") {
                self.showingImagePicker = true
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
    
    /// Custom Bottom Bar
        @ViewBuilder
        func BottomBar(
            chatText: Binding<String>, // Binding para el texto del chat
            viewModel: ChatLogViewModel, // ViewModel para llamar a las acciones
            currentUser: User? // El usuario que envía el mensaje
        ) -> some View {
            HStack(spacing: 12) {
                /// Custom Menu Source Button
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
                    /// Ejemplos:
                    /// Puede cerrar el teclado si está abierto, etc.
                    print("Plus Tapped")
                    UIApplication.shared.endEditing() // Buena práctica cerrar el teclado
                }

                TextField("Text Message", text: chatText) // Vinculamos al chatText del ViewModel
                    .padding(.vertical, 8)
                    .padding(.horizontal, 15)
                    .background {
                        Capsule()
                            .stroke(.gray.opacity(0.3), lineWidth: 1.5)
                    }
                    .onSubmit { // Permite enviar con la tecla "Intro"
                        viewModel.sendTextMessage(currentUser: currentUser)
                    }

                // Botón de enviar
                Button(action: {
                    viewModel.sendTextMessage(currentUser: currentUser)
                }) {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 18)) // Ajusta el tamaño según sea necesario
                        .foregroundColor(chatText.wrappedValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .gray : .blue) // Color dinámico
                        .padding(8) // Ajusta el padding
                }
                .disabled(chatText.wrappedValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) // Deshabilita si el texto está vacío

            }
            .padding(.horizontal, 15)
            .padding(.vertical, 8) // Padding vertical para la HStack completa
            .background(.thinMaterial) // Un fondo sutil, puedes cambiarlo a Color.white o lo que prefieras
        }
}


