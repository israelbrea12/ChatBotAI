//
//  NetworkExtensions.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 2/4/25.
//

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
        
        return .unknownError(self.localizedDescription)
    }
}
