//
//  DeleteAccountUseCase.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 30/3/25.
//

import Foundation
import FirebaseAuth

struct DeleteAccountUseCase: UseCaseProtocol {
    
    private let authRepository: AuthRepository
    private let chatRepository: ChatRepository
    private let storageRepository: StorageRepository
    private let userRepository: UserRepository

    init(authRepository: AuthRepository, chatRepository: ChatRepository,
         storageRepository: StorageRepository, userRepository: UserRepository) {
        self.authRepository = authRepository
        self.chatRepository = chatRepository
        self.storageRepository = storageRepository
        self.userRepository = userRepository
    }
    
    func execute(with params: Void) async -> Result<Void, AppError> {
        guard let userId = Auth.auth().currentUser?.uid else {
            return .failure(.authenticationError("No user logged in"))
        }
        
        do {
            print("Iniciando proceso de eliminación de cuenta para el usuario: \(userId)")
            
            // Elimino los datos en paralelo, datos del user, foto de perfil y ids de chats.
            try await withThrowingTaskGroup(of: Void.self) { group in
                
                group.addTask {
                    let result = await self.userRepository.deleteUserData(userId: userId)
                    if case .failure(let error) = result { throw error }
                }
                
                group.addTask {
                    let result = await self.storageRepository.deleteProfileImage(userId: userId)
                    if case .failure(let error) = result { throw error }
                }
                
                group.addTask {
                    let result = await self.chatRepository.deleteAllUserChatsIds(userId: userId)
                    if case .failure(let error) = result { throw error }
                }
                
                try await group.waitForAll()
            }
            
            print("Limpieza de datos completada. Procediendo a eliminar la autenticación.")
            
            // Una vez hecha la limpieza finalmene llamo a deleteFirebaseAuthUser para eliminar el user de firebase
            let finalResult = await authRepository.deleteFirebaseAuthUser()
            
            switch finalResult {
            case .success:
                return .success(())
            case .failure(let error):
                throw error
            }
            
        } catch let error as AppError {
            print("🛑 ERROR durante el proceso de eliminación de la cuenta: \(error.localizedDescription)")
            return .failure(error)
        } catch {
            print("🛑 ERROR desconocido durante el proceso de eliminación: \(error.localizedDescription)")
            return .failure(.unknownError(error.localizedDescription))
        }
    }
}
