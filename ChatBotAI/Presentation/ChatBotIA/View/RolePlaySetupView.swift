//
//  RolePlaySetupView.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 22/5/25.
//

import SwiftUI

struct RolePlaySetupView: View {
    
    @State private var userRole = ""
    @State private var botRole = ""
    @State private var scenario = ""
    
    @State private var internalHideTabBarState: Bool = false

    var body: some View {
        Form {
            TextField(LocalizedKeys.Placeholder.yourRole, text: $userRole)
            TextField(LocalizedKeys.Placeholder.botRole, text: $botRole)
            TextField(LocalizedKeys.Placeholder.scenario, text: $scenario)
            
            NavigationLink(value: NavigationChatBotIARoute.chatView(
                mode: .rolePlay(userRole: userRole, botRole: botRole, scenario: scenario))
            ) {
                Text(LocalizedKeys.ChatBot.roleplayStartButton)
            }
            .disabled(userRole.isEmpty || botRole.isEmpty || scenario.isEmpty)
        }
        .navigationTitle(LocalizedKeys.ChatBot.roleplayConfigureTitle)
        .hideFloatingTabBar(internalHideTabBarState)
    }
}
