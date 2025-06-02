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
                .frame(maxHeight: imageMaxHeight) // Image itself is capped by maxHeight
                .clipShape(RoundedRectangle(cornerRadius: max(0, bubbleCornerRadius - borderThickness)))

            if !message.text.isEmpty {
                Text(message.text)
                    .font(.body)
                    .foregroundColor(isCurrentUser ? .white : .primary)
                    .padding(.horizontal, 10)
                    .padding(.top, 6)
                    .padding(.bottom, 8)
            }
        }
        .padding(borderThickness) // Padding for the "border" effect
        .frame(maxWidth: imageMaxWidth)
        .background(isCurrentUser ? Color.blue : Color(UIColor.systemGray5))
        .clipShape(RoundedRectangle(cornerRadius: bubbleCornerRadius))
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

    // Re-define or pass these constants for use in messageContent
    private let bubbleCornerRadius: CGFloat = 16
    private let borderThickness: CGFloat = 3

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
                Text(message.text.isEmpty ? " " : message.text) // Ensure non-empty content for layout
                    .padding(10)
                    .foregroundColor(isCurrentUser ? .white : .primary)
                    .background(isCurrentUser ? Color.blue : Color(UIColor.systemGray5))
                    .clipShape(RoundedRectangle(cornerRadius: bubbleCornerRadius))
                    .fixedSize(horizontal: false, vertical: true)
            } else if message.messageType == .image, let imageURLString = message.imageURL, let url = URL(string: imageURLString) {
                WebImage(
                    url: url
                    // Optionally, you can set progressive loading or thumbnails if supported and desired
                    // .progressive()
                    // .thumbnail()
                ) { phase in
                    switch phase {
                    case .empty:
                        // --- MODIFIED PLACEHOLDER ---
                        VStack(alignment: .leading, spacing: 0) { // Mimic ImageBubbleContentView structure
                            ZStack { // Area for the image + progress indicator
                                Color.clear // Placeholder, ensures the ZStack takes up space
                                    .frame(height: imageMaxHeight) // CRITICAL: Reserve full imageMaxHeight
                                    .frame(maxWidth: .infinity) // Take available width from parent
                                ProgressView()
                            }
                            .clipShape(RoundedRectangle(cornerRadius: max(0, bubbleCornerRadius - borderThickness))) // Clip placeholder image area

                            // Display caption during loading if available
                            if !message.text.isEmpty {
                                Text(message.text)
                                    .font(.body)
                                    .foregroundColor(isCurrentUser ? .white.opacity(0.85) : .primary.opacity(0.85))
                                    .padding(.horizontal, 10)
                                    .padding(.top, 6)
                                    .padding(.bottom, 8)
                            }
                        }
                        .padding(borderThickness) // For the border effect
                        .frame(maxWidth: imageMaxWidth) // Overall max width
                        .background(.clear) // Dimmed background for loading
                        .clipShape(RoundedRectangle(cornerRadius: bubbleCornerRadius))

                    case .success(let image):
                        ImageBubbleContentView(
                            image: image,
                            message: message,
                            isCurrentUser: isCurrentUser,
                            imageMaxWidth: imageMaxWidth,
                            imageMaxHeight: imageMaxHeight
                        )

                    case .failure:
                        // --- MODIFIED FAILURE VIEW ---
                        VStack(alignment: .leading, spacing: 0) { // Mimic ImageBubbleContentView structure
                            ZStack { // Area for the error icon + text
                                Color.clear // Placeholder
                                    .frame(height: imageMaxHeight * 0.6) // Make failure view reasonably tall, e.g., 60% of imageMaxHeight
                                    .frame(maxWidth: .infinity)
                                VStack(spacing: 5) {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .font(.title2)
                                        .foregroundColor(isCurrentUser ? .white.opacity(0.7) : .red.opacity(0.7))
                                    Text("Error al cargar")
                                        .font(.caption)
                                        .foregroundColor(isCurrentUser ? .white.opacity(0.7) : .gray)
                                }
                            }
                            .clipShape(RoundedRectangle(cornerRadius: max(0, bubbleCornerRadius - borderThickness)))

                            // Display caption on failure if available
                            if !message.text.isEmpty {
                                Text(message.text)
                                    .font(.body)
                                    .foregroundColor(isCurrentUser ? .white.opacity(0.85) : .primary.opacity(0.85))
                                    .padding(.horizontal, 10)
                                    .padding(.top, 6)
                                    .padding(.bottom, 8)
                            }
                        }
                        .padding(borderThickness)
                        .frame(maxWidth: imageMaxWidth)
                        .background((isCurrentUser ? Color.blue : Color(UIColor.systemGray5)).opacity(0.5))
                        .clipShape(RoundedRectangle(cornerRadius: bubbleCornerRadius))
                    @unknown default:
                        EmptyView() // Should not happen ideally
                    }
                }
            } else {
                Text("Tipo de mensaje no soportado")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(10)
                    .background(Color(UIColor.systemGray5))
                    .clipShape(RoundedRectangle(cornerRadius: bubbleCornerRadius))
            }
        }
}

struct BubbleFramePreferenceKey: PreferenceKey {
    static var defaultValue: CGRect = .zero
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}

