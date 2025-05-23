//
//  ModeSelectionView.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 22/5/25.
//

import SwiftUI

struct ModeOption: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let imageName: String
    let destination: AnyView
}

struct ModeSelectionView: View {
    
    let modes: [ModeOption] = [
        ModeOption(
            title: "Clásico",
            description: "Mantén una conversación de cualquier tema con el chat.",
            imageName: "bubble.left.and.bubble.right.fill",
            destination: AnyView(
                ChatBotIAView(chatBotIAViewModel: Resolver.shared.resolve(ChatBotIAViewModel.self, arguments: ChatMode.classicConversation))
            )
        ),
        ModeOption(
            title: "Corrección y mejoras",
            description: "Envía un texto y recibe consejos para mejorarlo.",
            imageName: "pencil.and.outline",
            destination: AnyView(
                ChatBotIAView(chatBotIAViewModel: Resolver.shared.resolve(ChatBotIAViewModel.self, arguments: ChatMode.textImprovement))
            )
        ),
        ModeOption(
            title: "Role Play",
            description: "Crea un escenario de roles y conversa como si fueras parte de él.",
            imageName: "person.2.wave.2.fill",
            destination: AnyView(RolePlaySetupView())
        ),
        ModeOption(
            title: "Gramática",
            description: "Haz preguntas sobre gramática y recibe explicaciones claras.",
            imageName: "book.fill",
            destination: AnyView(
                ChatBotIAView(chatBotIAViewModel: Resolver.shared.resolve(ChatBotIAViewModel.self, arguments: ChatMode.grammarHelp))
            )
        )
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    ForEach(modes) { mode in
                        NavigationLink(destination: mode.destination) {
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
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding()
            }
            .navigationTitle("Elige tu modo")
        }
    }
}
