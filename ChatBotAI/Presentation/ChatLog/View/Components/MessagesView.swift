//
//  MessagesView.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 26/3/25.
//

import SwiftUI

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
    
    private let singleItemMenuSize = CGSize(width: 200, height: 45)
    private let multiItemMenuSize = CGSize(width: 200, height: 135)
    
    private var messageDictionary: [String: Message] {
        Dictionary(uniqueKeysWithValues: messages.map { ($0.id, $0) })
    }
    
    var groupedMessages: [(date: String, messages: [Message])] {
        Dictionary(grouping: messages) { message in
            guard let timestamp = message.sentAt else { return LocalizedKeys.Common.unknown }
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
            .alert(LocalizedKeys.Chat.deleteMessageAlertTitle, isPresented: $showDeleteMessageConfirmationAlert) {
                Button(LocalizedKeys.Common.cancel, role: .cancel) { }
                Button(LocalizedKeys.Common.delete, role: .destructive) {
                    Task {
                        guard let messageToDelete = contextMenuMessage else { return }
                        await chatLogViewModel.deleteMessage(messageId: messageToDelete.id)
                        contextMenuMessage = nil
                    }
                }
            } message: {
                Text(LocalizedKeys.Chat.deleteMessageAlertBody)
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
            
            let menuItems = generateMenuItems(for: message)
            
            let menuSize = menuItems.count == 1 ? singleItemMenuSize : multiItemMenuSize
            
            let containerFrame = screenGeometry.frame(in: .global)
            
            let bubbleFrameInContainer = CGRect(
                x: contextMenuAnchorFrame.origin.x - containerFrame.origin.x,
                y: contextMenuAnchorFrame.origin.y - containerFrame.origin.y,
                width: contextMenuAnchorFrame.width,
                height: contextMenuAnchorFrame.height
            )
            
            let (menuOrigin, anchorPoint) = calculateMenuPlacement(
                bubbleFrame: bubbleFrameInContainer,
                menuSize: menuSize,
                containerSize: containerFrame.size,
                isBubbleCurrentUser: message.senderId == currentUserId
            )
            
            MessageActionMenuView(
                items: menuItems,
                showMenu: $showContextMenu
            )
            .frame(width: menuSize.width, height: menuSize.height)
            .position(
                x: menuOrigin.x + menuSize.width / 2,
                y: menuOrigin.y + menuSize.height / 2
            )
            .transition(.scale(scale: 0.9, anchor: anchorPoint).combined(with: .opacity))
            .onAppear {
                self.menuAnchorPointForTransition = anchorPoint
            }
        }
    }
    
    private func generateMenuItems(for message: Message) -> [MessageActionItem] {
        var items: [MessageActionItem] = [
            MessageActionItem(label: LocalizedKeys.Chat.reply, systemImage: "arrowshape.turn.up.left.fill") {
                chatLogViewModel.startReplyingToMessage(message)
                withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                    self.showContextMenu = false
                }
            }
        ]
        
        if message.senderId == currentUserId {
            if message.messageType == .text {
                items.append(
                    MessageActionItem(label: LocalizedKeys.Common.edit, systemImage: "pencil.circle.fill") {
                        chatLogViewModel.startEditingMessage(message)
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                            self.showContextMenu = false
                        }
                    }
                )
            }
            
            items.append(
                MessageActionItem(label: LocalizedKeys.Common.delete, systemImage: "trash.circle.fill") {
                    Task {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                            self.showContextMenu = false
                        }
                        try? await Task.sleep(nanoseconds: 150_000_000)
                        self.showDeleteMessageConfirmationAlert = true
                    }
                }
            )
        }
        
        return items
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
