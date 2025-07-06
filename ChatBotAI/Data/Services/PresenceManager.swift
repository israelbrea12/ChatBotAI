//
//  PresenceManager.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 6/7/25.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth

/// Gestiona el estado de presencia del usuario actual en la Realtime Database.
class PresenceManager {
    
    static let shared = PresenceManager()
    
    private let databaseRef = Database.database().reference()
    private var presenceRef: DatabaseReference?
    
    // El observador para el estado de conexión
    private var connectedHandle: DatabaseHandle?

    private init() {} // Singleton
    
    /// Configura el sistema de presencia para el usuario actual.
    /// Esta función debe llamarse una vez que el usuario ha iniciado sesión.
    func setupPresence() {
        // Evitar configurar múltiples veces si ya está activo
        guard presenceRef == nil, let currentUserID = Auth.auth().currentUser?.uid else { return }
        
        // 1. Define la ruta al estado de presencia del usuario actual.
        self.presenceRef = databaseRef.child("users/\(currentUserID)/presence")
        
        // 2. Preparamos nuestro "testamento" con `onDisconnect`.
        // Esto se ejecutará en el servidor de Firebase si el cliente se desconecta abruptamente.
        // No se necesita una variable para `onDisconnect`, se configura directamente sobre la referencia.
        let onDisconnectData: [String: Any] = [
            "isOnline": false,
            "lastSeen": ServerValue.timestamp()
        ]
        presenceRef?.onDisconnectUpdateChildValues(onDisconnectData)

        // 3. Crea una referencia al nodo especial `.info/connected` de Firebase.
        let connectedRef = databaseRef.child(".info/connected")
        
        // 4. Observamos el estado de la conexión.
        // SOLUCIÓN: La sintaxis correcta del closure utiliza la etiqueta "with:".
        connectedHandle = connectedRef.observe(.value, with: { [weak self] snapshot in
            guard let self = self, let isConnected = snapshot.value as? Bool, isConnected else {
                return
            }
            
            // 5. Cuando nos conectamos, nos marcamos como 'online'.
            let presenceData: [String: Any] = [
                "isOnline": true,
                "lastSeen": ServerValue.timestamp()
            ]
            self.presenceRef?.setValue(presenceData)
        })
    }
    
    /// Marca al usuario como desconectado de forma manual y limpia los observadores.
    /// Llamar a esto cuando el usuario cierra sesión voluntariamente.
    func goOffline() {
        guard let presenceRef = self.presenceRef else { return }
        
        // Marcamos al usuario como offline manualmente.
        let offlineData: [String: Any] = [
            "isOnline": false,
            "lastSeen": ServerValue.timestamp()
        ]
        presenceRef.setValue(offlineData)
        
        // Cancelamos la operación onDisconnect pendiente ya que nos fuimos voluntariamente.
        presenceRef.cancelDisconnectOperations()
        
        // Eliminamos el observador del estado de conexión para evitar fugas de memoria.
        if let connectedHandle = connectedHandle {
            databaseRef.child(".info/connected").removeObserver(withHandle: connectedHandle)
            self.connectedHandle = nil
        }
        
        // Limpiamos la referencia.
        self.presenceRef = nil
    }
}
