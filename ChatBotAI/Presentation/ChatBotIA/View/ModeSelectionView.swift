//
//  ModeSelectionView.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 22/5/25.
//

import SwiftUI

struct ModeSelectionView: View {
    
    @State private var internalHideTabBarState: Bool = false
    
    let modes: [ModeOption] = [
        ModeOption(
            title: "Clásico",
            description: "Mantén una conversación de cualquier tema con el chat.",
            imageName: "bubble.left.and.bubble.right.fill",
            navigationRoute: .chatView(mode: .classicConversation)
        ),
        ModeOption(
            title: "Corrección y mejoras",
            description: "Envía un texto y recibe consejos para mejorarlo.",
            imageName: "pencil.and.outline",
            navigationRoute: .chatView(mode: .textImprovement)
        ),
        ModeOption(
            title: "Role Play",
            description: "Crea un escenario de roles y conversa como si fueras parte de él.",
            imageName: "person.2.wave.2.fill",
            navigationRoute: .rolePlaySetup
        ),
        ModeOption(
            title: "Gramática",
            description: "Haz preguntas sobre gramática y recibe explicaciones claras.",
            imageName: "book.fill",
            navigationRoute: .chatView(mode: .grammarHelp)
        )
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    ForEach(modes) { mode in
                        NavigationLink(value: mode.navigationRoute) {
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
                                    .foregroundColor(.blue) // Considera usar un color de tu tema
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
            .navigationDestination(for: NavigationChatBotIARoute.self) { route in
                destinationView(for: route)
            }
        }
        .onAppear {
            print("ModeSelectionView: .onAppear - setting internalHideTabBarState = false")
             if internalHideTabBarState {
             }
            self.internalHideTabBarState = false
        }
        .hideFloatingTabBar(internalHideTabBarState)
    }

    @ViewBuilder
    private func destinationView(for route: NavigationChatBotIARoute) -> some View {
        switch route {
        case .chatView(let chatMode):
            ChatBotIAView(chatBotIAViewModel: Resolver.shared.resolve(ChatBotIAViewModel.self, arguments: chatMode))
                .onAppear {
                    print("ChatBotIAView: .onAppear - setting internalHideTabBarState = true")
                    self.internalHideTabBarState = true
                }
                .onDisappear {
                    print("ChatBotIAView: .onDisappear - setting internalHideTabBarState = false")
                    self.internalHideTabBarState = false
                }
        case .rolePlaySetup:
            RolePlaySetupView()
                .onAppear {
                    print("RolePlaySetupView: .onAppear - setting internalHideTabBarState = true")
                    self.internalHideTabBarState = true
                }
        }
    }
}
