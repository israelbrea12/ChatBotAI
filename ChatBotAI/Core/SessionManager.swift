import FirebaseAuth
import Combine

@MainActor // 🔥 Garantiza que todo en esta clase se ejecute en el hilo principal
class SessionManager: ObservableObject {
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User? = User.placeholder // 🔥 Se evita que sea `nil` al inicio
    
    static let shared = SessionManager()
    private var authStateDidChangeListenerHandle: AuthStateDidChangeListenerHandle?

    private init() {
        self.userSession = Auth.auth().currentUser
        
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
        guard let _ = Auth.auth().currentUser else {
            self.currentUser = User.placeholder
            return
        } // 🔥 Evita llamadas innecesarias
        
        let fetchUserUseCase = Resolver.shared.resolve(FetchUserUseCase.self)
        let result = await fetchUserUseCase.execute(with: ())

        switch result {
        case .success(let user):
            self.currentUser = user
        case .failure(let error):
            print("Error al obtener usuario: \(error.localizedDescription)")
        }
    }
}

// 🔥 Definir un usuario "placeholder" para evitar retrasos en la UI
extension User {
    static let placeholder = User(id: "", fullName: "Cargando...", email: "")
}
