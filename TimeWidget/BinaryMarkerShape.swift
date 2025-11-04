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
    
    /// The diameter of the circle.
    let markerSize: CGFloat
    
    /// The vertical "bump" as a percentage (0.0 to 1.0) of the row's height.
    let amplitudePercent: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        guard digits.count == 4 else { return path }
        
        // --- Coordinate Calculation ---
        let xStep = rect.width / 3.0
        
        // This logic is now robust. It calculates the amplitude
        // and then centers the line vertically in the remaining space.
        let yAmplitude = rect.height * amplitudePercent
        let yOffset = (rect.height - yAmplitude) / 2.0
        
        func point(at index: Int) -> CGPoint {
            let x = CGFloat(index) * xStep
            // Use (1.0 - digit) to flip: 0 becomes 1 (bottom), 1 becomes 0 (top)
            let y = yOffset + (1.0 - CGFloat(digits[index])) * yAmplitude
            return CGPoint(x: x, y: y)
        }

        // Add a circle at each of the 4 points
        for i in 0..<4 {
            let center = point(at: i)
            let markerRect = CGRect(
                x: center.x - markerSize / 2,
                y: center.y - markerSize / 2,
                width: markerSize,
                height: markerSize
            )
            path.addEllipse(in: markerRect)
        }
        
        return path
    }
}
