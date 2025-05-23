//
//  ModeSelectionView.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 22/5/25.
//

import SwiftUI

struct ModeSelectionView: View {
    var body: some View {
        NavigationView {
            List {
                NavigationLink("Nivel Básico") {
                    ChatBotIAView(
                        chatBotIAViewModel: Resolver.shared.resolve(ChatBotIAViewModel.self, arguments: ChatMode.basicCorrection)
                    )
                }

                NavigationLink("Nivel Avanzado") {
                    ChatBotIAView(
                        chatBotIAViewModel: Resolver.shared.resolve(ChatBotIAViewModel.self, arguments: ChatMode.advancedCorrection)
                    )
                }

                NavigationLink("Role Play") {
                    RolePlaySetupView()
                }

                NavigationLink("Gramática") {
                    ChatBotIAView(
                        chatBotIAViewModel: Resolver.shared.resolve(ChatBotIAViewModel.self, arguments: ChatMode.grammarHelp)
                    )
                }
            }
            .navigationTitle("Elige tu modo")
        }
    }
}
