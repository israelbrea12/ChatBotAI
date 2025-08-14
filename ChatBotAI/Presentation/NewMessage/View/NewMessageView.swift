//
//  NewMessageView.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 20/3/25.
//

import SwiftUI
import SDWebImageSwiftUI

struct NewMessageView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @StateObject var viewModel = Resolver.shared.resolve(NewMessageViewModel.self)
    
    let didSelectNewUser: (User) -> ()
    
    var body: some View {
        NavigationView {
            ZStack {
                switch viewModel.state {
                case .initial, .loading:
                    ProgressView()
                case .success:
                    userListView()
                case .error(let errorMessage):
                    InfoView(message: errorMessage)
                case .empty:
                    InfoView(message: LocalizedKeys.AppError.noUsersAvailable)
                }
            }
            .navigationTitle(LocalizedKeys.Chat.newMessage)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Text(LocalizedKeys.Common.cancel)
                    }
                }
            }
            .onAppear {
                Task {
                    await viewModel.fetchMatchingUsers()
                }
            }
        }
    }
    
    private func userListView() -> some View {
        List(viewModel.users, id: \.id) { user in
            Button {
                didSelectNewUser(user)
            } label: {
                userRow(user: user)
            }
        }
    }
    
    private func userRow(user: User) -> some View {
        HStack {
            WebImage(url: URL(string: user.profileImageUrl ?? "")) { phase in
                switch phase {
                case .empty:
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .foregroundColor(.gray)
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                case .failure:
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .foregroundColor(.gray)
                @unknown default:
                    EmptyView()
                }
            }
            
            VStack(alignment: .leading) {
                Text(user.fullName ?? LocalizedKeys.DefaultValues.defaultFullName)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(user.email ?? LocalizedKeys.DefaultValues.defaultEmail)
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
        }
    }
    
}
