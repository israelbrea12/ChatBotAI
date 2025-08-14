//
//  ContentView.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 18/6/25.
//

import SwiftUI

struct AuthView: View {
    
    @State private var showSignup: Bool = false
    @State private var isKeyboardShowing: Bool = false
    
    var body: some View {
        NavigationStack {
            LoginView(showSignup: $showSignup)
                .navigationDestination(isPresented: $showSignup) {
                    SignUpView(showSignup: $showSignup)
                }
                .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification), perform: { _ in
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
    
    @ViewBuilder
    func CircleView() -> some View {
        Circle()
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
