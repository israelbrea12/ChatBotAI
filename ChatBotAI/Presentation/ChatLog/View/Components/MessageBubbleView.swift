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

    var body: some View {
        HStack {
            if isCurrentUser { Spacer(minLength: UIScreen.main.bounds.width * 0.15) } // Empuja más si es necesario

            ZStack(alignment: .bottomTrailing) {
                Text(message.text)
                    .padding(.all, 10)
                    .padding(.trailing, message.sentAt != nil ? 45 : 10) // Más espacio si hay hora
                    .foregroundColor(isCurrentUser ? .white : .primary) // .primary para modo oscuro/claro
                    .background(isCurrentUser ? Color.blue : Color(UIColor.systemGray5)) // systemGray5 es un buen color para burbujas recibidas
                    .cornerRadius(16) // Un poco más redondeado
                    .fixedSize(horizontal: false, vertical: true)

                if let sentAt = message.sentAt {
                    Text(Date(timeIntervalSince1970: sentAt).BublesFormattedTime()) // Asumo que esta extensión existe
                        .font(.caption2)
                        .foregroundColor(isCurrentUser ? .white.opacity(0.7) : .gray)
                        .padding(.bottom, 6)
                        .padding(.trailing, 8) // Ajusta el padding para la hora
                }
            }
            // Incrementa el maxWidth para permitir burbujas un poco más anchas si es necesario.
            .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: isCurrentUser ? .trailing : .leading)
            // Adjuntamos el GeometryReader y el gesto al ZStack que contiene la burbuja.
            .background(
                        GeometryReader { proxy in
                            Color.clear
                                .onAppear {
                                    bubbleFrame = proxy.frame(in: .global)
                                }
                                .onChange(of: proxy.frame(in: .global)) { newFrame in
                                    bubbleFrame = newFrame
                                }
                        }
                    )
                    .gesture(
                        LongPressGesture(minimumDuration: 0.45).onEnded { _ in
                            onLongPress?(message, bubbleFrame)
                        }
                    )

            if !isCurrentUser { Spacer(minLength: UIScreen.main.bounds.width * 0.15) }
        }
        .padding(.horizontal)
        .padding(.vertical, 2) // Un padding vertical más ajustado entre burbujas
        // .id(message.id) // El .id debe estar en la vista raíz que se itera en el ForEach de MessagesView si es para ScrollViewReader
    }
}

struct BubbleFramePreferenceKey: PreferenceKey {
    static var defaultValue: CGRect = .zero
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}

