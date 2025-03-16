import Foundation
import FirebaseAuth

@MainActor
class AuthViewModel: ObservableObject {
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User?
    @Published var state: ViewState = .success
    
    let signInUseCase: SignInUseCase
    let signUpUseCase: SignUpUseCase
    let signOutUseCase: SignOutUseCase
    let fetchUserUseCase: FetchUserUseCase
    
    init(signInUseCase: SignInUseCase,
         signUpUseCase: SignUpUseCase,
         signOutUseCase: SignOutUseCase,
         fetchUserUseCase: FetchUserUseCase) {
        
        self.signInUseCase = signInUseCase
        self.signUpUseCase = signUpUseCase
        self.signOutUseCase = signOutUseCase
        self.fetchUserUseCase = fetchUserUseCase
        
        self.userSession = Auth.auth().currentUser
        
        Task {
            await fetchUser()
        }
    }
    
    func signIn(withEmail email: String, password: String) async {
        let result = await signInUseCase.execute(with: SignInParam(email: email, password: password))
        switch result {
        case .success(let user):
            self.userSession = Auth.auth().currentUser
            self.currentUser = user
        case .failure(let error):
            print("DEBUG: Sign-in error \(error.localizedDescription)")
        }
    }
    
    func createUser(withEmail email: String, password: String, fullName: String) async {
        let result = await signUpUseCase.execute(with: SignUpParam(email: email, fullName: fullName, password: password))
        switch result {
        case .success(let user):
            self.userSession = Auth.auth().currentUser
            self.currentUser = user
        case .failure(let error):
            print("DEBUG: Sign-up error \(error.localizedDescription)")
        }
    }
    
    func signOut() {
        print("Antes de signOut: \(Auth.auth().currentUser?.email ?? "No user")")
        let result = signOutUseCase.execute(with: ())
        switch result {
        case .success:
            DispatchQueue.main.async {
                self.userSession = nil
                self.currentUser = nil
                print("Después de signOut: \(Auth.auth().currentUser?.email ?? "No user")")
            }
        case .failure(let error):
            print("DEBUG: Sign-out error \(error.localizedDescription)")
        }
    }
    
    func fetchUser() async {
        let result = await fetchUserUseCase.execute(with: ())
        switch result {
        case .success(let user):
            self.currentUser = user
        case .failure(let error):
            print("DEBUG: Fetch user error \(error.localizedDescription)")
        }
    }
}
