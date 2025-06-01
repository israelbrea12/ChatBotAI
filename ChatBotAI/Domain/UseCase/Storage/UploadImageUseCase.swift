//
//  UploadImageUseCase.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 1/6/25.
//

import Foundation

protocol UploadImageUseCase { // Definido como protocolo para consistencia
    func execute(with params: UploadImageParams) async -> Result<URL, AppError>
}

class UploadImageUseCaseImpl: UploadImageUseCase {
    private let storageRepository: StorageRepository

    init(storageRepository: StorageRepository) {
        self.storageRepository = storageRepository
    }

    func execute(with params: UploadImageParams) async -> Result<URL, AppError> {
        return await storageRepository.uploadImage(
            imageData: params.imageData,
            chatId: params.chatId,
            messageId: params.messageId
        )
    }
}
