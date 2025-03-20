//
//  ChatBotAIApp.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 11/3/25.
//

import SwiftUI

@main
struct ChatBotAIApp: App {
    
    init(){
        Resolver.shared.injectDependencies()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
