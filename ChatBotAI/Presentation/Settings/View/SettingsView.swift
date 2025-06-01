import SwiftUI
import SDWebImageSwiftUI

struct SettingsView: View {
    
    @StateObject var settingsViewModel = Resolver.shared.resolve(SettingsViewModel.self)
    
    @State private var showDeleteAlert = false
    @State private var showSignOutAlert = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                switch settingsViewModel.state {
                case .initial,
                        .loading:
                    loadingView()
                    
                case .success:
                    successView()
                    
                case .error(let errorMessage):
                    errorView(errorMsg: errorMessage)
                    signOutButton()
                    
                case .empty:
                    emptyView()
                    signOutButton()
                }
            }
            .navigationTitle("Settings")
        }
    }
    
    private func successView() -> some View {
        List {
            if let user = settingsViewModel.currentUser {
                
                Section {
                    userProfile(user: user)
                }
                
                Section("General") {
                    listButton()
                    broadcastButton()
                    starredButton()
                    linkedDevicesButton()
                }
                
                Section("Settings") {
                    accountButton()
                    privacyButton()
                    chatsButton()
                    notificationsButton()
                    storageButton()
                }
                
                Section("Account") {
                    signOutButton()
                    deleteAccountButton()
                }
                
                Section("") {
                    helpButton()
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
            showSignOutAlert = true
        } label: {
            SettingsRowView(imageName: "arrow.left.circle.fill", title: "Sign out", tintColor: .red)
        }
        .alert("¿Seguro que quieres cerrar sesión?", isPresented: $showSignOutAlert) {
            Button("Cancelar", role: .cancel) { }
            Button("Cerrar sesión", role: .destructive) {
                Task {
                    settingsViewModel.signOut()
                }
            }
        }
    }
    
    private func deleteAccountButton() -> some View {
        Button {
            showDeleteAlert = true
        } label: {
            SettingsRowView(imageName: "xmark.circle.fill", title: "Delete Account", tintColor: .red)
        }
        .alert("¿Seguro que quieres eliminar tu cuenta?", isPresented: $showDeleteAlert) {
            Button("Cancelar", role: .cancel) { }
            Button("Eliminar", role: .destructive) {
                Task {
                    await settingsViewModel.deleteAccount()
                }
            }
        }
    }
    
    private func listButton() -> some View {
        SettingsRowView(imageName: "person.crop.rectangle.stack", title: "Chats", tintColor: .black)
    }
        
    private func broadcastButton() -> some View {
        SettingsRowView(imageName: "megaphone", title: "Broadcast Lists", tintColor: .black)
    }
        
    private func starredButton() -> some View {
        SettingsRowView(imageName: "star", title: "Starred Messages", tintColor: .black)
    }
        
    private func linkedDevicesButton() -> some View {
        SettingsRowView(imageName: "laptopcomputer", title: "Linked Devices", tintColor: .black).symbolRenderingMode(.monochrome)
    }
        
    private func accountButton() -> some View {
            SettingsRowView(imageName: "key", title: "Account", tintColor: .black)
    }
        
    private func privacyButton() -> some View {
            SettingsRowView(imageName: "lock", title: "Privacy", tintColor: .black)
    }
        
    private func chatsButton() -> some View {
            SettingsRowView(imageName: "message", title: "Chats", tintColor: .black)
    }
        
    private func notificationsButton() -> some View {
            SettingsRowView(imageName: "bell", title: "Notifications", tintColor: .black)
    }
        
    private func storageButton() -> some View {
            SettingsRowView(imageName: "arrow.up.arrow.down", title: "Storage and Data", tintColor: .black)
    }
        
    private func helpButton() -> some View {
        SettingsRowView(imageName: "info.circle", title: "Help", tintColor: .black)
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
