//
//  HomeView.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 12/3/25.
//

import SwiftUI
import SDWebImageSwiftUI

struct HomeView: View {
    @StateObject var homeViewModel = Resolver.shared.resolve(HomeViewModel.self)

    var body: some View {
        NavigationStack {
            ScrollView {
                switch homeViewModel.state {
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
            .navigationTitle("Chats")
            .toolbar{
                ToolbarItem (placement: .topBarTrailing) {
                    Button {
                        // Llamada al ViewModel al método para añadir nuevo chat.
                        homeViewModel.isPresentingNewMessageView = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .resizable()
                            .frame(width: 32, height: 32)
                            .foregroundStyle(.green)
                    }
                    .sheet(isPresented: $homeViewModel.isPresentingNewMessageView) {
                        NewMessageView { selectedUser in
                            homeViewModel.startNewChat(with: selectedUser)
                        }
                    }
                }
                ToolbarItem (placement: .topBarLeading) {
                
                    HStack {
                        WebImage(
                            url: URL(string: homeViewModel.currentUser?.profileImageUrl ?? "")
                        ) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                                    .frame(width: 36, height: 36)
                                    .overlay(RoundedRectangle(cornerRadius: 44 )
                                        .stroke(Color.gray, lineWidth: 0.5))
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 36, height: 36)
                                    .clipShape(Circle())
                                    .overlay(RoundedRectangle(cornerRadius: 44 )
                                        .stroke(Color.gray, lineWidth: 0.5))
                            case .failure:
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .frame(width: 36, height: 36)
                                    .foregroundColor(.gray)
                                    .overlay(RoundedRectangle(cornerRadius: 44 )
                                        .stroke(Color.gray, lineWidth: 0.5))
                            @unknown default:
                                EmptyView()
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(homeViewModel.currentUser?.fullName ?? "")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(Color(.label))
                            HStack {
                                Circle()
                                    .foregroundColor(.green)
                                    .frame(width: 14, height: 14)
                                Text("online")
                                    .font(.system(size: 12))
                                    .foregroundColor(Color(.lightGray))
                            }
                        }

                    }
                }
            }
        }
    }
    
    private func successView() -> some View {
        ForEach(0..<10, id: \.self) { num in
            VStack {
                HStack (spacing: 16) {
                    Image(systemName: "person.fill")
                        .font(.system(size: 32))
                        .padding(8)
                        .overlay(RoundedRectangle(cornerRadius: 44 )
                            .stroke(Color.gray, lineWidth: 0.5))
                    
                    VStack(alignment: .leading) {
                        Text("username")
                            .font(.system(size: 16, weight: .bold))
                        Text("Message sent to user")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Color(.lightGray))
                    }
                    Spacer()
                    
                    Text("22d")
                        .font(.system(size: 14, weight: .semibold))
                }
                Divider()
                    .padding(.vertical, 8)
            }
            .padding(.horizontal)
        }
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
