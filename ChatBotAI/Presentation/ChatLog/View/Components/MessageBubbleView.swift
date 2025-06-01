//
//  MessageBubbleView.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 8/4/25.
//

import SwiftUI

struct MessageBubbleView: View {
    let message: Message
    let isCurrentUser: Bool
    // Modificado para pasar el mensaje y el CGRect de la burbuja (en coordenadas globales)
    var onLongPress: ((_ message: Message, _ frame: CGRect) -> Void)? = nil
    @State private var bubbleFrame: CGRect = .zero
    
    // Para controlar el tamaño de la imagen
    private let imageMaxWidth: CGFloat = UIScreen.main.bounds.width * 0.65
    private let imageMaxHeight: CGFloat = 300

    var body: some View {
            HStack {
                if isCurrentUser { Spacer(minLength: UIScreen.main.bounds.width * 0.15) }

                VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: 2) { // Contenedor para contenido y hora
                    
                    messageContent() // Contenido del mensaje (Texto o Imagen)
                    // Los paddings y fondos se manejan dentro de messageContent o aquí condicionalmente
                        .background(
                            GeometryReader { proxy in // GeometryReader para obtener el frame de la burbuja
                                Color.clear
                                    .onAppear { bubbleFrame = proxy.frame(in: .global) }
                                    .onChange(of: proxy.frame(in: .global)) { newFrame in bubbleFrame = newFrame }
                            }
                        )
                        .gesture(
                            LongPressGesture(minimumDuration: 0.45).onEnded { _ in
                                onLongPress?(message, bubbleFrame)
                            }
                        )
                    
                    Text(Date(timeIntervalSince1970: message.sentAt ?? Date().timeIntervalSince1970 ).BublesFormattedTime())
                        .font(.caption2)
                        .foregroundColor(.gray)
                        .padding(.horizontal, message.messageType == .text ? 6 : 0) // Solo si es texto
                        .padding(.top, 1)
                }
                .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: isCurrentUser ? .trailing : .leading)


                if !isCurrentUser { Spacer(minLength: UIScreen.main.bounds.width * 0.15) }
            }
            .padding(.horizontal)
            .padding(.vertical, message.messageType == .image ? 6 : 2) // Más padding vertical para imágenes si es necesario
        }

        @ViewBuilder
        private func messageContent() -> some View {
            if message.messageType == .text {
                // Mensaje de texto
                ZStack(alignment: .bottomTrailing) { // ZStack para la hora DENTRO de la burbuja de texto (opcional)
                    Text(message.text.isEmpty ? " " : message.text) // Evita que el Text sea vacío y colapse
                        .padding(10)
                        // .padding(.trailing, message.sentAt != nil ? 45 : 10) // Espacio para la hora si va DENTRO
                        .foregroundColor(isCurrentUser ? .white : .primary)
                        .background(isCurrentUser ? Color.blue : Color(UIColor.systemGray5))
                        .clipShape(RoundedRectangle(cornerRadius: 16)) // Usar clipShape para el fondo
                        .fixedSize(horizontal: false, vertical: true)
                    
                    // Si quieres la hora DENTRO de la burbuja de texto:
                    /*
                    if let sentAt = message.sentAt {
                        Text(Date(timeIntervalSince1970: sentAt).BublesFormattedTime())
                            .font(.caption2)
                            .foregroundColor(isCurrentUser ? .white.opacity(0.7) : .gray)
                            .padding(.bottom, 6)
                            .padding(.trailing, 8)
                    }
                    */
                }
            } else if message.messageType == .image, let imageURLString = message.imageURL, let url = URL(string: imageURLString) {
                // Mensaje de imagen
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(width: imageMaxWidth * 0.7, height: imageMaxHeight * 0.5) // Placeholder más pequeño
                            .background(Color.gray.opacity(0.2))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill) // .fill para llenar el frame
                            .frame(maxWidth: imageMaxWidth, maxHeight: imageMaxHeight)
                            .background(Color.gray.opacity(0.1)) // Fondo sutil por si la imagen tiene transparencia
                            .clipShape(RoundedRectangle(cornerRadius: 16)) // Redondea la imagen
                            // Podrías añadir aquí un overlay para el pie de foto (message.text) o la hora
                    case .failure:
                        VStack(spacing: 4) {
                            Image(systemName: "photo.fill")
                                .font(.title)
                                .foregroundColor(.gray)
                            Text("Error al cargar")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .frame(width: imageMaxWidth * 0.7, height: imageMaxHeight * 0.5, alignment: .center)
                        .background(Color(UIColor.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    @unknown default:
                        EmptyView()
                    }
                }
                // Si el mensaje de imagen tiene texto (caption), mostrarlo debajo
                if !message.text.isEmpty {
                    Text(message.text)
                        .font(.caption)
                        .foregroundColor(isCurrentUser ? .white.opacity(0.8) : .gray)
                        .padding(.horizontal, 6)
                        .padding(.top, 2)
                        .frame(maxWidth: imageMaxWidth, alignment: isCurrentUser ? .trailing : .leading)
                }
            } else {
                // Fallback para tipos de mensaje no soportados o datos incorrectos
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

