//
//  LocalizedKeys.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 28/7/25.
//

import Foundation

// Helper para simplificar la llamada a la localización.
fileprivate extension String {
    /// Devuelve la cadena localizada asociada con esta clave.
    func localized() -> String {
        return NSLocalizedString(self, comment: "")
    }
}

/// Enum central para gestionar todas las cadenas localizadas de la aplicación de forma segura.
enum LocalizedKeys {

    // MARK: - Common Strings
    enum Common {
        static var ok: String { "common_ok".localized() }
        static var cancel: String { "common_cancel".localized() }
        static var delete: String { "common_delete".localized() }
        static var save: String { "common_save".localized() }
        static var edit: String { "common_edit".localized() }
        static var `continue`: String { "common_continue".localized() }
        static var send: String { "common_send".localized() }
        static var or: String { "common_or".localized() }
        static var error: String { "common_error".localized() }
        static var settings: String { "common_settings".localized() }
        static var chats: String { "common_chats".localized() }
        static var chat: String { "common_chat".localized() }
        static var today: String { "common_today".localized() }
        static var yesterday: String { "common_yesterday".localized() }
        static var online: String { "common_online".localized() }
        static var fullName: String { "common_full_name".localized() }
        static var email: String { "common_email".localized() }
        static var saving: String { "common_saving".localized() }
        static var loadingMessages: String { "common_loading_messages".localized() }
        static var unknown: String { "common_unknown".localized() }
        static var noDataFound: String { "common_no_data_found".localized() }
        static var noMessagesYet: String { "common_no_messages_yet".localized() }
    }

    // MARK: - Authentication
    enum Auth {
        static var loginTitle: String { "auth_login_title".localized() }
        static var loginButton: String { "auth_login_button".localized() }
        static var signupTitle: String { "auth_signup".localized() }
        static var logoutButton: String { "auth_logout_button".localized() }
        static var signinWithApple: String { "auth_signin_with_apple".localized() }
        static var signinWithGoogle: String { "auth_signin_with_google".localized() }
        static var dontHaveAccount: String { "auth_dont_have_account".localized() }
        static var alreadyHaveAccount: String { "auth_already_have_account".localized() }
        static var forgotPassword: String { "auth_forgot_password".localized() }
        static var signinToContinue: String { "auth_signin_to_continue".localized() }
        static var signupToContinue: String { "auth_signup_to_continue".localized() }
        static var resetPasswordLink: String { "auth_reset_password_link".localized() }
        static var sendLinkButton: String { "auth_send_link_button".localized() }
        static var linkSentTitle: String { "auth_link_sent_title".localized() }
        static var linkSentMessage: String { "auth_link_sent_message".localized() }
    }
    
    // MARK: - Home
    enum Home {
        static var deleteChat: String { "home_delete_chat".localized() }
        static var deleteChatAlertBody: String { "home_delete_chat_alert_body".localized() }
        static var deleteChatButton: String { "home_delete_chat_button".localized() }
        static var deleteChatTextFieldHint: String { "home_delete_chat_textfield_hint".localized() }
    }
    
    // MARK: - ChatBot
    enum ChatBot {
        static var chooseYourMode: String { "chatbot_choose_your_mode".localized() }
        static var classicModeTitle: String { "chatbot_classic_mode_title".localized() }
        static var classicModeSubtitle: String { "chatbot_classic_mode_subtitle".localized() }
        static var classicDescription: String { "chatbot_classic_description".localized() }
        static var correctionModeTitle: String { "chatbot_correction_mode_title".localized() }
        static var correctionModeSubtitle: String { "chatbot_correction_mode_subtitle".localized() }
        static var correctionDescription: String { "chatbot_correction_description".localized() }
        static var grammarModeTitle: String { "chatbot_grammar_mode_title".localized() }
        static var grammarModeSubtitle: String { "chatbot_grammar_mode_subtitle".localized() }
        static var grammarDescription: String { "chatbot_grammar_description".localized() }
        static var roleplayModeTitle: String { "chatbot_roleplay_mode_title".localized() }
        static func roleplayModeSubtitle(for scenario: String) -> String {
            String(format: "chatbot_roleplay_mode_subtitle".localized(), scenario)
        }
        static var roleplayConfigureTitle: String { "chatbot_roleplay_configure_title".localized() }
        static var roleplayStartButton: String { "chatbot_roleplay_start_button".localized() }
        static var roleplayScenarioTitle: String { "chatbot_roleplay_scenario_title".localized() }
        static var roleplayYourRoleTitle: String { "chatbot_roleplay_your_role_title".localized() }
        static var roleplayChatRoleTitle: String { "chatbot_roleplay_chat_role_title".localized() }
        static var roleplayDescription: String { "chatbot_roleplay_description".localized() }
        
        
        static func roleplayChatTitle(for role: String) -> String {
            String(format: "chatbot_roleplay_chat_title".localized(), role)
        }
    }
    
    // MARK: - Chat Log & Messaging
    enum Chat {
        static var replyingToYou: String { "chat_replying_to_you".localized() }
        static var replyingToImage: String { "chat_replying_to_image".localized() }
        static var edited: String { "chat_edited".localized() }
        static var newMessage: String { "chat_new_message".localized() }
        static var reply: String { "chat_reply".localized() }
        static var unsupportedMessageType: String { "chat_unsupported_message_type".localized() }
        static var imagePreviewTitle: String { "chat_image_preview_title".localized() }
        static var previewLoadError: String { "chat_preview_load_error".localized() }
        static var couldNotLoadPreview: String { "chat_could_not_load_preview".localized() }
        static var deleteMessageAlertTitle: String { "chat_delete_message_alert_title".localized() }
        static var deleteMessageAlertBody: String { "chat_delete_message_alert_body".localized() }
        
        static func replyingTo(_ username: String) -> String {
            String(format: "chat_replying_to".localized(), username)
        }
        static func editingMessageFrom(_ username: String) -> String {
            String(format: "chat_editing_message_from".localized(), username)
        }
        static func lastSeenToday(at time: String) -> String {
            String(format: "chat_last_seen_today".localized(), time)
        }
        static func lastSeenYesterday(at time: String) -> String {
            String(format: "chat_last_seen_yesterday".localized(), time)
        }
        static func lastSeenOnDate(_ date: String) -> String {
            String(format: "chat_last_seen_on_date".localized(), date)
        }
    }
    

    // MARK: - App Features & Modes
    enum Features {
        static var chooseLanguagePrompt: String { "features_choose_language".localized() }
        static var canChangeAnytime: String { "features_can_change_anytime".localized() }
        static var learningLanguage: String { "features_learning_language".localized() }
    }

    // MARK: - Media Picker
    enum Media {
        static var photos: String { "media_photos".localized() }
        static var camera: String { "media_camera".localized() }
        static var location: String { "media_location".localized() }
        static var audio: String { "media_audio".localized() }
        static var music: String { "media_music".localized() }
        static var facetime: String { "media_facetime".localized() }
        static var digitalTouch: String { "media_digital_touch".localized() }
        static var appStore: String { "media_app_store".localized() }
        static var genmoji: String { "media_genmoji".localized() }
        static var textMessage: String { "media_text_message".localized() }
    }
    
    // MARK: - Settings Sections
    enum Settings {
        static var general: String { "settings_general".localized() }
        static var preferences: String { "settings_preferences".localized() }
        static var accountSection: String { "settings_account_section".localized() }
        static var editProfile: String { "settings_edit_profile".localized() }
        static var logOut: String { "settings_log_out".localized() }
        static var help: String { "settings_help".localized() }
        static var userInformationTitle: String { "settings_user_information_title".localized() }
        static var deleteAccountButton: String { "settings_delete_account_button".localized() }
        static var deleteAlertTitle: String { "settings_delete_alert_title".localized() }
        static var logoutAlertTitle: String { "settings_logout_alert_title".localized() }
        static var profilePictureTitle: String { "settings_profile_picture_title".localized() }
        static var tapToChangePhoto: String { "settings_tap_to_change_photo".localized() }
    }
    
    // MARK: - Validation Errors
    enum Validation {
        static var emailInvalid: String { "validation_email_invalid".localized() }
        static var passwordTooShort: String { "validation_password_too_short".localized() }
        static var nameTooShort: String { "validation_name_too_short".localized() }
        static var passwordsDoNotMatch: String { "validation_passwords_do_not_match".localized() }
    }

    // MARK: - Onboarding
    enum Onboarding {
        static var languageTitle: String { "onboarding_language_title".localized() }
        static var languageSubtitle: String { "onboarding_language_subtitle".localized() }
    }
       
    // MARK: - Language Names
    enum LanguageName {
        static var english: String { "language_english_full".localized() }
        static var spanish: String { "language_spanish_full".localized() }
        static var french: String { "language_french_full".localized() }
    }

       // MARK: - App Tabs
    enum Tab {
        static var chats: String { "tab_chats".localized() }
        static var chatbot: String { "tab_chatbot".localized() }
        static var settings: String { "tab_settings".localized() }
    }
       
    enum Placeholder {
        static var emailPlaceholder: String { "placeholder_email".localized() }
        static var fullnamePlaceholder: String { "placeholder_fullname".localized() }
        static var passwordPlaceholder: String { "placeholder_password".localized() }
        static var confirmPasswordPlaceholder: String { "placeholder_confirm_password".localized() }
        static var messagePlaceholder: String { "placeholder_message".localized() }
        static var addCommentPlaceholder: String { "placeholder_add_comment".localized() }
        static var yourRole: String { "placeholder_your_role".localized() }
        static var botRole: String { "placeholder_bot_role".localized() }
        static var scenario: String { "placeholder_scenario".localized() }
        static var typeYourMessage: String { "placeholder_type_your_message".localized() }
        static var unknown: String { "placeholder_unknown".localized() }
    }
    
    enum AppError {
        static var aiNoResponse: String { "error_ai_no_response".localized() }
        static var sendMessage: String { "error_send_message".localized() }
        static var sendImage: String { "error_send_image".localized() }
        static var loadMessages: String { "error_load_messages".localized() }
        static var deleteMessage: String { "error_delete_message".localized() }
        static var editingMessage: String { "error_editing_message".localized() }
        static var editingAccount: String { "error_editing_account".localized() }
        static var loadingSettings: String { "error_loading_settings".localized() }
        static var noUsersAvailable: String { "error_no_users_available".localized() }
        static var usersLoadFailed: String { "error_users_load_failed".localized() }
    }
    
    // MARK: - Miscellaneous
    enum Misc {
        static var creatingAccount: String { "loading_creating_account".localized() }
    }
    
    // MARK: - Default Values
    enum DefaultValues {
        static var defaultFullName: String { "default_full_name".localized() }
        static var defaultEmail: String { "default_email".localized() }
        static var defaultImageText: String { "default_image_text".localized() }
        static var defaultLastMessage: String { "default_last_message".localized() }
        static var defaultDate: String { "default_date".localized() }
    }
    
    // MARK: - Time Ago Formatting
        enum TimeAgo {
            static var justNow: String { "time_ago_just_now".localized() }
            
            static func minutes(_ count: Int) -> String {
                String(format: "time_ago_minutes".localized(), count)
            }
            
            static func hours(_ count: Int) -> String {
                String(format: "time_ago_hours".localized(), count)
            }
            
            static func days(_ count: Int) -> String {
                String(format: "time_ago_days".localized(), count)
            }
        }
        
        // MARK: - Image Detail View
        enum ImageDetail {
            static var senderYou: String { "image_detail_sender_you".localized() }
        }
}
