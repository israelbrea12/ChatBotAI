//
//  ModeSelectionView.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 22/5/25.
//

// ModeSelectionView.swift
import SwiftUI

struct ModeSelectionView: View {
    
    // Asegúrate que ChatMode sea Hashable para que NavigationRoute.chatView(mode:) lo sea.
    let modes: [ModeOption] = [
        ModeOption(
            title: "Clásico",
            description: "Mantén una conversación de cualquier tema con el chat.",
            imageName: "bubble.left.and.bubble.right.fill",
            navigationRoute: .chatView(mode: .classicConversation) // Usa NavigationRoute
        ),
        ModeOption(
            title: "Corrección y mejoras",
            description: "Envía un texto y recibe consejos para mejorarlo.",
            imageName: "pencil.and.outline",
            navigationRoute: .chatView(mode: .textImprovement) // Usa NavigationRoute
        ),
        ModeOption(
            title: "Role Play",
            description: "Crea un escenario de roles y conversa como si fueras parte de él.",
            imageName: "person.2.wave.2.fill",
            navigationRoute: .rolePlaySetup // Usa NavigationRoute
        ),
        ModeOption(
            title: "Gramática",
            description: "Haz preguntas sobre gramática y recibe explicaciones claras.",
            imageName: "book.fill",
            navigationRoute: .chatView(mode: .grammarHelp) // Usa NavigationRoute
        )
    ]
    
    var body: some View {
        // 1. Reemplaza NavigationView con NavigationStack
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    ForEach(modes) { mode in
                        // 2. Usa NavigationLink(value:label:)
                        NavigationLink(value: mode.navigationRoute) { // Pasa el NavigationRoute como valor
                            HStack {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(mode.title)
                                        .font(.title2)
                                        .bold()
                                    
                                    Text(mode.description)
                                        .font(.body)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Image(systemName: mode.imageName)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 40, height: 40)
                                    .foregroundColor(.blue)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                        }
                        .buttonStyle(PlainButtonStyle()) // Mantenlo si te gusta el estilo
                    }
                }
                .padding()
            }
            .navigationTitle("Elige tu modo")
            // 3. Añade navigationDestination para manejar las rutas
            .navigationDestination(for: NavigationChatBotIARoute.self) { route in
                switch route {
                case .chatView(let chatMode):
                    ChatBotIAView(chatBotIAViewModel: Resolver.shared.resolve(ChatBotIAViewModel.self, arguments: chatMode))
                case .rolePlaySetup:
                    RolePlaySetupView()
                }
            }
        }
    }
}
