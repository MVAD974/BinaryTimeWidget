//
//  ContentView.swift
//  BinaryTimeWidget
//
//  Created by Marc Vadier on 04/11/2025.
//

import SwiftUI
import Combine

struct ContentView: View {
    
    /// The manager for our app/widget style.
    @State private var styleManager = StyleManager()
    
    /// The current time, updated by a timer.
    @State private var currentDate = Date()
    
    // Timer to update the live preview
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        NavigationStack {
            Form {
                // --- 1. Live Preview Section ---
                Section("Live Preview") {
                    TimeVisualizationView(
                        date: currentDate,
                        style: $styleManager.style
                    )
                    // Keep the preview updating
                    .onReceive(timer) { input in
                        currentDate = input
                    }
                    .frame(height: 200)
                }
                
                // --- 2. Color Customization ---
                Section("Colors") {
                    ColorPicker("Background", selection: $styleManager.style.backgroundColor.color, supportsOpacity: true)
                    ColorPicker("Line 1 (Hour 1)", selection: $styleManager.style.lineColors[0].color)
                    ColorPicker("Line 2 (Hour 2)", selection: $styleManager.style.lineColors[1].color)
                    ColorPicker("Line 3 (Min 1)", selection: $styleManager.style.lineColors[2].color)
                    ColorPicker("Line 4 (Min 2)", selection: $styleManager.style.lineColors[3].color)
                }
                
                // --- 3. Dimension Customization ---
                Section("Dimensions") {
                    SliderView(
                        label: "Line Width",
                        value: $styleManager.style.lineWidth,
                        range: 1...10,
                        specifier: "%.1f"
                    )
                    SliderView(
                        label: "Marker Size",
                        value: $styleManager.style.markerSize,
                        range: 1...15,
                        specifier: "%.1f"
                    )
                    SliderView(
                        label: "Amplitude",
                        value: $styleManager.style.lineAmplitudePercent,
                        range: 0.1...1.0,
                        specifier: "%.2f"
                    )
                    SliderView(
                        label: "Spacing",
                        value: $styleManager.style.verticalSpacing,
                        range: 0...20,
                        specifier: "%.1f"
                    )
                    SliderView(
                        label: "Padding",
                        value: $styleManager.style.widgetPadding,
                        range: 0...40,
                        specifier: "%.1f"
                    )
                }
            }
            .navigationTitle("Widget Style")
            .tint(styleManager.style.lineColors[0].color)
        }
    }
}

/// A reusable view that shows the 4-line time visualization.
/// This is the same view logic as the widget, but in the app.
struct TimeVisualizationView: View {
    let date: Date
    @Binding var style: WidgetStyle
    
    var body: some View {
        let binaryLayers = TimeConverter.getTimeAsBinaryLayers(from: date)
        
        VStack(spacing: style.verticalSpacing) {
            ForEach(0..<binaryLayers.count, id: \.self) { index in
                let digits = binaryLayers[index]
                let color = style.lineColors[index % style.lineColors.count].color
                
                BinaryLineShape(
                    digits: digits,
                    amplitudePercent: style.lineAmplitudePercent
                )
                .stroke(color, lineWidth: style.lineWidth)
                .overlay(
                    BinaryMarkerShape(
                        digits: digits,
                        markerSize: style.markerSize,
                        amplitudePercent: style.lineAmplitudePercent
                    )
                    .fill(color)
                )
            }
        }
        .padding(style.widgetPadding)
        .background(style.backgroundColor.color)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

/// A helper view for a Labeled Slider.
struct SliderView: View {
    let label: String
    @Binding var value: CGFloat
    let range: ClosedRange<CGFloat>
    let specifier: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("\(label): \(value, specifier: specifier)")
            Slider(value: $value, in: range)
        }
    }
}

#Preview {
    ContentView()
}
