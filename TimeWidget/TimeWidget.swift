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

// MARK: - Timeline Provider
struct Provider: TimelineProvider {
    private func getStyle(for context: Context) -> WidgetStyle {
        StyleManager.loadStyle(for: context.family)
    }

    func placeholder(in context: Context) -> SimpleEntry {
        let now = Date()
        return SimpleEntry(
            date: now,
            timeBinaryLayers: TimeConverter.getTimeAsBinaryLayers(from: now),
            dateBinaryLayers: TimeConverter.getDateAsBinaryLayers(from: now),
            style: getStyle(for: context)
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let now = Date()
        let entry = SimpleEntry(
            date: now,
            timeBinaryLayers: TimeConverter.getTimeAsBinaryLayers(from: now),
            dateBinaryLayers: TimeConverter.getDateAsBinaryLayers(from: now),
            style: getStyle(for: context)
        )
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let currentDate = Date()
        let nextUpdateDate = Calendar.current.date(byAdding: .minute, value: 1, to: currentDate) ?? currentDate.addingTimeInterval(60)
        let style = getStyle(for: context)
        let entry = SimpleEntry(
            date: currentDate,
            timeBinaryLayers: TimeConverter.getTimeAsBinaryLayers(from: currentDate),
            dateBinaryLayers: TimeConverter.getDateAsBinaryLayers(from: currentDate),
            style: style
        )
        completion(Timeline(entries: [entry], policy: .after(nextUpdateDate)))
    }
}

// MARK: - Entry Model
struct SimpleEntry: TimelineEntry {
    let date: Date
    let timeBinaryLayers: [[Int]]
    let dateBinaryLayers: [[Int]]
    let style: WidgetStyle

    var accessibilityLabel: String {
        let comps = Calendar.current.dateComponents([.hour, .minute, .day, .month], from: date)
        let hour = comps.hour ?? 0
        let minute = comps.minute ?? 0
        let day = comps.day ?? 0
        let month = comps.month ?? 0
        return "Time \(hour):\(String(format: "%02d", minute)), Date \(day)/\(month)"
    }
}

// MARK: - Entry View
struct TimeWidgetEntryView: View {
    var entry: Provider.Entry
    private var style: WidgetStyle { entry.style }
    @Environment(\.widgetFamily) private var family

    var body: some View {
        content
            .containerBackground(style.backgroundColor.color, for: .widget)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(entry.accessibilityLabel)
    }

    @ViewBuilder
    private var content: some View {
        switch style.representation {
        case .binaryLineGraph:
            switch family {
            case .systemMedium:
                HStack(spacing: style.widgetPadding) {
                    binaryColumn(entry.timeBinaryLayers)
                    Divider().overlay(style.lineColors.first?.color ?? .white)
                    binaryColumn(entry.dateBinaryLayers)
                }
                .padding(style.widgetPadding)
            default:
                binaryColumn(entry.timeBinaryLayers)
                    .padding(style.widgetPadding)
            }
        case .artisticBars:
            artisticBarsContent
        }
    }

    private func binaryColumn(_ layers: [[Int]]) -> some View {
        VStack(spacing: style.verticalSpacing) {
            ForEach(Array(layers.enumerated()), id: \.offset) { (index, digits) in
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
    }
}

// MARK: - Artistic Bars Rendering
extension TimeWidgetEntryView {
    @ViewBuilder
    private var artisticBarsContent: some View {
        let timeLayers = entry.timeBinaryLayers
        let dateLayers = entry.dateBinaryLayers
        // Provide default artistic values if nil
        let maxH = style.barMaxHeightPercent ?? 0.9
        let minH = style.barMinHeightPercent ?? 0.25
        let corner = style.barCornerRadius ?? 4
        let spacing = style.barSpacing ?? 3

        switch family {
        case .systemMedium:
            HStack(spacing: style.widgetPadding) {
                artisticColumn(timeLayers, maxHeight: maxH, minHeight: minH, cornerRadius: corner, spacing: spacing)
                Divider().overlay(style.lineColors.first?.color ?? .white)
                artisticColumn(dateLayers, maxHeight: maxH, minHeight: minH, cornerRadius: corner, spacing: spacing)
            }
            .padding(style.widgetPadding)
        default:
            artisticColumn(timeLayers, maxHeight: maxH, minHeight: minH, cornerRadius: corner, spacing: spacing)
                .padding(style.widgetPadding)
        }
    }

    private func artisticColumn(_ layers: [[Int]], maxHeight: CGFloat, minHeight: CGFloat, cornerRadius: CGFloat, spacing: CGFloat) -> some View {
        VStack(spacing: style.verticalSpacing) {
            ForEach(Array(layers.enumerated()), id: \.offset) { (index, digits) in
                let color = style.lineColors[index % style.lineColors.count].color
                GeometryReader { geo in
                    // For four bits -> draw 4 vertical bars side by side
                    let totalWidth = geo.size.width
                    let barCount = digits.count
                    let barSpacing = spacing
                    let availableWidth = totalWidth - (CGFloat(barCount - 1) * barSpacing)
                    let barWidth = availableWidth / CGFloat(barCount)
                    HStack(alignment: .center, spacing: barSpacing) {
                        ForEach(0..<barCount, id: \.self) { i in
                            let bit = digits[i]
                            let heightPercent = bit == 1 ? maxHeight : minHeight
                            RoundedRectangle(cornerRadius: cornerRadius)
                                .fill(color)
                                .frame(width: barWidth, height: geo.size.height * heightPercent, alignment: .bottom)
                                .frame(maxHeight: .infinity, alignment: .bottom)
                        }
                    }
                }
                .frame(height: style.markerSize * 4 + style.lineWidth * 2) // approximate row height
            }
        }
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
        .description("Time and (medium) date in binary line form.")
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
        Group {
            let smallStyle = StyleManager.loadStyle(for: .systemSmall)
            let now = Date()
            let smallEntry = SimpleEntry(
                date: now,
                timeBinaryLayers: TimeConverter.getTimeAsBinaryLayers(from: now),
                dateBinaryLayers: TimeConverter.getDateAsBinaryLayers(from: now),
                style: smallStyle
            )
            TimeWidgetEntryView(entry: smallEntry)
                .previewContext(WidgetPreviewContext(family: .systemSmall))
                .containerBackground(for: .widget) { smallStyle.backgroundColor.color }

            let mediumStyle = StyleManager.loadStyle(for: .systemMedium)
            let mediumEntry = SimpleEntry(
                date: now,
                timeBinaryLayers: TimeConverter.getTimeAsBinaryLayers(from: now),
                dateBinaryLayers: TimeConverter.getDateAsBinaryLayers(from: now),
                style: mediumStyle
            )
            TimeWidgetEntryView(entry: mediumEntry)
                .previewContext(WidgetPreviewContext(family: .systemMedium))
                .containerBackground(for: .widget) { mediumStyle.backgroundColor.color }
        }
    }
}
#endif
