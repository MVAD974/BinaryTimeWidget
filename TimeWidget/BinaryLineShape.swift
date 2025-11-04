import SwiftUI

/// This is a custom `Shape` that draws one line of the binary representation.
/// It takes an array like [0, 1, 0, 1] and draws the path.
struct BinaryLineShape: Shape {
    let digits: [Int]
    
    // This is the required function, just like Python's `def`
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // Ensure we have 4 digits to draw
        guard digits.count == 4 else { return path }
        
        // --- Coordinate Calculation ---
        // We have 4 points (indices 0, 1, 2, 3), which means 3 segments.
        let xStep = rect.width / 3.0
        
        // We'll use 80% of the height for the '1's to give some padding.
        let yAmplitude = rect.height * 1.0
        let yOffset = rect.height * 0.0 // 10% padding at top
        
        // Function to calculate a single point's (x, y) coordinate
        // Note: In SwiftUI, (0,0) is the TOP-LEFT corner, so we must
        // invert the 'y' value (1.0 - ...).
        func point(at index: Int) -> CGPoint {
            let x = CGFloat(index) * xStep
            
            // Use (1.0 - digit) to flip: 0 becomes 1 (bottom), 1 becomes 0 (top)
            let y = yOffset + (1.0 - CGFloat(digits[index])) * yAmplitude
            
            return CGPoint(x: x, y: y)
        }
        
        // Start the path
        path.move(to: point(at: 0))
        
        // Add the other 3 lines
        path.addLine(to: point(at: 1))
        path.addLine(to: point(at: 2))
        path.addLine(to: point(at: 3))
        
        return path
    }
}
