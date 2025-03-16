import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        NavigationStack {
            ZStack {
                switch authViewModel.state {
                case .initial, .loading:
                    ProgressView()
                        .onAppear {
                            Task {
                                await authViewModel.fetchUser()
                            }
                        }
                    
                case .success:
                    settingsContent()
                    
                case .error(let errorMessage):
                    errorView(errorMsg: errorMessage)
                    
                case .empty:
                    emptyView()
                }
            }
            .navigationTitle("Settings")
        }
    }
    
    private func settingsContent() -> some View {
        List {
            if let user = authViewModel.currentUser {
                Section {
                    userProfile(user: user)
                }
                
                Section("General") {
                    versionInfo()
                }
                
                Section("Account") {
                    signOutButton()
                    deleteAccountButton()
                }
            }
        }
    }
    
    private func userProfile(user: User) -> some View {
        HStack {
            Text(user.initials)
                .font(.title)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(width: 72, height: 72)
                .background(Color(.systemGray3))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(user.fullName ?? "")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .padding(.top, 4)
                
                Text(user.email ?? "")
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
        }
    }
    
    private func versionInfo() -> some View {
        HStack {
            SettingsRowView(imageName: "gear", title: "Version", tintColor: Color(.systemGray))
            Spacer()
            Text("1.0.0")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
    }
    
    private func signOutButton() -> some View {
        Button {
            authViewModel.signOut()
        } label: {
            SettingsRowView(imageName: "arrow.left.circle.fill", title: "Sign out", tintColor: .red)
        }
    }
    
    private func deleteAccountButton() -> some View {
        Button {
            print("Delete account..")
        } label: {
            SettingsRowView(imageName: "xmark.circle.fill", title: "Delete Account", tintColor: .red)
        }
    }
    
    private func errorView(errorMsg: String) -> some View {
        InfoView(message: errorMsg)
    }
    
    private func emptyView() -> some View {
        InfoView(message: "No user data found")
    }
}
