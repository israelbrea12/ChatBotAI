//
//  ChatBotAIApp.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 11/3/25.
//

import SwiftUI

@main
struct ChatBotAIApp: App {
    
    @StateObject var viewModel = AuthViewModel()
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
        }
    }
}
