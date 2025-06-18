//
//  ContentView.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 18/6/25.
//


// MARK: ContentView.swift

import SwiftUI

struct AuthView: View {
    /// View Properties
    @State private var showSignup: Bool = false
    /// Keyboard Status
    @State private var isKeyboardShowing: Bool = false
    
    var body: some View {
        NavigationStack {
            // Pasamos el binding a LoginView
            LoginView(showSignup: $showSignup)
                .navigationDestination(isPresented: $showSignup) {
                    // La navegación nos lleva a SignUpView
                    SignUpView(showSignup: $showSignup)
                }
                /// Checking if any Keyboard is Visible
                .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification), perform: { _ in
                    /// Disabling it for signup view
                    if !showSignup {
                        isKeyboardShowing = true
                    }
                })
                .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification), perform: { _ in
                    isKeyboardShowing = false
                })
        }
        .overlay {
            CircleView()
                .animation(.smooth(duration: 0.45, extraBounce: 0), value: showSignup)
                .animation(.smooth(duration: 0.45, extraBounce: 0), value: isKeyboardShowing)
        }
    }
    
    /// Moving Blurred background
    @ViewBuilder
    func CircleView() -> some View {
        Circle()
            // Usando los nuevos colores azules para el fondo
            .fill(.linearGradient(colors: [.lightBlue, .appBlue], startPoint: .top, endPoint: .bottom))
            .frame(width: 200, height: 200)
            .offset(x: showSignup ? 90 : -90, y: -90 - (isKeyboardShowing ? 200 : 0))
            .blur(radius: 15)
            .hSpacing(showSignup ? .trailing : .leading)
            .vSpacing(.top)
    }
}

#Preview {
    ContentView()
}
