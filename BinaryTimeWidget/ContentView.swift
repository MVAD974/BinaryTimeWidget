//
//  ContentView.swift
//  BinaryTimeWidget
//
//  Created by Marc Vadier on 04/11/2025.
//

import SwiftUI
import Combine
import WidgetKit

struct ContentView: View {
    
    @State private var style: WidgetStyle
    @State private var selectedFamily: WidgetFamily = .systemMedium
    @State private var currentDate = Date()
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    init() {
        let initialFamily = WidgetFamily.systemMedium
        self._selectedFamily = State(initialValue: initialFamily)
        self._style = State(initialValue: StyleManager.loadStyle(for: initialFamily))
    }
    
    var body: some View {
        NavigationStack {
            Form {
                
                // --- 1. Size Selector ---
                Section("Editing Style") {
                    Picker("Widget Size", selection: $selectedFamily) {
                        Text("Small").tag(WidgetFamily.systemSmall)
                        Text("Medium").tag(WidgetFamily.systemMedium)
                        Text("Large").tag(WidgetFamily.systemLarge)
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: selectedFamily) { oldFamily, newFamily in
                        StyleManager.saveStyle(style, for: oldFamily)
                        style = StyleManager.loadStyle(for: newFamily)
                    }
                }

                // --- 2. Live Preview Section ---
                Section("Live Preview") {
                    TimeVisualizationView(
                        date: currentDate,
                        style: $style
                    )
                    .onReceive(timer) { input in currentDate = input }
                    .frame(height: 200)
                }
                
                // --- 3. Style Chooser ---
                Section("Representation") {
                    Picker("Style", selection: $style.representation) {
                        ForEach(RepresentationStyle.allCases) { styleCase in
                            Text(styleCase.rawValue).tag(styleCase)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                // --- 4. Color Customization ---
                Section("Colors") {
                    ColorPicker("Background", selection: $style.backgroundColor.color, supportsOpacity: true)
                    ColorPicker("Line 1 (Hour 1)", selection: $style.lineColors[0].color)
                    ColorPicker("Line 2 (Hour 2)", selection: $style.lineColors[1].color)
                    ColorPicker("Line 3 (Min 1)", selection: $style.lineColors[2].color)
                    ColorPicker("Line 4 (Min 2)", selection: $style.lineColors[3].color)
                }
                
                // --- 5. Common Dimension Settings ---
                Section("Common Dimensions") {
                    SliderView(
                        label: "Marker/Dot Size",
                        value: $style.markerSize,
                        range: 1...15,
                        specifier: "%.1f"
                    )
                    SliderView(
                        label: "Line/Stroke Width",
                        value: $style.lineWidth,
                        range: 1...10,
                        specifier: "%.1f"
                    )
                    SliderView(
                        label: "Widget Padding",
                        value: $style.widgetPadding,
                        range: 0...40,
                        specifier: "%.1f"
                    )
                }
                
                // --- 6. Style-Specific Settings ---
                // This panel is now dynamic based on your selection
                switch style.representation {
                case .binaryLineGraph:
                    Section("Line Graph Settings") {
                        SliderView(
                            label: "Line Amplitude",
                            value: $style.lineAmplitudePercent,
                            range: 0.1...1.0,
                            specifier: "%.2f"
                        )
                        SliderView(
                            label: "Horiz. Padding",
                            value: $style.horizontalPaddingPercent,
                            range: 0.0...0.4,
                            specifier: "%.2f"
                        )
                        SliderView(
                            label: "Vertical Spacing",
                            value: $style.verticalSpacing,
                            range: 0...20,
                            specifier: "%.1f"
                        )
                        Picker("Marker Shape", selection: $style.markerShape) {
                            ForEach(MarkerShape.allCases) { shape in
                                Text(shape.rawValue).tag(shape)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                case .binaryDots:
                    Section("Dots Settings") {
                        SliderView(
                            label: "Dot Spacing",
                            value: $style.verticalSpacing,
                            range: 0...20,
                            specifier: "%.1f"
                        )
                    }
                }
            }
            .navigationTitle("Widget Style")
            .tint(style.lineColors[0].color)
            .onDisappear {
                saveCurrentStyle()
            }
            .onChange(of: style) { _, _ in
                saveCurrentStyle()
            }
        }
    }
    
    func saveCurrentStyle() {
        StyleManager.saveStyle(style, for: selectedFamily)
    }
}

// --- TimeVisualizationView (sub-view) ---
/// This view is unchanged, but you can see how it
/// switches the preview based on the style.
struct TimeVisualizationView: View {
    let date: Date
    @Binding var style: WidgetStyle
    
    var body: some View {
        let binaryLayers = TimeConverter.getTimeAsBinaryLayers(from: date)
        
        switch style.representation {
        case .binaryLineGraph:
            VStack(spacing: style.verticalSpacing) {
                ForEach(0..<binaryLayers.count, id: \.self) { index in
                    let digits = binaryLayers[index]
                    let color = style.lineColors[index % style.lineColors.count].color
                    
                    BinaryLineShape(
                        digits: digits,
                        amplitudePercent: style.lineAmplitudePercent,
                        horizontalPaddingPercent: style.horizontalPaddingPercent
                    )
                    .stroke(color, lineWidth: style.lineWidth)
                    .overlay(
                        // We must pass the new shape property
                        BinaryMarkerShape(
                            digits: digits,
                            markerSize: style.markerSize,
                            amplitudePercent: style.lineAmplitudePercent,
                            horizontalPaddingPercent: style.horizontalPaddingPercent,
                            markerShape: style.markerShape // <-- PASSING NEW PROP
                        )
                        .fill(color)
                    )
                }
            }
            .padding(style.widgetPadding)
            .background(style.backgroundColor.color)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            
        case .binaryDots:
            BinaryDotsView(binaryLayers: binaryLayers, style: style)
        }
    }
}

// --- SliderView (helper) ---
struct SliderView: View {
    // ... (This struct is unchanged) ...
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
