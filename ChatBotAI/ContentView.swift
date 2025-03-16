//
//  ContentView.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 11/3/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        Group {
            if authViewModel.userSession != nil {
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

