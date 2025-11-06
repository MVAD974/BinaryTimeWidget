//
//  BinaryLineShape.swift
//  TimeWidget
//
//  Created by Marc Vadier on 06/11/2025.
//

import SwiftUI

struct BinaryLineShape: Shape {
    let digits: [Int]
    let amplitudePercent: CGFloat
    let horizontalPaddingPercent: CGFloat // <-- NEW

    func path(in rect: CGRect) -> Path {
        var path = Path()
        guard digits.count == 4 else { return path }
        
        // --- NEW Coordinate Calculation ---
        // 1. Calculate the available drawing area
        let yAmplitude = rect.height * amplitudePercent
        let yOffset = (rect.height - yAmplitude) / 2.0
        
        let xOffset = rect.width * horizontalPaddingPercent // <-- NEW
        let effectiveWidth = rect.width * (1.0 - 2.0 * horizontalPaddingPercent) // <-- NEW
        let xStep = effectiveWidth / 3.0 // 3 segments for 4 points
        
        func point(at index: Int) -> CGPoint {
            let x = xOffset + (CGFloat(index) * xStep) // <-- MODIFIED
            let y = yOffset + (1.0 - CGFloat(digits[index])) * yAmplitude
            return CGPoint(x: x, y: y)
        }
        
        // ... (rest of the path drawing is the same) ...
        path.move(to: point(at: 0))
        path.addLine(to: point(at: 1))
        path.addLine(to: point(at: 2))
        path.addLine(to: point(at: 3))
        
        return path
    }
}
