//
//  UICoordinator.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 17/6/25.
//

import SwiftUI

@Observable
class UICoordinator {
    var selectedMessage: Message? {
        didSet {
            if selectedMessage != nil {
                toggleView(show: true)
            }
        }
    }
    
    var currentUserID: String?
    var otherUserName: String?
    var animateView: Bool = false
    var showDetailView: Bool = false
    var imageMessages: [Message] = []
    var detailScrollPosition: String?
    var detailIndicatorPosition: String?
    var offset: CGSize = .zero
    var dragProgress: CGFloat = 0
    
    func setup(messages: [Message]) {
        self.imageMessages = messages.filter { $0.messageType == .image && $0.imageURL != nil }
    }
    
    func didDetailPageChanged() {
        if let updatedItem = imageMessages.first(where: { $0.id == detailScrollPosition }) {
            selectedMessage = updatedItem
            withAnimation(.easeInOut(duration: 0.2)) {
                detailIndicatorPosition = updatedItem.id
            }
        }
    }
    
    func didDetailIndicatorPageChanged() {
        if let updatedItem = imageMessages.first(where: { $0.id == detailIndicatorPosition }) {
            selectedMessage = updatedItem
            detailScrollPosition = updatedItem.id
        }
    }
    
    func toggleView(show: Bool) {
        let animation: Animation = .spring(response: 0.4, dampingFraction: 0.85)
        
        if show {
            detailScrollPosition = selectedMessage?.id
            detailIndicatorPosition = selectedMessage?.id
            
            DispatchQueue.main.async {
                withAnimation(animation) {
                    self.animateView = true
                } completion: {
                    self.showDetailView = true
                }
            }
        } else {
            showDetailView = false
            withAnimation(animation) {
                animateView = false
            } completion: {
                self.resetAnimationProperties()
            }
        }
    }
    
    func resetAnimationProperties() {
        selectedMessage = nil
        detailScrollPosition = nil
        detailIndicatorPosition = nil
        offset = .zero
        dragProgress = 0
    }
}
