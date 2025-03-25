//
//  NewMessageView.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 20/3/25.
//

import SwiftUI
import SDWebImageSwiftUI

struct NewMessageView: View {
    @StateObject var viewModel = Resolver.shared.resolve(NewMessageViewModel.self)
    let didSelectNewUser: (User) -> ()
    
    @Environment(\.presentationMode) var presentationMode
    
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
                    InfoView(message: "No users available")
                }
            }
            .navigationTitle("New Message")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Text("Cancel")
                    }
                }
            }
            .onAppear {
                Task {
                    await viewModel.fetchAllUsersExceptCurrent()
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
                Text(user.fullName ?? "Unknown")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(user.email ?? "No email")
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
        }
    }

}
