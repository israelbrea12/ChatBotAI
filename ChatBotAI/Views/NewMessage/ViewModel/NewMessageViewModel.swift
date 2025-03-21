//
//  NewMessageViewModel.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 20/3/25.
//

import SwiftUI
import Combine

@MainActor
class NewMessageViewModel: ObservableObject {
    @Published var users: [User] = []
    @Published var state: ViewState = .initial
    
    private let fetchAllUserExceptCurrentUseCase: FetchAllUsersExceptCurrentUseCase
    private var cancellables = Set<AnyCancellable>()
    
    init(fetchAllUsersExceptCurrentUseCase: FetchAllUsersExceptCurrentUseCase) {
        self.fetchAllUserExceptCurrentUseCase = fetchAllUsersExceptCurrentUseCase
        fetchAllUsersExceptCurrent()
    }
    
    func fetchAllUsersExceptCurrent() {
        state = .loading
        Task {
            let result = await fetchAllUserExceptCurrentUseCase.execute(with: ())
            DispatchQueue.main.async {
                switch result {
                case .success(let users):
                    self.users = users.compactMap { $0 } // Elimina los nil
                    self.state = self.users.isEmpty ? .empty : .success
                case .failure(let error):
                    print("Error fetching users: \(error.localizedDescription)")
                    self.state = .error("Failed to load users")
                }
            }
        }
    }
}

