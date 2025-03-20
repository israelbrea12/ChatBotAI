import FirebaseAuth
import Combine
import FirebaseStorage
import FirebaseFirestore

@MainActor // 🔥 Garantiza que todo en esta clase se ejecute en el hilo principal
class SessionManager: ObservableObject {
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User? = User.placeholder // 🔥 Se evita que sea `nil` al inicio
    let storage: Storage
    
    static let shared = SessionManager()
    private var authStateDidChangeListenerHandle: AuthStateDidChangeListenerHandle?

    private init() {
        self.userSession = Auth.auth().currentUser
        self.storage = Storage.storage()
        
        // Escuchar cambios de autenticación
        authStateDidChangeListenerHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let self = self else { return }
            self.userSession = user
            Task {
                await self.fetchUser()
            }
        }
        
        // Recuperar usuario al inicio de la app
        Task {
            await fetchUser()
        }
    }
    
    deinit {
        if let handle = authStateDidChangeListenerHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    
    func fetchUser() async {
        guard let currentUser = Auth.auth().currentUser else {
            self.currentUser = User.placeholder
            return
        }
        
        // Si ya tenemos los datos del usuario, no volvemos a cargarlos
        if self.currentUser?.id == currentUser.uid {
            return
        }
        
        let db = Firestore.firestore()
        do {
            let snapshot = try await db.collection("users").document(currentUser.uid).getDocument()
            if let data = snapshot.data() {
                let userModel = UserModel(
                    uid: currentUser.uid,
                    email: data["email"] as? String,
                    fullName: data["fullName"] as? String,
                    profileImageUrl: data["profileImageUrl"] as? String
                )
                self.currentUser = userModel.toDomain()
            } else {
                self.currentUser = User.placeholder
            }
        } catch {
            print("DEBUG: Error al obtener datos del usuario: \(error.localizedDescription)")
        }
    }
}

// 🔥 Definir un usuario "placeholder" para evitar retrasos en la UI
extension User {
    static let placeholder = User(id: "", fullName: "Cargando...", email: "", profileImageUrl: "")
}
