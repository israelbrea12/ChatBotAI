//
//  HomeView.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 12/3/25.
//

import SwiftUI

struct HomeView: View {
    @StateObject var viewModel = HomeViewModel()
    
    
    var body: some View {
        NavigationStack {
            ZStack (
                content: {
                    switch viewModel.state {
                    case .initial,
                            .loading:
                        loadingView()
                    case .error(let errorMessage):
                        errorView(errorMsg: errorMessage)
                    case .success:
                        successView()
                    default:
                        emptyView()
                    }
                }
            )}
    }
    
    private func successView() -> some View {
        Text("success")
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

#Preview {
    HomeView()
}
