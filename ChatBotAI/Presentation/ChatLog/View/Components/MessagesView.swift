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
    @ObservedObject var chatLogViewModel: ChatLogViewModel
    
    @State private var showContextMenu: Bool = false
    @State private var contextMenuMessage: Message? = nil
    @State private var contextMenuAnchorFrame: CGRect = .zero
    @State private var menuAnchorPointForTransition: UnitPoint = .center
    
    @State private var showDeleteMessageConfirmationAlert = false
    
    private let menuEstimatedSize = CGSize(width: 200, height: 110)
    private var messageDictionary: [String: Message] {
        Dictionary(uniqueKeysWithValues: messages.map { ($0.id, $0) })
    }
    
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
                ScrollViewReader { scrollViewProxy in
                    messageScrollView(proxy: scrollViewProxy)
                }
                
                if showContextMenu {
                    contextMenuOverlay(screenGeometry: screenGeometry)
                }
            }
            .alert("¿Eliminar Mensaje?", isPresented: $showDeleteMessageConfirmationAlert) {
                            Button("Cancelar", role: .cancel) { }
                Button("Eliminar", role: .destructive) {
                    Task {
                        guard let messageToDelete = contextMenuMessage else { return }
                        await chatLogViewModel.deleteMessage(messageId: messageToDelete.id)
                        contextMenuMessage = nil
                    }
                }
            } message: {
                Text("Este mensaje se eliminará para ti y para la otra persona. Esta acción no se puede deshacer.")
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
                            
                            let repliedMessage = message.replyTo.flatMap { messageDictionary[$0] }
                            
                            let shouldBlurMessage = (showContextMenu && message.id != contextMenuMessage?.id) ||
                                                    (chatLogViewModel.editingMessage != nil && message.id != chatLogViewModel.editingMessage?.id) ||
                                                    (chatLogViewModel.replyingToMessage != nil && message.id != chatLogViewModel.replyingToMessage?.id)
                            
                            MessageBubbleView(
                                message: message,
                                isCurrentUser: message.senderId == currentUserId,
                                repliedToMessage: repliedMessage,
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
                                    coordinator.selectedMessage = tappedMessage
                                }
                            )
                            .id(message.id)
                            .padding(.bottom, group.messages.last?.id == message.id ? 5 : 0)
                            .blur(radius: shouldBlurMessage ? 5 : 0)
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
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardDidShowNotification)) { _ in
                scrollToBottom(proxy: proxy, animated: true)
            }
            .onChange(of: messages.count) {
                scrollToBottom(proxy: proxy)
            }
            .onChange(of: messages.last?.id) {
                scrollToBottom(proxy: proxy)
            }
        }
        
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

            let containerFrame = screenGeometry.frame(in: .global)
            
            let bubbleFrameInContainer = CGRect(
                x: contextMenuAnchorFrame.origin.x - containerFrame.origin.x,
                y: contextMenuAnchorFrame.origin.y - containerFrame.origin.y,
                width: contextMenuAnchorFrame.width,
                height: contextMenuAnchorFrame.height
            )
            
            // 3. Pasamos este nuevo marco relativo y el TAMAÑO del contenedor a nuestra función de cálculo.
            let (menuOrigin, anchorPoint) = calculateMenuPlacement(
                bubbleFrame: bubbleFrameInContainer,
                menuSize: menuEstimatedSize,
                containerSize: containerFrame.size,
                isBubbleCurrentUser: message.senderId == currentUserId
            )
            
            // --- FIN DE LA SOLUCIÓN ---
            
            MessageActionMenuView(
                items: [
                    MessageActionItem(label: "Responder", systemImage: "arrowshape.turn.up.left.fill") {
                        chatLogViewModel.startReplyingToMessage(message)
                        
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                            self.showContextMenu = false
                        }
                    },
                    MessageActionItem(label: "Editar", systemImage: "pencil.circle.fill") {
                        if message.messageType == .text {
                            chatLogViewModel.startEditingMessage(message)
                        }
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                            self.showContextMenu = false
                        }
                    },
                    MessageActionItem(label: "Eliminar", systemImage: "trash.circle.fill") {
                        Task {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                                self.showContextMenu = false
                            }
                            self.showDeleteMessageConfirmationAlert = true
                        }
                    }
                ],
                showMenu: $showContextMenu
            )
            .frame(width: menuEstimatedSize.width, height: menuEstimatedSize.height)
            .position(
                x: menuOrigin.x + menuEstimatedSize.width / 2,
                y: menuOrigin.y + menuEstimatedSize.height / 2
            )
            .transition(.scale(scale: 0.9, anchor: anchorPoint).combined(with: .opacity))
            .onAppear {
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
