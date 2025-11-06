//
//  BinaryDotsView.swift
//  BinaryTimeWidget
//
//  Created by Marc Vadier on 06/11/2025.
//

import SwiftUI

/// A view that represents 4 digits as 4 vertical stacks of 4 dots.
struct BinaryDotsView: View {
    let binaryLayers: [[Int]]
    let style: WidgetStyle
    
    var body: some View {
        // Show the 4 digits horizontally
        HStack(spacing: style.verticalSpacing) {
            
            ForEach(0..<binaryLayers.count, id: \.self) { index in
                let digits = binaryLayers[index]
                let color = style.lineColors[index % style.lineColors.count].color
                
                // Each digit is a vertical stack of dots
                VStack(spacing: style.markerSize / 2) {
                    ForEach(0..<digits.count, id: \.self) { digitIndex in
                        let isFilled = (digits[digitIndex] == 1)
                        
                        Circle()
                            .fill(isFilled ? color : Color.clear)
                            .stroke(color, lineWidth: style.lineWidth / 2)
                            .frame(width: style.markerSize * 2, height: style.markerSize * 2)
                    }
                }
            }
        }
        .padding(style.widgetPadding)
        .background(style.backgroundColor.color)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
