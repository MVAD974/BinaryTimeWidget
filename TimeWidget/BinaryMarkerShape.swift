//
//  BinaryMarkerShape.swift
//  BinaryTimeWidget
//
//  Created by Marc Vadier on 04/11/2025.
//

import SwiftUI

/// A shape that draws the circular markers for a single binary line.
struct BinaryMarkerShape: Shape {
    let digits: [Int]
    
    // Style properties
    let markerSize: CGFloat
    let amplitudePercent: CGFloat
    let horizontalPaddingPercent: CGFloat
    let markerShape: MarkerShape // <-- NEW

    func path(in rect: CGRect) -> Path {
        var path = Path()
        guard digits.count == 4 else { return path }
        
        // --- Coordinate Calculation ---
        let yAmplitude = rect.height * amplitudePercent
        let yOffset = (rect.height - yAmplitude) / 2.0
        
        let xOffset = rect.width * horizontalPaddingPercent
        let effectiveWidth = rect.width * (1.0 - 2.0 * horizontalPaddingPercent)
        let xStep = effectiveWidth / 3.0
        
        func point(at index: Int) -> CGPoint {
            let x = xOffset + (CGFloat(index) * xStep)
            let y = yOffset + (1.0 - CGFloat(digits[index])) * yAmplitude
            return CGPoint(x: x, y: y)
        }

        // Add a shape at each of the 4 points
        for i in 0..<4 {
            let center = point(at: i)
            let markerRect = CGRect(
                x: center.x - markerSize / 2,
                y: center.y - markerSize / 2,
                width: markerSize,
                height: markerSize
            )
            
            // ** NEW: Draw the correct shape **
            switch markerShape {
            case .circle:
                path.addEllipse(in: markerRect)
            case .square:
                path.addRect(markerRect)
            }
        }
        
        return path
    }
}
