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
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    init() {
        let initialFamily: WidgetFamily = .systemMedium
        _selectedFamily = State(initialValue: initialFamily)
        _style = State(initialValue: StyleManager.loadStyle(for: initialFamily))
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
                    HStack {
                        Spacer()
                        TimeVisualizationView(
                            date: currentDate,
                            style: $style,
                            family: selectedFamily
                        )
                        .frame(width: previewSize.width, height: previewSize.height)
                        .onReceive(timer) { currentDate = $0 }
                        Spacer()
                    }
                }

                // --- 3. Style Chooser ---
                Section("Representation") {
                    Picker("Style", selection: $style.representation) {
                        ForEach(RepresentationStyle.allCases) { styleCase in
                            Text(styleCase.rawValue).tag(styleCase)
                        }
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: style.representation) { _, newValue in
                        if newValue == .artisticBars {
                            // Initialize artistic defaults if nil
                            if style.barMaxHeightPercent == nil { style.barMaxHeightPercent = 0.9 }
                            if style.barMinHeightPercent == nil { style.barMinHeightPercent = 0.25 }
                            if style.barCornerRadius == nil { style.barCornerRadius = 4 }
                            if style.barSpacing == nil { style.barSpacing = 3 }
                        }
                    }
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

                // --- 6. Line Graph Settings ---
                if style.representation == .binaryLineGraph {
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
                }
                if style.representation == .artisticBars {
                    Section("Artistic Bars Settings") {
                        SliderView(
                            label: "Bar Max Height %",
                            value: Binding(
                                get: { style.barMaxHeightPercent ?? 0.9 },
                                set: { style.barMaxHeightPercent = $0 }
                            ),
                            range: 0.2...1.0,
                            specifier: "%.2f"
                        )
                        SliderView(
                            label: "Bar Min Height %",
                            value: Binding(
                                get: { style.barMinHeightPercent ?? 0.25 },
                                set: { style.barMinHeightPercent = $0 }
                            ),
                            range: 0.0...0.8,
                            specifier: "%.2f"
                        )
                        SliderView(
                            label: "Bar Corner Radius",
                            value: Binding(
                                get: { style.barCornerRadius ?? 4 },
                                set: { style.barCornerRadius = $0 }
                            ),
                            range: 0...20,
                            specifier: "%.1f"
                        )
                        SliderView(
                            label: "Bar Spacing",
                            value: Binding(
                                get: { style.barSpacing ?? 3 },
                                set: { style.barSpacing = $0 }
                            ),
                            range: 0...20,
                            specifier: "%.1f"
                        )
                    }
                }
            }
            .navigationTitle("Widget Style")
            .tint(style.lineColors[0].color)
            .onDisappear { saveCurrentStyle() }
            .onChange(of: style) { _, _ in saveCurrentStyle() }
        }
    }

    private func saveCurrentStyle() {
        StyleManager.saveStyle(style, for: selectedFamily)
    }

    // Approximate widget sizes (points) for iPhone widgets (can vary by device, use as preview heuristic)
    private var previewSize: CGSize {
        switch selectedFamily {
        case .systemSmall: return CGSize(width: 158, height: 158)
        case .systemMedium: return CGSize(width: 329, height: 158)
        case .systemLarge: return CGSize(width: 329, height: 345)
        default: return CGSize(width: 158, height: 158)
        }
    }
}

// --- TimeVisualizationView (sub-view) ---
/// This view is unchanged, but you can see how it
/// switches the preview based on the style.
struct TimeVisualizationView: View {
    let date: Date
    @Binding var style: WidgetStyle
    let family: WidgetFamily

    var body: some View {
        let timeLayers = TimeConverter.getTimeAsBinaryLayers(from: date)
        let dateLayers = TimeConverter.getDateAsBinaryLayers(from: date)

        Group {
            switch family {
            case .systemMedium:
                HStack(spacing: style.widgetPadding) {
                    binaryColumn(timeLayers, scale: 1.0)
                    Divider().overlay(style.lineColors.first?.color ?? .white)
                    binaryColumn(dateLayers, scale: 1.0)
                }
            case .systemSmall:
                binaryColumn(timeLayers, scale: 0.85)
            case .systemLarge:
                binaryColumn(timeLayers, scale: 1.1)
            default:
                binaryColumn(timeLayers, scale: 1.0)
            }
        }
        .padding(style.widgetPadding)
        .background(style.backgroundColor.color)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func binaryColumn(_ layers: [[Int]], scale: CGFloat) -> some View {
        VStack(spacing: style.verticalSpacing) {
            ForEach(Array(layers.enumerated()), id: \.offset) { (index, digits) in
                let color = style.lineColors[index % style.lineColors.count].color
                BinaryLineShape(
                    digits: digits,
                    amplitudePercent: style.lineAmplitudePercent * scale,
                    horizontalPaddingPercent: style.horizontalPaddingPercent
                )
                .stroke(color, lineWidth: style.lineWidth)
                .overlay(
                    BinaryMarkerShape(
                        digits: digits,
                        markerSize: style.markerSize,
                        amplitudePercent: style.lineAmplitudePercent * scale,
                        horizontalPaddingPercent: style.horizontalPaddingPercent,
                        markerShape: style.markerShape
                    )
                    .fill(color)
                )
            }
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
