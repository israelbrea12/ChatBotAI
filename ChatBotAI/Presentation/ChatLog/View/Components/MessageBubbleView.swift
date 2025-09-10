//
//  MessageBubbleView.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 8/4/25.
//

import SwiftUI
import SDWebImageSwiftUI

struct MessageBubbleView: View {
    @Environment(UICoordinator.self) private var coordinator
    
    let message: Message
    let isCurrentUser: Bool
    let repliedToMessage: Message?
    
    var onLongPress: ((_ message: Message, _ frame: CGRect) -> Void)? = nil
    var onImageTap: ((Message) -> Void)? = nil
    
    @State private var bubbleFrame: CGRect = .zero
    
    private let imageMaxWidth: CGFloat = UIScreen.main.bounds.width * 0.65
    private let imageMaxHeight: CGFloat = 300
    private let bubbleCornerRadius: CGFloat = 16
    private let borderThickness: CGFloat = 3
    
    var body: some View {
        HStack {
            if isCurrentUser { Spacer(minLength: UIScreen.main.bounds.width * 0.15) }
            VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: 2) {
                VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: 0) {
                    if let repliedMessage = repliedToMessage {
                        RepliedMessagePreview(
                            message: repliedMessage,
                            isReplyBubbleFromCurrentUser: self.isCurrentUser
                        )
                        .fixedSize(horizontal: false, vertical: true)
                    }
                    
                    messageContent()
                        .background(isCurrentUser ? Color.blue : Color(UIColor.systemGray5))
                        .clipShape(RoundedRectangle(cornerRadius: bubbleCornerRadius))
                        .fixedSize(horizontal: false, vertical: true)
                }
                .background(
                    GeometryReader { proxy in
                        Color.clear
                            .onAppear { bubbleFrame = proxy.frame(in: .global) }
                            .onChange(of: proxy.frame(in: .global)) { _, newFrame in bubbleFrame = newFrame }
                    }
                )
                .gesture(LongPressGesture(minimumDuration: 0.45).onEnded { _ in
                    onLongPress?(message, bubbleFrame)
                })
                
                HStack(spacing: 4) {
                    Text(Date(timeIntervalSince1970: message.sentAt ?? Date().timeIntervalSince1970).BublesFormattedTime())
                        .font(.caption2)
                        .foregroundColor(.gray)
                    
                    if message.isEdited {
                        Text(LocalizedKeys.Chat.edited)
                            .font(.caption2)
                            .foregroundColor(.gray)
                            .italic()
                    }
                }
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
        switch message.messageType {
        case .text:
            textMessageView()
                .padding(10)
        case .image:
            imageMessageView()
                .padding(4)
        }
    }
}

private extension MessageBubbleView {
    @ViewBuilder
    func textMessageView() -> some View {
        Text(message.text.isEmpty ? "" : message.text)
            .foregroundColor(isCurrentUser ? .white : .primary)
            .fixedSize(horizontal: false, vertical: true)
    }
    
    @ViewBuilder
    func unsupportedMessageView() -> some View {
        Text(LocalizedKeys.Chat.unsupportedMessageType)
            .font(.caption)
            .foregroundColor(.gray)
            .padding(10)
            .background(Color(UIColor.systemGray5))
            .clipShape(RoundedRectangle(cornerRadius: bubbleCornerRadius))
    }
    
    @ViewBuilder
    func imageMessageView() -> some View {
        VStack(alignment: .leading, spacing: 0) {
            if message.isUploading {
                if let data = message.localImageData, let uiImage = UIImage(data: data) {
                    imageDisplay(image: Image(uiImage: uiImage), overlay: { uploadOverlay })
                }
            } else if message.uploadFailed {
                imageDisplay(image: nil, overlay: { failureOverlay })
            } else if let urlString = message.imageURL, let url = URL(string: urlString) {
                WebImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        imageDisplay(image: nil, overlay: { loadingOverlay })
                    case .success(let image):
                        imageDisplay(image: image, overlay: { EmptyView() })
                    case .failure:
                        imageDisplay(image: nil, overlay: { failureOverlay })
                    @unknown default:
                        EmptyView()
                    }
                }
                .onTapGesture {
                    onImageTap?(message)
                }
                .anchorPreference(key: HeroKey.self, value: .bounds) { anchor in
                    return [message.id + "SOURCE": anchor]
                }
                .opacity(coordinator.selectedMessage?.id == message.id ? 0 : 1)
            }
            
            if !message.text.isEmpty {
                Text(message.text)
                    .font(.body)
                    .foregroundColor(isCurrentUser ? .white : .primary)
                    .padding(.horizontal, 10)
                    .padding(.top, 6)
                    .padding(.bottom, 8)
            }
        }
    }
    
    @ViewBuilder
    func imageDisplay<Overlay: View>(image: Image?, @ViewBuilder overlay: () -> Overlay) -> some View {
        ZStack {
            Color(UIColor.systemGray5)
                .aspectRatio(1, contentMode: .fill)
                .frame(maxWidth: imageMaxWidth, maxHeight: imageMaxHeight)
            
            if let image = image {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: imageMaxWidth, maxHeight: imageMaxHeight)
                    .transition(.opacity.animation(.easeInOut))
            }
            
            overlay()
        }
        .clipShape(RoundedRectangle(cornerRadius: bubbleCornerRadius))
    }
    
    @ViewBuilder
    var uploadOverlay: some View {
        ZStack {
            Color.black.opacity(0.4)
            ProgressView().tint(.white)
        }
    }
    
    @ViewBuilder
    var loadingOverlay: some View {
        ProgressView()
    }
    
    @ViewBuilder
    var failureOverlay: some View {
        ZStack {
            Color.black.opacity(0.4)
            VStack(spacing: 5) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.title2)
                    .foregroundColor(.white)
                Text(LocalizedKeys.Chat.loadImageError)
                    .font(.caption)
                    .foregroundColor(.white)
            }
        }
    }
}

struct RepliedMessagePreview: View {
    let message: Message
    let isReplyBubbleFromCurrentUser: Bool
    
    var body: some View {
        HStack(spacing: 8) {
            
            Capsule()
                .fill(Color.blue)
                .frame(width: 3)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(message.senderId == SessionManager.shared.currentUser?.id ? LocalizedKeys.Chat.replyingToYou : message.senderName)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                
                HStack(spacing: 4) {
                    if message.messageType == .image && !(message.imageURL ?? "").isEmpty {
                        Image(systemName: "photo.fill")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Text(message.messageType == .image && message.text.isEmpty ? LocalizedKeys.Chat.replyingToImage : message.text)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(
            (isReplyBubbleFromCurrentUser ? Color(UIColor.systemGray5) : Color.blue.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 12))
        )
        .padding(.bottom, 4)
    }
}
