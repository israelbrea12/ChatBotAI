//
//  DeleteUserChatParams.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 18/5/25.
//

class DeleteUserChatUseCase: UseCaseProtocol {
    private let chatRepository: ChatRepository
    
    init(chatRepository: ChatRepository) {
        self.chatRepository = chatRepository
    }
    
    func execute(with params: DeleteUserChatParams) async -> Result<Void, AppError> {
        await chatRepository.deleteUserChat(userId: params.userId, chatId: params.chatId)
    }
}
