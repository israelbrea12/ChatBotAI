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
    
    func resolve<T, Arg1>(_ serviceType: T.Type, arguments arg1: Arg1) -> T {
        container.resolve(serviceType, argument: arg1)!
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
        
        container.register(ChatDataSource.self) { resolver in
            ChatDataSourceImpl()
        }.inObjectScope(.container)
        
        container.register(MessageDataSource.self) { resolver in
            MessageDataSourceImpl()
        }.inObjectScope(.container)
        
        container.register(ChatBotDataSource.self) { resolver in
            ChatBotDataSourceImpl()
        }.inObjectScope(.container)
        
        container.register(StorageDataSource.self) { resolver in
            StorageDataSourceImpl()
        }.inObjectScope(.container)
        
        container.register(PresenceDataSource.self) { resolver in
            PresenceDataSourceImpl()
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
        
        container.register(ChatRepository.self){resolver in
            ChatRepositoryImpl(
                chatDataSource: resolver.resolve(ChatDataSource.self)!
            )
        }.inObjectScope(.container)
        
        container.register(MessageRepository.self){resolver in
            MessageRepositoryImpl(
                messageDataSource: resolver.resolve(MessageDataSource.self)!
            )
        }.inObjectScope(.container)
        
        container.register(ChatBotRepository.self){resolver in
            ChatBotRepositoryImpl(
                chatBotDataSource: resolver.resolve(ChatBotDataSource.self)!)
        }.inObjectScope(.container)
        
        container.register(StorageRepository.self){resolver in
            StorageRepositoryImpl(
                storageDataSource: resolver.resolve(StorageDataSource.self)!)
        }.inObjectScope(.container)
        
        container.register(PresenceRepository.self){resolver in
            PresenceRepositoryImpl(
                presenceDataSource: resolver.resolve(PresenceDataSource.self)!)
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
                authRepository: resolver.resolve(AuthRepository.self)!,
                chatRepository: resolver.resolve(ChatRepository.self)!,
                storageRepository: resolver.resolve(StorageRepository.self)!,
                userRepository: resolver.resolve(UserRepository.self)!
            )
        }.inObjectScope(.container)
        
        container.register(CreateChatUseCase.self) { resolver in
            CreateChatUseCase(
                chatRepository: resolver.resolve(ChatRepository.self)!
            )
        }.inObjectScope(.container)
        
        container.register(FetchUserChatsUseCase.self) { resolver in
            FetchUserChatsUseCase(
                chatRepository: resolver.resolve(ChatRepository.self)!
            )
        }.inObjectScope(.container)
        
        container.register(FetchUserByIdUseCase.self) { resolver in
            FetchUserByIdUseCase(
                repository: resolver.resolve(UserRepository.self)!
            )
        }.inObjectScope(.container)
        
        container.register(SendMessageUseCase.self) { resolver in
            SendMessageUseCase(
                messageRepository: resolver.resolve(MessageRepository.self)!
            )
        }.inObjectScope(.container)
        
        container.register(FetchMessagesUseCase.self) { resolver in
            FetchMessagesUseCase(
                messageRepository: resolver.resolve(MessageRepository.self)!
            )
        }.inObjectScope(.container)
        
        container.register(ObserveMessagesUseCase.self) { resolver in
            ObserveMessagesUseCase(
                messageRepository: resolver.resolve(MessageRepository.self)!
            )
        }.inObjectScope(.container)
        
        container.register(ObserveUserChatsUseCase.self) { resolver in
            ObserveUserChatsUseCase(
                chatRepository: resolver.resolve(ChatRepository.self)!
            )
        }.inObjectScope(.container)
        
        container.register(SendMessageToChatBotUseCase.self) { resolver in
            SendMessageToChatBotUseCase(
                chatBotRepository: resolver.resolve(ChatBotRepository.self)!
            )
        }.inObjectScope(.container)
        
        container.register(DeleteUserChatUseCase.self) { resolver in
            DeleteUserChatUseCase(
                chatRepository: resolver.resolve(ChatRepository.self)!
            )
        }.inObjectScope(.container)
        
        container.register(DeleteMessageUseCase.self) { resolver in
            DeleteMessageUseCase(
                messageRepository: resolver.resolve(MessageRepository.self)!
            )
        }.inObjectScope(.container)

        container.register(UploadImageUseCase.self) { resolver in
            UploadImageUseCaseImpl(
                storageRepository: resolver.resolve(StorageRepository.self)!
            )
        }.inObjectScope(.container)
        
        container.register(SendPasswordResetUseCase.self) { resolver in
            SendPasswordResetUseCase(
                authRepository: resolver.resolve(AuthRepository.self)!
            )
        }.inObjectScope(.container)
        
        container.register(ObservePresenceUseCase.self) { resolver in
            ObservePresenceUseCase(
                presenceRepository: resolver.resolve(PresenceRepository.self)!
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
                deleteAccountUseCase: resolver.resolve(DeleteAccountUseCase.self)!
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
                fetchUserUseCase: resolver.resolve(FetchUserUseCase.self)!,
                createChatUseCase: resolver.resolve(CreateChatUseCase.self)!,
                fetchUserChatsUseCase: resolver.resolve(FetchUserChatsUseCase.self)!,
                fetchUserByIdUseCase: resolver.resolve(FetchUserByIdUseCase.self)!,
                observeUserChatsUseCase: resolver.resolve(ObserveUserChatsUseCase.self)!,
                deleteUserChatUseCase: resolver.resolve(DeleteUserChatUseCase.self)!
                
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
                sendMessageUseCase: resolver.resolve(SendMessageUseCase.self)!,
                fetchMessagesUseCase: resolver.resolve(FetchMessagesUseCase.self)!,
                observeMessagesUseCase: resolver.resolve(ObserveMessagesUseCase.self)!,
                deleteMessageUseCase: resolver.resolve(DeleteMessageUseCase.self)!,
                uploadImageUseCase: resolver.resolve(UploadImageUseCase.self)!,
                observePresenceUseCase: resolver.resolve(ObservePresenceUseCase.self)!
            )
        }.inObjectScope(.container)
        
        container.register(ChatBotIAViewModel.self) { resolver, chatMode in
            ChatBotIAViewModel(
                sendMessageToChatBotUseCase: resolver.resolve(SendMessageToChatBotUseCase.self)!,
                chatMode: chatMode
            )
        }.inObjectScope(.transient)
        
        container.register(ForgotPasswordViewModel.self) { resolver in
            ForgotPasswordViewModel(
                sendPasswordResetUseCase: resolver
                    .resolve(SendPasswordResetUseCase.self)!
            )
        }.inObjectScope(.container)
    
    }
}
