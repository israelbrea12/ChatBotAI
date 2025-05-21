//
//  ChatBotDataSource.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 15/5/25.
//

import Foundation
import GoogleGenerativeAI

protocol ChatBotDataSource {
    func generateResponse(prompt: String, apiKey: String) async -> Result<String, Error>
}

class ChatBotDataSourceImpl: ChatBotDataSource {

    private func getGenerativeModel(apiKey: String) -> GenerativeModel {
        return GenerativeModel(name: DataConstant.geminiModel, apiKey: apiKey)
    }

    func generateResponse(prompt: String, apiKey: String) async -> Result<String, Error> {
        let model = getGenerativeModel(apiKey: apiKey)
        do {
            let response = try await model.generateContent(prompt)
            if let text = response.text {
                return .success(text)
            } else {
                let noTextError = NSError(
                    domain: "ChatBotDataSourceError",
                    code: 1001,
                    userInfo: [NSLocalizedDescriptionKey: "La respuesta de la IA no contenía texto."]
                )
                return .failure(noTextError)
            }
        } catch {
            return .failure(error)
        }
    }
}
