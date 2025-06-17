//
//  MessagesView.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 26/3/25.
//

import SwiftUI

struct MessagesView: View {
    @StateObject var chatLogViewModel = Resolver.shared.resolve(
        ChatLogViewModel.self
    )
    @Namespace private var bottomID
    let messages: [Message]
    let currentUserId: String?
    @State private var showContextMenu: Bool = false
    @State private var contextMenuMessage: Message? = nil
    @State private var contextMenuAnchorFrame: CGRect = .zero
    @State private var menuAnchorPointForTransition: UnitPoint = .center
    @State private var showFullScreenImage = false
    @State private var fullScreenImageUrl: URL? = nil
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
                                        },
                                        onImageTap: { imageUrl in
                                            self.fullScreenImageUrl = imageUrl
                                            self.showFullScreenImage = true
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
                }
                if showContextMenu {
                    Color.black.opacity(0.001)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                                self.showContextMenu = false
                                self.contextMenuMessage = nil
                            }
                        }
                    if let message = contextMenuMessage, contextMenuAnchorFrame != .zero {
                        let messagesViewGlobalOrigin = screenGeometry.frame(in: .global).origin
                        let bubbleFrameInMessagesViewSpace = CGRect(
                            x: contextMenuAnchorFrame.origin.x - messagesViewGlobalOrigin.x,
                            y: contextMenuAnchorFrame.origin.y - messagesViewGlobalOrigin.y,
                            width: contextMenuAnchorFrame.width,
                            height: contextMenuAnchorFrame.height
                        )
                        let (menuOriginInMessagesView, determinedAnchor) = calculateMenuPlacement(
                            bubbleFrame: bubbleFrameInMessagesViewSpace,
                            menuSize: menuEstimatedSize,
                            containerBounds: CGRect(origin: .zero, size: screenGeometry.size),
                            isBubbleCurrentUser: message.senderId == currentUserId
                        )
                        MessageActionMenuView(
                            items: [
                                MessageActionItem(label: "Editar", systemImage: "pencil.circle.fill") {
                                    print("Acción: Editar mensaje con ID '\(message.id)'")
                                    // Implementa la lógica de edición
                                    withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                                        self.showContextMenu = false
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
                        .frame(width: menuEstimatedSize.width, height: menuEstimatedSize.height)
                        .position(
                            x: menuOriginInMessagesView.x + menuEstimatedSize.width / 2,
                            y: menuOriginInMessagesView.y + menuEstimatedSize.height / 2
                        )
                        .onAppear {
                            self.menuAnchorPointForTransition = determinedAnchor
                        }
                        .transition(.scale(scale: 0.9, anchor: menuAnchorPointForTransition).combined(with: .opacity))
                    }
                }
            }
            .fullScreenCover(isPresented: $showFullScreenImage) {
                FullScreenImageView(url: fullScreenImageUrl, isPresented: $showFullScreenImage)
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
