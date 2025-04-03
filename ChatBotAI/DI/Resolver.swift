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
        injectService()
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
        container.register(UserDataSource.self) { _ in
            UserDataSourceImpl()
        }.inObjectScope(.container)
                
        container.register(AuthDataSource.self) { resolver in
            AuthDataSourceImpl(
                userDataSource: resolver.resolve(UserDataSource.self)!,
                googleAuthService: resolver.resolve(GoogleAuthService.self)!
            )
        }.inObjectScope(.container)
    }
}

// MARK: - Service

extension Resolver {
    @MainActor func injectService() {
        
        container.register(GoogleAuthService.self) { resolver in
            GoogleAuthServiceImpl(
                
            )
        }.inObjectScope(.container)
    }
}


// MARK: - Repository

extension Resolver {
    @MainActor func injectRepository() {
        container.register(AuthRepository.self){resolver in
            AuthRepositoryImpl(
                dataSource: resolver.resolve(AuthDataSource.self)!
            )
        }.inObjectScope(.container)
        container.register(UserRepository.self){resolver in
            UserRepositoryImpl(
                userDataSource: resolver.resolve(UserDataSource.self)!
            )
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
            FetchUserUseCase(repository: resolver.resolve(UserRepository.self)!)
        }.inObjectScope(.container)
        
        container.register(FetchAllUsersExceptCurrentUseCase.self) { resolver in
            FetchAllUsersExceptCurrentUseCase(
                repository: resolver.resolve(UserRepository.self)!
            )
        }.inObjectScope(.container)
        
        container.register(SignInWithGoogleUseCase.self) { resolver in
            SignInWithGoogleUseCase(
                repository: resolver.resolve(AuthRepository.self)!
            )
        }.inObjectScope(.container)
        
        container.register(SignInWithAppleUseCase.self) { resolver in
            SignInWithAppleUseCase(
                repository: resolver.resolve(AuthRepository.self)!
            )
        }.inObjectScope(.container)
        
        container.register(DeleteAccountUseCase.self) { resolver in
            DeleteAccountUseCase(
                repository: resolver.resolve(AuthRepository.self)!
            )
        }.inObjectScope(.container)
    }

}


// MARK: - ViewModel

extension Resolver {
    @MainActor func injectViewModel() {
        
        
        container.register(SettingsViewModel.self) { resolver in
            SettingsViewModel(
                signOutUseCase: resolver.resolve(SignOutUseCase.self)!,
                fetchUserUseCase: resolver.resolve(FetchUserUseCase.self)!,
                deleteAccountUseCase: resolver
                    .resolve(DeleteAccountUseCase.self)!
            )
        }.inObjectScope(.container)
        
        container.register(LoginViewModel.self) { resolver in
            LoginViewModel(
                signInUseCase: resolver.resolve(SignInUseCase.self)!,
                signInWithGoogleUseCase: resolver.resolve(SignInWithGoogleUseCase.self)!,
                signInWithAppleUseCase: resolver.resolve(SignInWithAppleUseCase.self)!
            )
        }.inObjectScope(.container)
        
        container.register(RegistrationViewModel.self) { resolver in
            RegistrationViewModel(

                signUpUseCase: resolver.resolve(SignUpUseCase.self)!
            )
        }.inObjectScope(.container)
        
        container.register(HomeViewModel.self) { resolver in
            HomeViewModel(
                fetchUserUseCase: resolver.resolve(FetchUserUseCase.self)!
            )
        }.inObjectScope(.container)
        
        container.register(NewMessageViewModel.self) { resolver in
            NewMessageViewModel(
                fetchAllUsersExceptCurrentUseCase: resolver
                    .resolve(FetchAllUsersExceptCurrentUseCase.self)!
            )
        }.inObjectScope(.container)
        
        container.register(ChatLogViewModel.self) { resolver in
            ChatLogViewModel(
                
            )
        }.inObjectScope(.container)
    }
}
