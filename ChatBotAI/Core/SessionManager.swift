import FirebaseAuth
import Combine
import Firebase
import FirebaseStorage
import FirebaseFirestore

@MainActor
class SessionManager: NSObject, ObservableObject {
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User?
    
    let auth: Auth
    let storage: Storage
    let firestore: Firestore
    
    static let shared = SessionManager()
    
    private var authStateListenerHandle: AuthStateDidChangeListenerHandle?

    override init() {
        FirebaseApp.configure()
        
        self.auth = Auth.auth()
        self.storage = Storage.storage()
        self.firestore = Firestore.firestore()
        
        super.init()
        
        listenToAuthChanges()
    }

    private func listenToAuthChanges() {
        authStateListenerHandle = auth.addStateDidChangeListener { [weak self] _, user in
            guard let self = self else { return }

            // 🔥 Publicamos el usuario solo después de actualizarse completamente
            DispatchQueue.main.async {
                self.userSession = user
            }
        }
    }

    deinit {
        if let handle = authStateListenerHandle {
            auth.removeStateDidChangeListener(handle)
        }
    }
}
