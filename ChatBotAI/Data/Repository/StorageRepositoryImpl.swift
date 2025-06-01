//
//  StorageRepositoryImpl.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 1/6/25.
//


import Foundation

class StorageRepositoryImpl: StorageRepository {
    private let storageDataSource: StorageDataSource // Usas el StorageDataSource que ya tienes

    init(storageDataSource: StorageDataSource) {
        self.storageDataSource = storageDataSource
    }

    func uploadImage(imageData: Data, chatId: String, messageId: String) async -> Result<URL, AppError> {
        do {
            let url = try await storageDataSource.uploadImage(imageData: imageData, chatId: chatId, messageId: messageId)
            return .success(url)
        } catch {
            // Asumiendo que tienes una extensión `toAppError()` para convertir errores genéricos
            return .failure(error.toAppError())
        }
    }
}