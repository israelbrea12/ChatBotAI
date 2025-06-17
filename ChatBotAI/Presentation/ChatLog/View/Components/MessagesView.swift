//
//  MessagesView.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 26/3/25.
//

import SwiftUI

struct MessagesView: View {
    
    @Environment(UICoordinator.self) private var coordinator
    
    @Namespace private var bottomID
    
    let messages: [Message]
    let currentUserId: String?
    let chatLogViewModel: ChatLogViewModel
    
    @State private var showContextMenu: Bool = false
    @State private var contextMenuMessage: Message? = nil
    @State private var contextMenuAnchorFrame: CGRect = .zero
    @State private var menuAnchorPointForTransition: UnitPoint = .center
    
    private let menuEstimatedSize = CGSize(width: 200, height: 110)
    
    var groupedMessages: [(date: String, messages: [Message])] {
        Dictionary(grouping: messages) { message in
            guard let timestamp = message.sentAt else { return "Desconocido" }
            let date = Date(timeIntervalSince1970: timestamp)
            return date.whatsappFormattedTimeAgoWithoutAMOrPM()
        }
        .map { (key: String, value: [Message]) in (date: key, messages: value) }
        .sorted { a, b in
            guard let firstDate = a.messages.first?.sentAt, let secondDate = b.messages.first?.sentAt else { return false }
            return firstDate < secondDate
        }
    }
    
    var body: some View {
        GeometryReader { screenGeometry in
            ZStack {
                // El ScrollViewReader y el ScrollView principal
                ScrollViewReader { scrollViewProxy in
                    messageScrollView(proxy: scrollViewProxy)
                }
                
                // La superposición del menú contextual
                if showContextMenu {
                    contextMenuOverlay(screenGeometry: screenGeometry)
                }
            }
        }
    }
    
    @ViewBuilder
        private func messageScrollView(proxy: ScrollViewProxy) -> some View {
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
                                    // Lógica para mostrar el menú contextual
                                    self.contextMenuMessage = tappedMessage
                                    self.contextMenuAnchorFrame = bubbleFrameGlobal
                                    withAnimation(.spring(response: 0.35, dampingFraction: 0.65)) {
                                        self.showContextMenu = true
                                    }
                                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                },
                                onImageTap: { tappedMessage in
                                    // Lógica para la animación de la imagen
                                    coordinator.selectedMessage = tappedMessage
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
                    scrollToBottom(proxy: proxy, animated: false)
                }
            }
            .onChange(of: messages.count) {
                scrollToBottom(proxy: proxy)
            }
            .onChange(of: messages.last?.id) {
                scrollToBottom(proxy: proxy)
            }
        }
        
        // --- 3. VISTA DEL MENÚ CONTEXTUAL (EXTRAÍDA) ---
        @ViewBuilder
        private func contextMenuOverlay(screenGeometry: GeometryProxy) -> some View {
            Color.black.opacity(0.001)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                        self.showContextMenu = false
                        self.contextMenuMessage = nil
                    }
                }
            
            if let message = contextMenuMessage, contextMenuAnchorFrame != .zero {
                let (menuOrigin, anchorPoint) = calculateMenuPlacement(
                    bubbleFrame: contextMenuAnchorFrame,
                    menuSize: menuEstimatedSize,
                    containerBounds: screenGeometry.frame(in: .global),
                    isBubbleCurrentUser: message.senderId == currentUserId
                )
                
                MessageActionMenuView(
                    items: [
                        MessageActionItem(label: "Editar", systemImage: "pencil.circle.fill") {
                            // Lógica de edición
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                                self.showContextMenu = false
                            }
                        },
                        MessageActionItem(label: "Eliminar", systemImage: "trash.circle.fill") {
                            Task {
                                if let msg = self.contextMenuMessage {
                                    await chatLogViewModel.deleteMessage(messageId: msg.id)
                                }
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                                    self.showContextMenu = false
                                }
                            }
                        }
                    ],
                    showMenu: $showContextMenu
                )
                .frame(width: menuEstimatedSize.width, height: menuEstimatedSize.height)
                // Usamos .position para colocar el CENTRO de la vista del menú.
                .position(x: menuOrigin.x + menuEstimatedSize.width / 2, y: menuOrigin.y + menuEstimatedSize.height / 2)
                .transition(.scale(scale: 0.9, anchor: anchorPoint).combined(with: .opacity))
                .onAppear {
                    // Actualiza el punto de ancla para la animación de transición.
                    self.menuAnchorPointForTransition = anchorPoint
                }
            }
        }
    
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
}
