//
//  MainView.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 12/3/25.
//

import SwiftUI

enum AppTab: String, CaseIterable, FLoatingTabProtocol {
    case home = "Chats"
    case chatbot = "ChatBotIA"
    case settings = "Settings"
    
    var symbolImage: String {
        switch self {
        case .home: "bubble.left.and.text.bubble.right"
        case .chatbot: "translate"
        case .settings: "gear"
        }
    }
    
    var tabTitle: String {
        switch self {
        case .home: LocalizedKeys.Tab.chats
        case .chatbot: LocalizedKeys.Tab.chatbot
        case .settings: LocalizedKeys.Tab.settings
        }
    }
}

struct MainView: View {
    
    @State private var activeTab: AppTab = .home
    
    var body: some View {
        FloatingTabView(selection: $activeTab) { tab, tabBarHeight in
            switch activeTab {
            case .home:
                HomeView()
            case .chatbot:
                ModeSelectionView()
            case .settings:
                SettingsView()
            }
        }
    }
}

#Preview {
    MainView()
        .preferredColorScheme(.dark)
}
