//
//  MessagesView.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 26/3/25.
//

import SwiftUI

struct MessagesView: View {
    
    @StateObject var chatLogViewModel = Resolver.shared.resolve(
        ChatLogViewModel.self
    )
    
    @Namespace private var bottomID
    
    let messages: [Message]
    let currentUserId: String?
    
    // Estados para el menú contextual
    @State private var showContextMenu: Bool = false
    @State private var contextMenuMessage: Message? = nil
    @State private var contextMenuAnchorFrame: CGRect = .zero // Frame de la burbuja pulsada (coordenadas globales)
    @State private var menuAnchorPointForTransition: UnitPoint = .center // Para la animación de transición del menú

    // Estimación del tamaño del menú para cálculos de posición.
    private let menuEstimatedSize = CGSize(width: 200, height: 110) // Ajusta según el contenido real de tu menú

    var groupedMessages: [(date: String, messages: [Message])] {
        // ... (tu lógica existente para agrupar mensajes)
        Dictionary(grouping: messages) { message in
            guard let timestamp = message.sentAt else { return "Desconocido" }
            let date = Date(timeIntervalSince1970: timestamp)
            return date.whatsappFormattedTimeAgoWithoutAMOrPM() // Asumo que esta extensión existe
        }
        .map { (key: String, value: [Message]) in (date: key, messages: value) }
        .sorted { a, b in
            guard let firstDate = a.messages.first?.sentAt, let secondDate = b.messages.first?.sentAt else { return false }
            return firstDate < secondDate
        }
    }

    var body: some View {
        // GeometryReader para obtener las dimensiones de MessagesView para posicionar el menú
        GeometryReader { screenGeometry in
            ZStack { // ZStack principal para superponer el menú
                ScrollViewReader { scrollViewProxy in
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(groupedMessages, id: \.date) { group in
                                Text(group.date)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 8)
                                    .background(Capsule().fill(Color.gray.opacity(0.2)))
                                    .padding(.vertical, 10)
                            
                                ForEach(group.messages) { message in
                                    MessageBubbleView(
                                        message: message,
                                        isCurrentUser: message.senderId == currentUserId,
                                        onLongPress: { tappedMessage, bubbleFrameGlobal in
                                            self.contextMenuMessage = tappedMessage
                                            self.contextMenuAnchorFrame = bubbleFrameGlobal // Esto está en coordenadas globales
                                            withAnimation(.spring(response: 0.35, dampingFraction: 0.65)) {
                                                self.showContextMenu = true
                                            }
                                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                        }
                                    )
                                    .id(message.id)
                                    .padding(.bottom, group.messages.last?.id == message.id ? 5 : 0)
                                    .blur(radius: showContextMenu && message.id != contextMenuMessage?.id ? 5 : 0)
                                }
                            }
                            Color.clear
                                .frame(height: 1)
                                .id(bottomID)
                        }
                        .padding(.vertical, 8)
                    }
                    .simultaneousGesture(
                        DragGesture().onChanged { _ in
                            UIApplication.shared.endEditing()
                        }
                    )
                    .background(Color(.init(white: 0.95, alpha: 1)))
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                            scrollToBottom(proxy: scrollViewProxy, animated: false)
                        }
                    }
                    .onChange(of: messages.count) {
                        scrollToBottom(proxy: scrollViewProxy)
                    }
                    .onChange(of: messages.last?.id) {
                         scrollToBottom(proxy: scrollViewProxy)
                    }
                } // Fin ScrollViewReader

                // Overlay para el menú contextual
                if showContextMenu {
                    // Fondo semi-transparente para cerrar el menú al tocar fuera
                    Color.black.opacity(0.001) // Casi invisible pero tappable
                        .edgesIgnoringSafeArea(.all) // Cubre toda la pantalla para el gesto de tap
                        .onTapGesture {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                                self.showContextMenu = false
                                self.contextMenuMessage = nil
                            }
                        }

                    // El menú en sí
                    if let message = contextMenuMessage, contextMenuAnchorFrame != .zero {
                        // contextMenuAnchorFrame está en coordenadas GLOBALES.
                        // screenGeometry.frame(in: .global) es el frame GLOBAL de MessagesView.
                        // Necesitamos posicionar ContextMenuView dentro del espacio de coordenadas de MessagesView.
                        
                        let messagesViewGlobalOrigin = screenGeometry.frame(in: .global).origin
                        
                        // Convertimos el frame global de la burbuja a coordenadas relativas a MessagesView
                        let bubbleFrameInMessagesViewSpace = CGRect(
                            x: contextMenuAnchorFrame.origin.x - messagesViewGlobalOrigin.x,
                            y: contextMenuAnchorFrame.origin.y - messagesViewGlobalOrigin.y,
                            width: contextMenuAnchorFrame.width,
                            height: contextMenuAnchorFrame.height
                        )

                        // Calculamos el origen (top-left) del menú y el ancla para su animación de transición.
                        // Los límites para el cálculo son los propios límites de MessagesView.
                        let (menuOriginInMessagesView, determinedAnchor) = calculateMenuPlacement(
                            bubbleFrame: bubbleFrameInMessagesViewSpace,
                            menuSize: menuEstimatedSize,
                            containerBounds: CGRect(origin: .zero, size: screenGeometry.size), // Límites de MessagesView
                            isBubbleCurrentUser: message.senderId == currentUserId // Podría usarse para alineación horizontal avanzada
                        )
                        
                        MessageActionMenuView(
                            items: [
                                MessageActionItem(label: "Editar", systemImage: "pencil.circle.fill") {
                                    print("Acción: Editar mensaje con ID '\(message.id)'")
                                    // Implementa la lógica de edición
                                    withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                                        self.showContextMenu = false // Cierra el menú
                                    }
                                },
                                MessageActionItem(label: "Eliminar", systemImage: "trash.circle.fill") {
                                    Task {
                                        if let message = contextMenuMessage {
                                            let messageId = message.id
                                            await chatLogViewModel.deleteMessage(messageId: messageId)
                                        }

                                        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                                            self.showContextMenu = false
                                        }
                                    }
                                }
                            ],
                            showMenu: $showContextMenu
                        )
                        .frame(width: menuEstimatedSize.width, height: menuEstimatedSize.height) // Fuerza el tamaño del menú
                        // Posiciona el CENTRO de ContextMenuView
                        .position(
                            x: menuOriginInMessagesView.x + menuEstimatedSize.width / 2,
                            y: menuOriginInMessagesView.y + menuEstimatedSize.height / 2
                        )
                        .onAppear { // Actualiza el punto de anclaje para la transición
                            self.menuAnchorPointForTransition = determinedAnchor
                        }
                        // Aplica la transición usando el punto de anclaje determinado dinámicamente
                        .transition(.scale(scale: 0.9, anchor: menuAnchorPointForTransition).combined(with: .opacity))
                    }
                }
            } // Fin ZStack principal
        } // Fin GeometryReader
    }
    
    // Función helper para hacer scroll al fondo
    private func scrollToBottom(proxy: ScrollViewProxy, animated: Bool = true) {
        guard !messages.isEmpty, let lastId = messages.last?.id else {
            if animated {
                withAnimation(.spring()) { proxy.scrollTo(bottomID, anchor: .bottom) }
            } else {
                proxy.scrollTo(bottomID, anchor: .bottom)
            }
            return
        }
        
        if animated {
            withAnimation(.spring()) {
                proxy.scrollTo(lastId, anchor: .bottom)
            }
        } else {
            proxy.scrollTo(lastId, anchor: .bottom)
        }
    }

    // Función helper para calcular el origen (top-left) del menú y el ancla para la transición
    // Todos los CGRects y CGPoints aquí son relativos a 'containerBounds' (es decir, el espacio de coordenadas de MessagesView)
    private func calculateMenuPlacement(
        bubbleFrame: CGRect,      // El frame de la burbuja del mensaje, en coordenadas del contenedor
        menuSize: CGSize,         // El tamaño estimado del menú
        containerBounds: CGRect,  // Los límites de la vista contenedora (MessagesView)
        isBubbleCurrentUser: Bool // Para informar una posible alineación horizontal (no usada activamente para x aquí)
    ) -> (origin: CGPoint, anchorForTransition: UnitPoint) {

        var xOrigin: CGFloat
        var yOrigin: CGFloat
        var anchor: UnitPoint

        let gap: CGFloat = 8.0       // Espacio entre la burbuja y el menú
        let padding: CGFloat = 8.0   // Padding desde los bordes del contenedor

        // === Posicionamiento Vertical ===
        let yBelow = bubbleFrame.maxY + gap
        let yAbove = bubbleFrame.minY - menuSize.height - gap

        // Intenta colocar debajo
        if (yBelow + menuSize.height) <= (containerBounds.maxY - padding) {
            yOrigin = yBelow
            anchor = .top // El menú se escala hacia abajo desde su borde superior
        }
        // Si no, intenta colocar encima
        else if yAbove >= (containerBounds.minY + padding) {
            yOrigin = yAbove
            anchor = .bottom // El menú se escala hacia arriba desde su borde inferior
        }
        // Fallback: No hay espacio ideal. Prioriza debajo, luego encima, luego ajusta.
        else {
            // Si la burbuja está más en la mitad superior, preferir abajo. Si no, preferir arriba.
            if (bubbleFrame.midY < containerBounds.midY) {
                 yOrigin = yBelow // Intenta abajo primero
                 anchor = .top
                 // Si se desborda, ajústalo para que quepa desde abajo
                 if (yOrigin + menuSize.height) > (containerBounds.maxY - padding) {
                     yOrigin = containerBounds.maxY - menuSize.height - padding
                 }
            } else {
                yOrigin = yAbove // Intenta arriba primero
                anchor = .bottom
                // Si se desborda (ej. yOrigin < minY), ajústalo para que quepa desde arriba
                if yOrigin < (containerBounds.minY + padding) {
                    yOrigin = containerBounds.minY + padding
                }
            }
            // Asegúrate de que no se salga de los límites después del ajuste
            yOrigin = max(containerBounds.minY + padding, yOrigin)
            yOrigin = min(yOrigin, containerBounds.maxY - menuSize.height - padding)

            // Re-evaluar el ancla si se ha ajustado fuertemente a un borde
            if yOrigin == (containerBounds.minY + padding) && anchor == .bottom {
                 // Si está pegado arriba, pero iba a escalar desde abajo, mejor escalar desde arriba
                 anchor = .top
            } else if (yOrigin + menuSize.height) == (containerBounds.maxY - padding) && anchor == .top {
                 // Si está pegado abajo, pero iba a escalar desde arriba, mejor escalar desde abajo
                 anchor = .bottom
            }
        }

        // === Posicionamiento Horizontal ===
        // Por defecto: Centra el menú horizontalmente con la burbuja
        xOrigin = bubbleFrame.midX - (menuSize.width / 2)

        // Ajusta xOrigin para mantener el menú dentro de los límites del contenedor
        xOrigin = max(containerBounds.minX + padding, xOrigin) // Ajusta al borde izquierdo
        xOrigin = min(xOrigin, containerBounds.maxX - menuSize.width - padding) // Ajusta al borde derecho
        
        return (CGPoint(x: xOrigin, y: yOrigin), anchor)
    }
}
