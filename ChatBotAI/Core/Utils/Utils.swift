//
//  Utils.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 16/6/25.
//

import Foundation
import SwiftUI

func calculateMenuPlacement(bubbleFrame: CGRect, menuSize: CGSize, containerSize: CGSize, isBubbleCurrentUser: Bool) -> (origin: CGPoint, anchor: UnitPoint) {
    let spacing: CGFloat = 8.0
    let edgePadding: CGFloat = 15.0
    
    var menuX = bubbleFrame.midX - (menuSize.width / 2)
    if menuX + menuSize.width > containerSize.width - edgePadding {
        menuX = containerSize.width - menuSize.width - edgePadding
    }
    if menuX < edgePadding {
        menuX = edgePadding
    }
    
    var menuY: CGFloat
    var anchorPoint: UnitPoint
    
    let yPosAbove = bubbleFrame.minY - menuSize.height - spacing
    let yPosBelow = bubbleFrame.maxY + spacing
    
    if (yPosBelow + menuSize.height) < (containerSize.height - edgePadding) {
        menuY = yPosBelow
        anchorPoint = .top
    } else {
        menuY = yPosAbove
        anchorPoint = .bottom
    }
    
    return (CGPoint(x: menuX, y: menuY), anchorPoint)
}
