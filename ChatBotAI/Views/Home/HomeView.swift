//
//  HomeView.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 12/3/25.
//

import SwiftUI

struct HomeView: View {
    @StateObject var viewModel = HomeViewModel()
    @EnvironmentObject var sessionManager: SessionManager // 🔥 Obtener datos en tiempo real

    var body: some View {
        NavigationStack {
            ZStack {
                switch viewModel.state {
                case .initial, .loading:
                    loadingView()
                case .error(let errorMessage):
                    errorView(errorMsg: errorMessage)
                case .success:
                    successView()
                default:
                    emptyView()
                }
            }
        }
    }
    
    private func successView() -> some View {
        Text("Bienvenido, \(sessionManager.currentUser?.fullName ?? "Invitado")") // 🔥 Ahora reacciona a cambios
    }

    private func loadingView() -> some View {
        ProgressView()
    }

    private func emptyView() -> some View {
        InfoView(message: "No data found")
    }

    private func errorView(errorMsg: String) -> some View {
        InfoView(message: errorMsg)
    }
}
