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
    
    @State private var showSplash = true
    
    init(){
        Resolver.shared.injectDependencies()
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                ContentView()
                    .onChange(of: scenePhase) { oldPhase, newPhase in
                        switch newPhase {
                        case .active:
                            if SessionManager.shared.userSession != nil {
                                PresenceManager.shared.setupPresence()
                            }
                        case .background:
                            print("App en segundo plano.")
                        default:
                            break
                        }
                    }

                if showSplash {
                    SplashView(isActive: $showSplash)
                        .transition(.opacity)
                }
            }
        }
    }
}
