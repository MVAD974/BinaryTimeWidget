//
//  TimeWidget.swift
//  TimeWidget
//
//  Created by Marc Vadier on 04/11/2025.
//
//  ** NOTE: This file requires iOS 17+ **
//

import WidgetKit
import SwiftUI

// --- 1. The Timeline Provider ---
struct Provider: TimelineProvider {
    
    private func getStyle(for context: Context) -> WidgetStyle {
        return StyleManager.loadStyle(for: context.family)
    }
    
    func placeholder(in context: Context) -> SimpleEntry {
        let layers = [
            TimeConverter.digitToBinary(1), // 1
            TimeConverter.digitToBinary(0), // 0
            TimeConverter.digitToBinary(0), // 0
            TimeConverter.digitToBinary(8)  // 8
        ]
        return SimpleEntry(date: Date(), binaryLayers: layers, style: getStyle(for: context))
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let layers = TimeConverter.getTimeAsBinaryLayers(from: Date())
        let entry = SimpleEntry(date: Date(), binaryLayers: layers, style: getStyle(for: context))
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        
        let currentDate = Date()
        guard let nextUpdateDate = Calendar.current.date(
            byAdding: .minute,
            @ViewBuilder
            private var widgetBody: some View {
                VStack(spacing: style.verticalSpacing) {
                    ForEach(0..<entry.binaryLayers.count, id: \.self) { index in
                        let digits = entry.binaryLayers[index]
                        let color = style.lineColors[index % style.lineColors.count].color
                
                        BinaryLineShape(
                            digits: digits,
                            amplitudePercent: style.lineAmplitudePercent,
                            horizontalPaddingPercent: style.horizontalPaddingPercent
                        )
                        .stroke(color, lineWidth: style.lineWidth)
                        .overlay(
                            BinaryMarkerShape(
                                digits: digits,
                                markerSize: style.markerSize,
                                amplitudePercent: style.lineAmplitudePercent,
                                horizontalPaddingPercent: style.horizontalPaddingPercent,
                                markerShape: style.markerShape
                            )
                            .fill(color)
                        )
                    }
                }
                .padding(style.widgetPadding)
            }
                                    markerShape: style.markerShape
                                )
                                .fill(color)
                            )
                        }
                    }
                    .padding(style.widgetPadding)
                ForEach(0..<entry.binaryLayers.count, id: \.self) { index in
                    let digits = entry.binaryLayers[index]
                    let color = style.lineColors[index % style.lineColors.count].color
                    
                    BinaryLineShape(
                        digits: digits,
                        amplitudePercent: style.lineAmplitudePercent,
                        horizontalPaddingPercent: style.horizontalPaddingPercent
                    )
                    .stroke(color, lineWidth: style.lineWidth)
                    .overlay(
                        BinaryMarkerShape(
                            digits: digits,
                            markerSize: style.markerSize,
                            amplitudePercent: style.lineAmplitudePercent,
                            horizontalPaddingPercent: style.horizontalPaddingPercent,
                            markerShape: style.markerShape // <-- ** ADD THIS LINE **
                        )
                        .fill(color)
                    )
                }
            }
            .padding(style.widgetPadding)
    }
}

// --- 4. The Widget Configuration ---
struct TimeWidget: Widget {
    let kind: String = "TimeWidget"

    var body: some WidgetConfiguration {
        // This is now simple, with no #if checks.
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            TimeWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Binary Time")
        .description("Displays the time as a layered binary plot.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

// --- 5. Previews ---
// We can now use a simple preview, also for iOS 17+.
// NOTE: Previews only work if this file is also in the App target.
// If you've removed it (as we did in the last step),
// you can just delete this Preview struct.
#if DEBUG
struct TimeWidget_Previews: PreviewProvider {
    static var previews: some View {
        let style = StyleManager.loadStyle(for: .systemSmall)
        let layers = [
            TimeConverter.digitToBinary(1), // 1
            TimeConverter.digitToBinary(8), // 8
            TimeConverter.digitToBinary(5), // 5
            TimeConverter.digitToBinary(2)  // 2
        ]
        let entry = SimpleEntry(date: Date(), binaryLayers: layers, style: style)
        
        TimeWidgetEntryView(entry: entry)
            .previewContext(WidgetPreviewContext(family: .systemSmall))
            .containerBackground(for: .widget) {
                style.backgroundColor.color
            }
    }
}
#endif
