//
//  BinaryTimeWidgetStyle.swift
//  BinaryTimeWidget
//
//  Created by Marc Vadier on 04/11/2025.
//

import SwiftUI

/// A central struct to define the look and feel of the binary time widget.
/// To customize your widget, change the values in the `.default` instance.
struct WidgetStyle {
    
    // MARK: - Colors
    
    /// The background color of the widget.
    var backgroundColor: Color
    
    /// The array of colors for the four lines (H1, H2, M1, M2).
    var lineColors: [Color]
    
    // MARK: - Dimensions
    
    /// The thickness of the binary lines.
    var lineWidth: CGFloat
    
    /// The diameter of the circles at each point.
    var markerSize: CGFloat
    
    /// The vertical "bump" of the line, as a percentage (0.0 to 1.0) of the row's height.
    /// 1.0 = full height, 0.8 = 80% height.
    var lineAmplitudePercent: CGFloat
    
    /// The vertical space between each of the four lines.
    var verticalSpacing: CGFloat
    
    /// The padding around the entire group of lines.
    var widgetPadding: CGFloat
    
    
    // MARK: - Default Style
    
    /// The default style used by the widget.
    /// **Change these values to customize your widget!**
    static let `default` = WidgetStyle(
        backgroundColor: .black,
        lineColors: [.blue, .cyan, .yellow, .orange],
        lineWidth: 3.0,
        markerSize: 5.0,
        lineAmplitudePercent: 2.0, // 100% (as you requested)
        verticalSpacing: 16.0,
        widgetPadding: 12.0
    )
}
