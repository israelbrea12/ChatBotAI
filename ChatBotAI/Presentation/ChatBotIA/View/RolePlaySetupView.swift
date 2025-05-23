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
    @State private var navigateToChat = false

    var body: some View {
        Form {
            TextField("Tu rol", text: $userRole)
            TextField("Rol del chat", text: $botRole)
            TextField("Escenario", text: $scenario)

            NavigationLink(destination:
                ChatBotIAView(
                    chatBotIAViewModel: Resolver.shared.resolve(
                        ChatBotIAViewModel.self,
                        arguments: ChatMode.rolePlay(userRole: userRole, botRole: botRole, scenario: scenario)
                    )
                ), isActive: $navigateToChat
            ) {
                Button("Iniciar roleplay") {
                    navigateToChat = true
                }
            }
            .disabled(userRole.isEmpty || botRole.isEmpty || scenario.isEmpty)
        }
        .navigationTitle("Configura el Roleplay")
    }
}
