import SwiftUI
import SDWebImageSwiftUI

struct SettingsView: View {
    @StateObject var settingsViewModel = Resolver.shared.resolve(SettingsViewModel.self)
    
    var body: some View {
        NavigationStack {
            ZStack {
                switch settingsViewModel.state {
                case .initial,
                        .loading:
                    loadingView()
                    
                case .success:
                    settingsContent()
                    
                case .error(let errorMessage):
                    errorView(errorMsg: errorMessage)
                    signOutButton()
                    
                case .empty:
                    emptyView()
                }
            }
            .navigationTitle("Settings")
        }
    }
    
    private func settingsContent() -> some View {
        List {
            if let user = settingsViewModel.currentUser {
                
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
            
            WebImage(
                url: URL(string: user.profileImageUrl ?? "")
            ) { phase in
                switch phase {
                case .empty:
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 72, height: 72)
                        .foregroundColor(.gray)
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 72, height: 72)
                        .clipShape(Circle())
                case .failure:
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 72, height: 72)
                        .foregroundColor(.gray)
                @unknown default:
                    EmptyView()
                }
            }
            
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
            settingsViewModel.signOut()
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
    
    private func loadingView() -> some View {
        ProgressView()
    }
    
    private func errorView(errorMsg: String) -> some View {
        InfoView(message: errorMsg)
    }
    
    private func emptyView() -> some View {
        InfoView(message: "No user data found")
    }
}
