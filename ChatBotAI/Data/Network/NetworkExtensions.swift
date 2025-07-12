import Foundation
import FirebaseAuth

extension Error {
    func toAppError() -> AppError {
        if let appError = self as? AppError {
            return appError
        }
        
        if let authError = self as? AuthErrorCode {
            switch authError.code {
            case .emailAlreadyInUse:
                return .emailAlreadyInUse
            case .invalidEmail:
                return .invalidEmail
            case .wrongPassword:
                return .wrongPassword
            case .userNotFound:
                return .userNotFound
            case .weakPassword:
                return .weakPassword
            case .requiresRecentLogin:
                return .requiresRecentLogin
            default:
                return .unknownError(self.localizedDescription)
            }
        }
        
        // Fallback para cualquier otro tipo de error.
        return .unknownError(self.localizedDescription)
    }
}
