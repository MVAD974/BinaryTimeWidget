//
//  BinaryTimeWidgetStyle.swift
//  BinaryTimeWidget
//
//  Created by Marc Vadier on 04/11/2025.
//

import SwiftUI
import UIKit
import WidgetKit

// An enum for the marker shape
enum MarkerShape: String, Codable, CaseIterable, Identifiable {
    case circle = "Circle"
    case square = "Square"
    
    var id: String { self.rawValue }
}

// An enum to define the different visual styles.
enum RepresentationStyle: String, Codable, CaseIterable, Identifiable {
    case binaryLineGraph = "Line Graph"
    case artisticBars = "Artistic Bars"
    var id: String { self.rawValue }
}

struct WidgetStyle: Codable, Equatable {
    
    // MARK: - Properties
    
    // --- Style Properties ---
    var backgroundColor: CodableColor
    var lineColors: [CodableColor]
    var representation: RepresentationStyle

    // --- Dimension Properties ---
    var lineWidth: CGFloat
    var markerSize: CGFloat
    var lineAmplitudePercent: CGFloat
    var verticalSpacing: CGFloat
    var widgetPadding: CGFloat
    var horizontalPaddingPercent: CGFloat
    var markerShape: MarkerShape // <-- NEW (Request 1)
    
    // Artistic Bars Properties (only meaningful when representation == .artisticBars)
    var barMaxHeightPercent: CGFloat?    // 0.0 - 1.0 relative to available height (height for bit=1)
    var barMinHeightPercent: CGFloat?    // 0.0 - 1.0 (height for bit=0)
    var barCornerRadius: CGFloat?        // Corner radius of each bar
    var barSpacing: CGFloat?             // Spacing between bars within a digit column
    
    
    // MARK: - Default Style
    
    /// Provides a default style for a given widget family.
    static func defaultStyle(for family: WidgetFamily) -> WidgetStyle {
        
        // Base defaults for line graph
        var style = WidgetStyle(
            backgroundColor: CodableColor(color: .black),
            lineColors: [
                CodableColor(color: .blue),
                CodableColor(color: .cyan),
                CodableColor(color: .yellow),
                CodableColor(color: .orange)
            ],
            representation: .binaryLineGraph,
            lineWidth: 3.0,
            markerSize: 5.0,
            lineAmplitudePercent: 1.0,
            verticalSpacing: 5.0,
            widgetPadding: 12.0,
            horizontalPaddingPercent: 0.1,
            markerShape: .circle,
            barMaxHeightPercent: nil,
            barMinHeightPercent: nil,
            barCornerRadius: nil,
            barSpacing: nil
        )
        
        // Family-specific adjustments (can tweak defaults)
        switch family {
        case .systemSmall:
            break
        case .systemMedium:
            style.verticalSpacing = 6
        case .systemLarge, .systemExtraLarge:
            style.verticalSpacing = 8
        case .accessoryCircular, .accessoryRectangular, .accessoryInline:
            break
        @unknown default:
            break
        }
        return style
        
        // This switch is now exhaustive and safe.
        // NOTE: ArtisticBars defaults are provided lazily when representation changes.
    }
}

/// A Codable wrapper for SwiftUI's `Color`.
struct CodableColor: Codable, Equatable {
    // ... (This struct remains unchanged from our last fix) ...
    // ... (Make sure you have the version that uses UIColor) ...
    
    var red: Double
    var green: Double
    var blue: Double
    var opacity: Double
    
    private static func getComponents(from color: Color) -> (red: Double, green: Double, blue: Double, opacity: Double) {
        let uiColor = UIColor(color)
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        return (Double(r), Double(g), Double(b), Double(a))
    }

    init(color: Color) {
        let components = Self.getComponents(from: color)
        self.red = components.red
        self.green = components.green
        self.blue = components.blue
        self.opacity = components.opacity
    }
    
    var color: Color {
        get {
            Color(red: red, green: green, blue: blue, opacity: opacity)
        }
        set {
            let components = Self.getComponents(from: newValue)
            self.red = components.red
            self.green = components.green
            self.blue = components.blue
            self.opacity = components.opacity
        }
    }
}
