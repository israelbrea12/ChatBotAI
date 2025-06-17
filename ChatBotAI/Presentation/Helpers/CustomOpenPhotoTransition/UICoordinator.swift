import SwiftUI

@Observable
class UICoordinator {
    // --- Propiedades existentes ---
    var selectedMessage: Message?
    var animateView: Bool = false
    var showDetailView: Bool = false
    
    // --- Nuevas Propiedades para Gestos y Paginación ---
    
    /// Almacena todos los mensajes que son de tipo imagen.
    var imageMessages: [Message] = []
    
    /// Posición del ScrollView principal en la vista de detalle.
    var detailScrollPosition: String?
    /// Posición del ScrollView del indicador inferior.
    var detailIndicatorPosition: String?
    
    /// El desplazamiento actual de la vista debido al gesto de arrastre.
    var offset: CGSize = .zero
    /// El progreso del arrastre (de 0 a 1) para controlar animaciones como el fundido del fondo.
    var dragProgress: CGFloat = 0
    
    /// Filtra los mensajes para obtener solo los que tienen imágenes y los asigna.
    /// Debes llamar a esta función cuando cargas los mensajes en tu `ChatLogViewModel`.
    func setup(messages: [Message]) {
        self.imageMessages = messages.filter { $0.messageType == .image && $0.imageURL != nil }
    }
    
    /// Se llama cuando el usuario desliza la imagen principal.
    func didDetailPageChanged() {
        if let updatedItem = imageMessages.first(where: { $0.id == detailScrollPosition }) {
            selectedMessage = updatedItem
            // Sincroniza el indicador inferior con la imagen principal.
            withAnimation(.easeInOut(duration: 0.1)) {
                detailIndicatorPosition = updatedItem.id
            }
        }
    }
    
    /// Se llama cuando el usuario toca una miniatura en el indicador inferior.
    func didDetailIndicatorPageChanged() {
        if let updatedItem = imageMessages.first(where: { $0.id == detailIndicatorPosition }) {
            selectedMessage = updatedItem
            // Sincroniza la imagen principal con el indicador.
            detailScrollPosition = updatedItem.id
        }
    }

    func toggleView(show: Bool) {
        if show {
            // Asegúrate de que las posiciones de los scrolls se establecen al mensaje seleccionado.
            detailScrollPosition = selectedMessage?.id
            detailIndicatorPosition = selectedMessage?.id
            
            withAnimation(.easeInOut(duration: 0.35), completionCriteria: .removed) {
                animateView = true
            } completion: {
                self.showDetailView = true
            }
        } else {
            showDetailView = false
            withAnimation(.easeInOut(duration: 0.35), completionCriteria: .removed) {
                animateView = false
                offset = .zero // Resetea el offset en la animación de cierre.
                dragProgress = 0 // Resetea el progreso.
            } completion: {
                self.resetAnimationProperties()
            }
        }
    }
    
    func resetAnimationProperties() {
        selectedMessage = nil
        detailScrollPosition = nil
        offset = .zero
        dragProgress = 0
        detailIndicatorPosition = nil
        // No reseteamos 'imageMessages' para no tener que recargarlo.
    }
}
