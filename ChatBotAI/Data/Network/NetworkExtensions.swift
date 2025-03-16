import FirebaseAuth
import FirebaseFirestore

extension Error {
    func toAppError() -> AppError {
        if let authError = self as? AuthErrorCode {
            switch authError.code {
            case .networkError:
                return .networkError("Error de conexión. Verifica tu internet.")
            case .wrongPassword:
                return .authenticationError("Contraseña incorrecta.")
            case .userNotFound:
                return .authenticationError("Usuario no encontrado.")
            case .emailAlreadyInUse:
                return .authenticationError("El correo ya está en uso.")
            case .weakPassword:
                return .authenticationError("La contraseña es demasiado débil.")
            default:
                return .authenticationError("Error de autenticación.")
            }
        }

        let nsError = self as NSError
        if nsError.domain == FirestoreErrorDomain {
            return .databaseError("Error en la base de datos: \(nsError.localizedDescription)")
        }

        return .unknownError(self.localizedDescription)
    }
}
