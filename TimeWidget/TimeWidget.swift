//
//  TimeWidget.swift
//  TimeWidget
//
//  Created by Marc Vadier on 04/11/2025.
//

import WidgetKit
import SwiftUI

// --- 1. The Timeline Provider ---
struct Provider: TimelineProvider {
    
    // **NEW: Load the style once**
    private func getStyle() -> WidgetStyle {
        return StyleManager.loadStyle()
    }
    
    func placeholder(in context: Context) -> SimpleEntry {
        let layers = [
            TimeConverter.digitToBinary(1),
            TimeConverter.digitToBinary(0),
            TimeConverter.digitToBinary(0),
            TimeConverter.digitToBinary(8)
        ]
        // **MODIFIED: Pass style to entry**
        return SimpleEntry(date: Date(), binaryLayers: layers, style: getStyle())
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let layers = TimeConverter.getTimeAsBinaryLayers(from: Date())
        // **MODIFIED: Pass style to entry**
        let entry = SimpleEntry(date: Date(), binaryLayers: layers, style: getStyle())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        
        let currentDate = Date()
        guard let nextUpdateDate = Calendar.current.date(
            byAdding: .minute,
            value: 1,
            to: currentDate
        ) else {
            return
        }
        
        // **NEW: Load the style for the timeline**
        let style = getStyle()
        let layers = TimeConverter.getTimeAsBinaryLayers(from: currentDate)
        
        // **MODIFIED: Pass style to entry**
        let entry = SimpleEntry(date: currentDate, binaryLayers: layers, style: style)
        
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdateDate))
        completion(timeline)
    }
}

// --- 2. The Data Model (Timeline Entry) ---
struct SimpleEntry: TimelineEntry {
    let date: Date
    let binaryLayers: [[Int]]
    let style: WidgetStyle // **NEW: Style is now part of the entry**
    
    var accessibilityTimeString: String {
        let components = Calendar.current.dateComponents([.hour, .minute], from: date)
        let hour = components.hour ?? 0
        let minute = components.minute ?? 0
        return "Time, \(hour) \(String(format: "%02d", minute))"
    }
}

// --- 3. The Widget's View ---
struct TimeWidgetEntryView : View {
    var entry: Provider.Entry
    
    // **MODIFIED: The style now comes from the entry**
    private var style: WidgetStyle { entry.style }

    var body: some View {
        VStack(spacing: style.verticalSpacing) {
            ForEach(0..<entry.binaryLayers.count, id: \.self) { index in
                let digits = entry.binaryLayers[index]
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
        .containerBackground(style.backgroundColor.color, for: .widget)
        .accessibilityElement()
        .accessibilityLabel(entry.accessibilityTimeString)
    }
}

// --- 4. The Widget Configuration ---
struct TimeWidget: Widget {
    let kind: String = "TimeWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            TimeWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Binary Time")
        .description("Displays the time as a layered binary plot.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

// --- 5. (Bonus) A Preview ---
struct TimeWidget_Previews: PreviewProvider {
    static var previews: some View {
        let style = StyleManager.loadStyle()
        let layers = [
            TimeConverter.digitToBinary(1),
            TimeConverter.digitToBinary(8),
            TimeConverter.digitToBinary(5),
            TimeConverter.digitToBinary(2)
        ]
        let entry = SimpleEntry(date: Date(), binaryLayers: layers, style: style)
        
        TimeWidgetEntryView(entry: entry)
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
