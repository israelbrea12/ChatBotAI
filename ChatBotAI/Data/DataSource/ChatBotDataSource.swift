//
//  ChatBotDataSource.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 15/5/25.
//


// Data/DataSources/Remote/ChatBotRemoteDataSource.swift (o simplemente ChatBotDataSource.swift)
import Foundation
import GoogleGenerativeAI // El SDK se usa aquí

protocol ChatBotDataSource {
    func generateResponse(prompt: String, apiKey: String) async -> Result<String, Error>
}

class ChatBotDataSourceImpl: ChatBotDataSource {
    // El modelo se instancia aquí. Podrías inyectar el nombre del modelo si necesitas flexibilidad.
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
                // Considera un error más específico del dominio si "no text" es un caso esperado
                let noTextError = NSError(
                    domain: "ChatBotDataSourceError",
                    code: 1001,
                    userInfo: [NSLocalizedDescriptionKey: "La respuesta de la IA no contenía texto."]
                )
                return .failure(noTextError)
            }
        } catch {
            // El error del SDK ya es de tipo `Error`
            return .failure(error)
        }
    }
}
