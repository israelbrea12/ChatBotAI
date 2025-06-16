//
//  Utils.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 16/6/25.
//

import Foundation
import SwiftUI

func calculateMenuPlacement(
    bubbleFrame: CGRect,      // El frame de la burbuja del mensaje, en coordenadas del contenedor
    menuSize: CGSize,         // El tamaño estimado del menú
    containerBounds: CGRect,  // Los límites de la vista contenedora (MessagesView)
    isBubbleCurrentUser: Bool // Para informar una posible alineación horizontal (no usada activamente para x aquí)
) -> (origin: CGPoint, anchorForTransition: UnitPoint) {

    var xOrigin: CGFloat
    var yOrigin: CGFloat
    var anchor: UnitPoint

    let gap: CGFloat = 8.0       // Espacio entre la burbuja y el menú
    let padding: CGFloat = 8.0   // Padding desde los bordes del contenedor

    // === Posicionamiento Vertical ===
    let yBelow = bubbleFrame.maxY + gap
    let yAbove = bubbleFrame.minY - menuSize.height - gap

    // Intenta colocar debajo
    if (yBelow + menuSize.height) <= (containerBounds.maxY - padding) {
        yOrigin = yBelow
        anchor = .top // El menú se escala hacia abajo desde su borde superior
    }
    // Si no, intenta colocar encima
    else if yAbove >= (containerBounds.minY + padding) {
        yOrigin = yAbove
        anchor = .bottom // El menú se escala hacia arriba desde su borde inferior
    }
    // Fallback: No hay espacio ideal. Prioriza debajo, luego encima, luego ajusta.
    else {
        // Si la burbuja está más en la mitad superior, preferir abajo. Si no, preferir arriba.
        if (bubbleFrame.midY < containerBounds.midY) {
             yOrigin = yBelow // Intenta abajo primero
             anchor = .top
             // Si se desborda, ajústalo para que quepa desde abajo
             if (yOrigin + menuSize.height) > (containerBounds.maxY - padding) {
                 yOrigin = containerBounds.maxY - menuSize.height - padding
             }
        } else {
            yOrigin = yAbove // Intenta arriba primero
            anchor = .bottom
            // Si se desborda (ej. yOrigin < minY), ajústalo para que quepa desde arriba
            if yOrigin < (containerBounds.minY + padding) {
                yOrigin = containerBounds.minY + padding
            }
        }
        // Asegúrate de que no se salga de los límites después del ajuste
        yOrigin = max(containerBounds.minY + padding, yOrigin)
        yOrigin = min(yOrigin, containerBounds.maxY - menuSize.height - padding)

        // Re-evaluar el ancla si se ha ajustado fuertemente a un borde
        if yOrigin == (containerBounds.minY + padding) && anchor == .bottom {
             // Si está pegado arriba, pero iba a escalar desde abajo, mejor escalar desde arriba
             anchor = .top
        } else if (yOrigin + menuSize.height) == (containerBounds.maxY - padding) && anchor == .top {
             // Si está pegado abajo, pero iba a escalar desde arriba, mejor escalar desde abajo
             anchor = .bottom
        }
    }

    // === Posicionamiento Horizontal ===
    // Por defecto: Centra el menú horizontalmente con la burbuja
    xOrigin = bubbleFrame.midX - (menuSize.width / 2)

    // Ajusta xOrigin para mantener el menú dentro de los límites del contenedor
    xOrigin = max(containerBounds.minX + padding, xOrigin) // Ajusta al borde izquierdo
    xOrigin = min(xOrigin, containerBounds.maxX - menuSize.width - padding) // Ajusta al borde derecho
    
    return (CGPoint(x: xOrigin, y: yOrigin), anchor)
}
