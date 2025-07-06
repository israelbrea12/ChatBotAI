//
//  ChatBotAIApp.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 11/3/25.
//

import SwiftUI

@main
struct ChatBotAIApp: App {
    
    @Environment(\.scenePhase) var scenePhase
    
    init(){
        Resolver.shared.injectDependencies()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onChange(
                    of: scenePhase
                ) { oldPhase, newPhase in
                    switch newPhase {
                    case .active:
                                       
                        if SessionManager.shared.userSession != nil {
                            print("App activa, configurando presencia...")
                            PresenceManager.shared.setupPresence()
                        }
                    case .background:
                        print(
                            "App en segundo plano, onDisconnect se encargará."
                        )
                    default:
                        // Otros estados como .inactive
                        break
                    }
                }
        }
    }
}
