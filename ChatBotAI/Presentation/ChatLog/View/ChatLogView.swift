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
    @State private var imageDataToPreview: Data? = nil // Para la imagen seleccionada
    @State private var showImagePreviewScreen: Bool = false // Para mostrar la pantalla de preview
    @State private var imagePreviewCaption: String = "" // Para el pie de foto en la preview
    
    
    let user: User?
    
    var body: some View {
        CustomMenuView(config: $config) {
            NavigationStack {
                ZStack {
                    // Contenido principal del chat
                    VStack { // Añadido VStack para que el ZStack principal pueda superponer el ProgressView correctamente
                        switch chatLogViewModel.state {
                        case .initial, .loading:
                                if !chatLogViewModel.isUploadingImage { // No mostrar si ya se está subiendo una imagen
                                loadingView()
                            } else {
                                successView() // Mostrar chat mientras se sube imagen en segundo plano
                            }
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
                        
                    // MODIFICADO: Indicador de carga translúcido
                    if chatLogViewModel.isUploadingImage {
                        VStack { // Contenedor para centrar el ProgressView
                            Spacer()
                            HStack {
                                Spacer()
                                ProgressView("Enviando imagen...")
                                    .padding()
                                    .background(.ultraThinMaterial) // Fondo translúcido
                                    .cornerRadius(10)
                                    .shadow(radius: 5) // Sombra sutil para destacar
                                Spacer()
                            }
                            Spacer()
                        }
                        .background(Color.black.opacity(0.05)) // Fondo muy sutil para todo el ZStack
                        .edgesIgnoringSafeArea(.all)
                    }
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
            .photosPicker( // Se mantiene aquí para la selección inicial
                isPresented: $showingImagePicker,
                selection: $selectedPhotoItem,
                matching: .images
            )
            .onChange(of: selectedPhotoItem) { newItem in
                Task {
                    if let item = newItem {
                        do {
                            if let data = try await item.loadTransferable(type: Data.self) {
                                self.imageDataToPreview = data // Guardar datos para la preview
                                self.showImagePreviewScreen = true // Mostrar pantalla de preview
                                self.selectedPhotoItem = nil // Resetear picker para la próxima
                                // El config.showMenu = false se maneja en la acción del menú
                            } else {
                                print("No se pudieron cargar los datos de la imagen seleccionada.")
                            }
                        } catch {
                                print("Error al cargar la imagen: \(error.localizedDescription)")
                        }
                    }
                }
            }
            // NUEVO: Pantalla de previsualización como fullScreenCover
            .fullScreenCover(isPresented: $showImagePreviewScreen) {
                if let dataForPreview = imageDataToPreview {
                    ImagePreviewView(
                        imageData: dataForPreview,
                        caption: $imagePreviewCaption, // Pasa el binding para el pie de foto
                        onCancel: {
                            self.imageDataToPreview = nil
                            self.imagePreviewCaption = "" // Limpia el pie de foto
                            self.showImagePreviewScreen = false
                        },
                        onSend: { confirmedCaption in
                            chatLogViewModel.sendImageMessage(
                                imageData: dataForPreview,
                                currentUser: SessionManager.shared.currentUser,
                                caption: confirmedCaption // Envía el pie de foto confirmado
                            )
                            self.imageDataToPreview = nil
                            self.imagePreviewCaption = "" // Limpia el pie de foto
                            self.showImagePreviewScreen = false
                        }
                    )
                } else {
                    // Fallback en caso de que imageDataToPreview sea nil, aunque no debería ocurrir
                    // si showImagePreviewScreen es true.
                    Text("Error al cargar previsualización.")
                        .onAppear {
                            self.showImagePreviewScreen = false // Cierra si no hay datos
                        }
                }
            }
        } actions: {
            /// Sample Action's
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


