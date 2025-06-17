//
//  Utils.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 16/6/25.
//

import Foundation
import SwiftUI

/// Calcula la posición óptima para el menú contextual, evitando los bordes de la pantalla.
/// - Returns: Una tupla con el punto de origen (top-left) para el menú y el UnitPoint para la animación.
func calculateMenuPlacement(bubbleFrame: CGRect, menuSize: CGSize, containerSize: CGSize, isBubbleCurrentUser: Bool) -> (origin: CGPoint, anchor: UnitPoint) {
    let spacing: CGFloat = 8.0
    let edgePadding: CGFloat = 15.0

    // --- Posicionamiento Horizontal (X) ---
    // (Esta parte no cambia)
    var menuX = bubbleFrame.midX - (menuSize.width / 2)
    if menuX + menuSize.width > containerSize.width - edgePadding {
        menuX = containerSize.width - menuSize.width - edgePadding
    }
    if menuX < edgePadding {
        menuX = edgePadding
    }
    
    // --- Posicionamiento Vertical (Y) con Lógica Invertida ---
    var menuY: CGFloat
    var anchorPoint: UnitPoint

    let yPosAbove = bubbleFrame.minY - menuSize.height - spacing
    let yPosBelow = bubbleFrame.maxY + spacing

    // --- INICIO DE LA SOLUCIÓN ---
    // Prioridad: colocar el menú DEBAJO de la burbuja si hay espacio.
    // Comprobamos si el borde inferior del menú cabe dentro de los límites del contenedor.
    if (yPosBelow + menuSize.height) < (containerSize.height - edgePadding) {
        menuY = yPosBelow
        anchorPoint = .top // La animación de escala se origina desde la parte superior del menú.
    } else {
        // Si no hay espacio suficiente debajo, lo colocamos arriba.
        menuY = yPosAbove
        anchorPoint = .bottom // La animación de escala se origina desde la parte inferior del menú.
    }
    // --- FIN DE LA SOLUCIÓN ---
    
    return (CGPoint(x: menuX, y: menuY), anchorPoint)
}
