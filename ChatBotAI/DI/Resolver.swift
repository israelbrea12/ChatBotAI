//
//  Resolver.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 15/3/25.
//

import Foundation
import Swinject

public final class Resolver {
    static let shared = Resolver()
    
    private var container = Container()
    
    private init() {
    }
    
    @MainActor func injectDependencies() {
        injectNetwork()
        injectDataSource()
        injectRepository()
        injectUseCase()
        injectViewModel()
    }
    
    func resolve<T>(_ type: T.Type) -> T {
        container.resolve(T.self)!
    }
}

// MARK: - Network

extension Resolver {
    @MainActor func injectNetwork() {
        
    }
}

// MARK: - DataSource
extension Resolver {
    @MainActor func injectDataSource() {
        container.register(AuthDataSource.self) { _ in
            AuthDataSourceImpl()
        }.inObjectScope(.container)
        
        container.register(StorageDataSource.self) { _ in
            StorageDataSourceImpl()
        }.inObjectScope(.container)
    }
}

// MARK: - Repository

extension Resolver {
    @MainActor func injectRepository() {
        container.register(AuthRepository.self){resolver in
            AuthRepositoryImpl(dataSource: resolver.resolve(AuthDataSource.self)!)
        }.inObjectScope(.container)
        
        container.register(StorageRepository.self){resolver in
            StorageRepositoryImpl(dataSource: resolver.resolve(StorageDataSource.self)!)
        }.inObjectScope(.container)
    }
}


// MARK: - UseCase

extension Resolver {
    @MainActor func injectUseCase() {
        container.register(SignInUseCase.self) { resolver in
            SignInUseCase(repository: resolver.resolve(AuthRepository.self)!)
        }.inObjectScope(.container)
        
        container.register(SignUpUseCase.self) { resolver in
            SignUpUseCase(repository: resolver.resolve(AuthRepository.self)!)
        }.inObjectScope(.container)
        
        container.register(SignOutUseCase.self) { resolver in
            SignOutUseCase(repository: resolver.resolve(AuthRepository.self)!)
        }.inObjectScope(.container)
        
        container.register(FetchUserUseCase.self) { resolver in
            FetchUserUseCase(repository: resolver.resolve(AuthRepository.self)!)
        }.inObjectScope(.container)
        
        container.register(UploadImageUseCase.self) { resolver in
            UploadImageUseCase(repository: resolver.resolve(StorageRepository.self)!)
        }.inObjectScope(.container)
    }

}


// MARK: - ViewModel

extension Resolver {
    @MainActor func injectViewModel() {
        
        
        container.register(SettingsViewModel.self) { resolver in
            SettingsViewModel(
                signOutUseCase: resolver.resolve(SignOutUseCase.self)!                )
            }.inObjectScope(.container)
        
        container.register(AuthViewModel.self) { resolver in
                AuthViewModel(
                    signInUseCase: resolver.resolve(SignInUseCase.self)!,
                    signUpUseCase: resolver.resolve(SignUpUseCase.self)!,
                    uploadImageUseCase: resolver.resolve(UploadImageUseCase.self)!
                )
            }.inObjectScope(.container)
    }
}
