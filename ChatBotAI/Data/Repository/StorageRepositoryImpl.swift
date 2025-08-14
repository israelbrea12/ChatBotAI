//
//  StorageRepositoryImpl.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 1/6/25.
//


import Foundation

class StorageRepositoryImpl: StorageRepository {
    private let storageDataSource: StorageDataSource
    
    init(storageDataSource: StorageDataSource) {
        self.storageDataSource = storageDataSource
    }
    
    func uploadImage(imageData: Data, chatId: String, messageId: String) async -> Result<URL, AppError> {
        do {
            let url = try await storageDataSource.uploadImage(imageData: imageData, chatId: chatId, messageId: messageId)
            return .success(url)
        } catch {
            return .failure(error.toAppError())
        }
    }
    
    func deleteProfileImage(userId: String) async -> Result<Void, AppError> {
        do {
            try await storageDataSource.deleteProfileImage(userId: userId)
            return .success(())
        } catch {
            return .failure(error.toAppError())
        }
    }
}
