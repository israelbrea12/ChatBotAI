//
//  ImagePreviewView.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 1/6/25.
//


import SwiftUI

struct ImagePreviewView: View {
    let imageData: Data
    @Binding var caption: String // Para el pie de foto opcional
    var onCancel: () -> Void
    var onSend: (_ caption: String) -> Void // Devuelve el pie de foto

    @Environment(\.colorScheme) var colorScheme
    @FocusState private var isCaptionFieldFocused: Bool // Para manejar el foco del TextField

    var body: some View {
        NavigationView { // NavigationView para la barra de navegación con el botón de cancelar
            ZStack {
                // Fondo que se adapta al modo oscuro/claro
                (colorScheme == .dark ? Color.black : Color.white)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        isCaptionFieldFocused = false // Ocultar teclado al tocar fuera del TextField
                    }

                VStack(spacing: 0) { // VStack principal para la imagen y los controles
                    Spacer() // Empuja la imagen hacia el centro verticalmente

                    if let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .padding() // Un poco de padding alrededor de la imagen
                            .accessibilityLabel(LocalizedKeys.Chat.imagePreviewTitle)
                    } else {
                        Text(LocalizedKeys.Chat.couldNotLoadPreview)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer() // Empuja los controles hacia abajo

                    // Pie de foto y botón de enviar
                    HStack(spacing: 10) {
                        TextField(LocalizedKeys.Placeholder.addCommentPlaceholder, text: $caption)
                            .focused($isCaptionFieldFocused)
                            .padding(12)
                            .background(.thinMaterial)
                            .clipShape(Capsule())
                            .overlay(
                                Capsule().stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                        
                        Button(action: {
                            isCaptionFieldFocused = false // Ocultar teclado antes de enviar
                            onSend(caption)
                        }) {
                            Image(systemName: "paperplane.circle.fill")
                                .resizable()
                                .frame(width: 44, height: 44) // Tamaño del botón de enviar
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 10 > 0 ? 0 : 20) // Padding inferior más seguro
                    .padding(.bottom, 10) // Padding inferior adicional
                }
            }
            .navigationBarItems(
                leading:
                    Button(action: {
                        isCaptionFieldFocused = false
                        onCancel()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                            .padding(8)
                            .background(Circle().fill(Color.gray.opacity(0.2)))
                    }
            )
            .navigationBarTitleDisplayMode(.inline)
            // .navigationTitle("Enviar Imagen") // Título opcional
        }
        .accentColor(.blue) // Para el botón de "atrás" si se navega más profundo (no aplica aquí pero es buena práctica)
    }
}

struct ImagePreviewView_Previews: PreviewProvider {
    static var previews: some View {
        let placeholderImageData = UIImage(systemName: "photo")?.pngData() ?? Data()
        
        ImagePreviewView(
            imageData: placeholderImageData,
            caption: .constant("Un bonito pie de foto"),
            onCancel: { print("Preview Cancelled") },
            onSend: { caption in print("Preview Send with caption: \(caption)") }
        )
    }
}
