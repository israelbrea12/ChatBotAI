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
    
    @StateObject var authViewModel = Resolver.shared.resolve(AuthViewModel.self)
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
        }
    }
}
