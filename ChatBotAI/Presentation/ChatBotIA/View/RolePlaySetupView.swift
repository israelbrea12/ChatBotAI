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
            TextField("Tu rol", text: $userRole)
            TextField("Rol del chat", text: $botRole)
            TextField("Escenario", text: $scenario)
            
            NavigationLink(value: NavigationChatBotIARoute.chatView(
                mode: .rolePlay(userRole: userRole, botRole: botRole, scenario: scenario))
            ) {
                Text("Iniciar roleplay") // El Text es ahora la etiqueta directa
            }
            .disabled(userRole.isEmpty || botRole.isEmpty || scenario.isEmpty)
        }
        .navigationTitle("Configura el Roleplay")
        .hideFloatingTabBar(internalHideTabBarState)
    }
}
