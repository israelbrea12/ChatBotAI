//
//  MessageActionItem 2.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 1/6/25.
//

import SwiftUI

struct MessageActionItem: Identifiable {
    let id = UUID()
    let label: String
    let systemImage: String
    let action: () -> Void
}
