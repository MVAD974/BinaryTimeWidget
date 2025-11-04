//
//  TimeWidget.swift
//  TimeWidget
//
//  Created by Marc Vadier on 04/11/2025.
//

import WidgetKit
import SwiftUI

// --- 1. The Timeline Provider ---
// This object provides the data (the "Timeline") for the widget.
struct Provider: TimelineProvider {
    
    /// Provides a sample entry for the widget gallery (e.g., 10:08)
    func placeholder(in context: Context) -> SimpleEntry {
        let layers = [
            TimeConverter.digitToBinary(1), // 1
            TimeConverter.digitToBinary(0), // 0
            TimeConverter.digitToBinary(0), // 0
            TimeConverter.digitToBinary(8)  // 8
        ]
        return SimpleEntry(date: Date(), binaryLayers: layers)
    }

    /// Provides the current state of the widget for the gallery.
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let layers = TimeConverter.getTimeAsBinaryLayers(from: Date())
        let entry = SimpleEntry(date: Date(), binaryLayers: layers)
        completion(entry)
    }

    /// Provides the timeline (past, present, future) for the widget.
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        
        let currentDate = Date()
        
        guard let nextUpdateDate = Calendar.current.date(
            byAdding: .minute,
            value: 1,
            to: currentDate
        ) else {
            return
        }
        
        let layers = TimeConverter.getTimeAsBinaryLayers(from: currentDate)
        let entry = SimpleEntry(date: currentDate, binaryLayers: layers)
        
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdateDate))
        completion(timeline)
    }
}

// --- 2. The Data Model (Timeline Entry) ---
struct SimpleEntry: TimelineEntry {
    let date: Date
    let binaryLayers: [[Int]] // Our 4x4 array of binary data
    
    /// **NEW: Accessibility helper**
    /// Provides a human-readable string for VoiceOver.
    var accessibilityTimeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short // e.g., "10:45 AM"
        
        // This format is clearer for VoiceOver
        let components = Calendar.current.dateComponents([.hour, .minute], from: date)
        let hour = components.hour ?? 0
        let minute = components.minute ?? 0
        
        // Reads as "Time, 10 45"
        return "Time, \(hour) \(String(format: "%02d", minute))"
    }
}

// --- 3. The Widget's View ---
struct TimeWidgetEntryView : View {
    var entry: Provider.Entry
    
    /// **NEW: The single source of truth for styling.**
    let style = WidgetStyle.default

    var body: some View {
        // A VStack (Vertical Stack) to stack the 4 lines
        VStack(spacing: style.verticalSpacing) { // <-- MODIFIED
            
            // Loop over the 4 layers of data
            ForEach(0..<entry.binaryLayers.count, id: \.self) { index in
                let digits = entry.binaryLayers[index]
                let color = style.lineColors[index % style.lineColors.count] // <-- MODIFIED
                
                // Draw the line shape
                BinaryLineShape(
                    digits: digits,
                    amplitudePercent: style.lineAmplitudePercent // <-- MODIFIED
                )
                    // We must "stroke" the path to make the line visible
                    .stroke(color, lineWidth: style.lineWidth) // <-- MODIFIED
                    .overlay(
                        // Add the small circles ("markers")
                        BinaryMarkerShape(
                            digits: digits,
                            markerSize: style.markerSize, // <-- MODIFIED
                            amplitudePercent: style.lineAmplitudePercent // <-- MODIFIED
                        )
                            .fill(color)
                    )
            }
        }
        .padding(style.widgetPadding) // <-- MODIFIED
        .containerBackground(style.backgroundColor, for: .widget) // <-- MODIFIED
        
        // --- **NEW: Accessibility** ---
        // This treats the whole widget as one element
        // and gives it a useful VoiceOver label.
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

// --- 5. (Bonus) A Shape for the Markers ---
// **DELETED**: This struct has been moved to its own file: `BinaryMarkerShape.swift`


// --- 6. (Bonus) A Preview ---
struct TimeWidget_Previews: PreviewProvider {
    static var previews: some View {
        let layers = [
            TimeConverter.digitToBinary(1), // 1
            TimeConverter.digitToBinary(8), // 8
            TimeConverter.digitToBinary(5), // 5
            TimeConverter.digitToBinary(2)  // 2
        ]
        let entry = SimpleEntry(date: Date(), binaryLayers: layers)
        
        TimeWidgetEntryView(entry: entry)
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
