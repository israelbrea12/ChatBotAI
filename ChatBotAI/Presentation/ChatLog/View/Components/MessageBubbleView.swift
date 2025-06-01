//
//  MessageBubbleView.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 8/4/25.
//

import SwiftUI
import SDWebImageSwiftUI

// Estructura auxiliar para el contenido de la burbuja de imagen (imagen + texto)
struct ImageBubbleContentView: View {
    let image: Image // La imagen de SwiftUI ya cargada
    let message: Message
    let isCurrentUser: Bool
    let imageMaxWidth: CGFloat
    let imageMaxHeight: CGFloat

    // Constantes para el diseño del borde y las esquinas
    private let bubbleCornerRadius: CGFloat = 16
    private let borderThickness: CGFloat = 3 // Grosor del borde visible

    var body: some View {
        VStack(alignment: .leading, spacing: 0) { // Sin espaciado, el padding lo controla
            image // La Image de SwiftUI
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(maxHeight: imageMaxHeight)
                // Recortar la imagen con un radio de esquina ligeramente menor
                // para que encaje bien dentro del borde redondeado.
                // Si el radio de la burbuja es 16 y el borde es 2, el radio interior de la imagen sería 14.
                .clipShape(RoundedRectangle(cornerRadius: max(0, bubbleCornerRadius - borderThickness)))

            if !message.text.isEmpty {
                Text(message.text)
                    .font(.body) // Mismo estilo que los mensajes de texto normales
                    .foregroundColor(isCurrentUser ? .white : .primary) // Color de texto según el usuario
                    .padding(.horizontal, 10) // Padding horizontal para el texto (adicional al borde)
                    .padding(.top, 6)        // Espacio entre la imagen y el texto
                    .padding(.bottom, 8)     // Padding inferior para el texto
                    // Asegura que el texto se alinee correctamente dentro de su espacio
            }
        }
        // 1. Aplicar padding para crear el espacio del borde.
        // Este padding se llenará con el color de fondo.
        .padding(borderThickness)
        .frame(maxWidth: imageMaxWidth) // Ancho máximo de la burbuja de imagen (incluyendo el borde)
        // 2. Aplicar el color de fondo a la burbuja (incluyendo el área del padding/borde).
        .background(isCurrentUser ? Color.blue : Color(UIColor.systemGray5)) // Color de fondo de la burbuja
        // 3. Recortar la forma final de la burbuja con sus esquinas redondeadas.
        .clipShape(RoundedRectangle(cornerRadius: bubbleCornerRadius)) // Bordes redondeados para la burbuja completa
    }
}

// El resto de tu código (MessageBubbleView, etc.) permanece igual que en la versión anterior.
// Solo necesitas reemplazar la struct ImageBubbleContentView con esta versión.

struct MessageBubbleView: View {
    let message: Message
    let isCurrentUser: Bool
    var onLongPress: ((_ message: Message, _ frame: CGRect) -> Void)? = nil
    @State private var bubbleFrame: CGRect = .zero
    
    private let imageMaxWidth: CGFloat = UIScreen.main.bounds.width * 0.65
    private let imageMaxHeight: CGFloat = 300

    var body: some View {
        HStack {
            if isCurrentUser { Spacer(minLength: UIScreen.main.bounds.width * 0.15) }

            VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: 2) {
                messageContent()
                    .background(
                        GeometryReader { proxy in
                            Color.clear
                                .onAppear { bubbleFrame = proxy.frame(in: .global) }
                                .onChange(of: proxy.frame(in: .global)) { oldFrame, newFrame in bubbleFrame = newFrame }
                        }
                    )
                    .gesture(
                        LongPressGesture(minimumDuration: 0.45).onEnded { _ in
                            onLongPress?(message, bubbleFrame)
                        }
                    )
                
                Text(Date(timeIntervalSince1970: message.sentAt ?? Date().timeIntervalSince1970).BublesFormattedTime())
                    .font(.caption2)
                    .foregroundColor(.gray)
                    .padding(.horizontal, message.messageType == .text ? 6 : 0)
                    .padding(.top, 1)
            }
            .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: isCurrentUser ? .trailing : .leading)

            if !isCurrentUser { Spacer(minLength: UIScreen.main.bounds.width * 0.15) }
        }
        .padding(.horizontal)
        .padding(.vertical, message.messageType == .image ? 6 : 2)
    }

    @ViewBuilder
    private func messageContent() -> some View {
        if message.messageType == .text {
            Text(message.text.isEmpty ? " " : message.text)
                .padding(10)
                .foregroundColor(isCurrentUser ? .white : .primary)
                .background(isCurrentUser ? Color.blue : Color(UIColor.systemGray5))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .fixedSize(horizontal: false, vertical: true)
        } else if message.messageType == .image, let imageURLString = message.imageURL, let url = URL(string: imageURLString) {
            WebImage(
                url: url
            ) { phase in
                switch phase {
                case .empty:
                    VStack {
                        ProgressView()
                    }
                    .frame(width: imageMaxWidth * 0.5, height: imageMaxHeight * 0.3)
                    .padding(10)
                    .background(isCurrentUser ? Color.blue : Color(UIColor.systemGray5))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                case .success(let image):
                    ImageBubbleContentView(
                        image: image,
                        message: message,
                        isCurrentUser: isCurrentUser,
                        imageMaxWidth: imageMaxWidth,
                        imageMaxHeight: imageMaxHeight
                    )
                case .failure:
                    VStack(spacing: 4) {
                        Image(systemName: "photo.fill")
                            .font(.title)
                            .foregroundColor(isCurrentUser ? .white.opacity(0.8) : .gray)
                        Text("Error al cargar")
                            .font(.caption)
                            .foregroundColor(isCurrentUser ? .white.opacity(0.8) : .gray)
                    }
                    .padding(10)
                    .frame(maxWidth: imageMaxWidth * 0.7, minHeight: imageMaxHeight * 0.3)
                    .background(isCurrentUser ? Color.blue : Color(UIColor.systemGray5))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                @unknown default:
                    EmptyView()
                }
            }
        } else {
            Text("Tipo de mensaje no soportado")
                .font(.caption)
                .foregroundColor(.gray)
                .padding(10)
                .background(Color(UIColor.systemGray5))
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
}

struct BubbleFramePreferenceKey: PreferenceKey {
    static var defaultValue: CGRect = .zero
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}

