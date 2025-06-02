//
//  ModeOption.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 1/6/25.
//


import SwiftUI

struct ModeOption: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let description: String
    let imageName: String
    let navigationRoute: NavigationChatBotIARoute
}
