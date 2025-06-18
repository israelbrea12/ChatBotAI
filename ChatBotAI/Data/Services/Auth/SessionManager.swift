import FirebaseAuth
import Combine
import Firebase
import FirebaseStorage
import FirebaseFirestore
import FirebaseDatabase

@MainActor
class SessionManager: NSObject, ObservableObject {
    
    @Published var userSession: FirebaseAuth.User?
    var currentUser: User?
    
    let auth: Auth
    let storage: Storage
    let firestore: Firestore
    
    static let shared = SessionManager()
    
    override init() {
        FirebaseApp.configure()
        
        self.auth = Auth.auth()
        self.storage = Storage.storage()
        self.firestore = Firestore.firestore()
        
        self.userSession = auth.currentUser
        super.init()
        
    }
    
}
