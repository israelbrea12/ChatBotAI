//
//  ContentView.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 11/3/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var sessionManager = SessionManager.shared
    
    var body: some View {
        Group {
            if sessionManager.userSession != nil {
                MainView()
            } else {
                LoginView()
            }
        }
    }
}

#Preview {
    ContentView()
}

