//
//  BinaryTimeWidgetStyle.swift
//  BinaryTimeWidget
//
//  Created by Marc Vadier on 04/11/2025.
//

import SwiftUI
import UIKit

/// A central struct to define the look and feel of the binary time widget.
/// Conforms to Codable so it can be saved in UserDefaults.
struct WidgetStyle: Codable, Equatable {
    
    // MARK: - Properties
    
    var backgroundColor: CodableColor
    var lineColors: [CodableColor]
    var lineWidth: CGFloat
    var markerSize: CGFloat
    var lineAmplitudePercent: CGFloat
    var verticalSpacing: CGFloat
    var widgetPadding: CGFloat
    
    // MARK: - Default Style
    
    static let `default` = WidgetStyle(
        backgroundColor: CodableColor(color: .black),
        lineColors: [
            CodableColor(color: .blue),
            CodableColor(color: .cyan),
            CodableColor(color: .yellow),
            CodableColor(color: .orange)
        ],
        lineWidth: 3.0,
        markerSize: 5.0,
        lineAmplitudePercent: 1.0,
        verticalSpacing: 5.0,
        widgetPadding: 12.0
    )
}

/// A Codable wrapper for SwiftUI's `Color`.
/// This stores the color's RGBA components to allow saving.
struct CodableColor: Codable, Equatable {
    var red: Double
    var green: Double
    var blue: Double
    var opacity: Double
    
    // Helper function to get components from a SwiftUI Color
    private static func getComponents(from color: Color) -> (red: Double, green: Double, blue: Double, opacity: Double) {
        let uiColor = UIColor(color)
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        return (Double(r), Double(g), Double(b), Double(a))
    }

    // Convert from SwiftUI.Color to CodableColor
    init(color: Color) {
        let components = Self.getComponents(from: color)
        self.red = components.red
        self.green = components.green
        self.blue = components.blue
        self.opacity = components.opacity
    }
    
    // Convert from CodableColor back to SwiftUI.Color
    // This is now a get/set property, fixing the "get-only" error
    var color: Color {
        get {
            Color(red: red, green: green, blue: blue, opacity: opacity)
        }
        set {
            // When the ColorPicker sets this color,
            // update our stored RGBA properties
            let components = Self.getComponents(from: newValue)
            self.red = components.red
            self.green = components.green
            self.blue = components.blue
            self.opacity = components.opacity
        }
    }
}
