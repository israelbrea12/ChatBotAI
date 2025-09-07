//
//  UserProfileViewModel.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 7/9/25.
//


import Foundation
import Combine

@MainActor
class UserProfileViewModel: ObservableObject {
    @Published var user: User?
    private var cancellables = Set<AnyCancellable>()

    init() {
        // Se suscribe a la variable $currentUser del SessionManager
        // y asigna cualquier cambio a su propia variable 'user'.
        SessionManager.shared.$currentUser
            .receive(on: DispatchQueue.main)
            .assign(to: \.user, on: self)
            .store(in: &cancellables)
    }
}