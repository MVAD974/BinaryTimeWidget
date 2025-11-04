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
        
        // --- This is the most important part for a clock ---
        let currentDate = Date()
        
        // 1. Calculate the start of the next minute
        guard let nextUpdateDate = Calendar.current.date(
            byAdding: .minute,
            value: 1,
            to: currentDate
        ) else {
            return // Should not fail
        }
        
        // 2. Get the binary data for the *current* time
        let layers = TimeConverter.getTimeAsBinaryLayers(from: currentDate)
        
        // 3. Create a single timeline entry for *now*
        let entry = SimpleEntry(date: currentDate, binaryLayers: layers)
        
        // 4. Create the timeline.
        // The `policy: .after(nextUpdateDate)` tells WidgetKit
        // "Show this entry, and then ask me for a new one *after* the next minute begins."
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdateDate))
        completion(timeline)
    }
}

// --- 2. The Data Model (Timeline Entry) ---
// This struct holds the data for a single widget refresh.
struct SimpleEntry: TimelineEntry {
    let date: Date
    let binaryLayers: [[Int]] // Our 4x4 array of binary data
}

// --- 3. The Widget's View ---
// This is the SwiftUI view that actually renders the widget.
struct TimeWidgetEntryView : View {
    var entry: Provider.Entry
    
    // Define some colors, similar to your 'coolwarm' colormap
    private let colors: [Color] = [.blue, .cyan, .yellow, .orange]

    var body: some View {
        // A VStack (Vertical Stack) to stack the 4 lines
        VStack(spacing: 5) {
            
            // Loop over the 4 layers of data
            ForEach(0..<entry.binaryLayers.count, id: \.self) { index in
                let digits = entry.binaryLayers[index]
                let color = colors[index % colors.count]
                
                // Draw the line shape
                BinaryLineShape(digits: digits)
                    // We must "stroke" the path to make the line visible
                    .stroke(color, lineWidth: 3.0) // Use 3pt line width
                    .overlay(
                        // Add the small circles ("markers")
                        BinaryMarkerShape(digits: digits)
                            .fill(color)
                    )
            }
        }
        .padding(12) // Add some padding around the whole widget
        // This is the modern way to set a widget background
        .containerBackground(.black, for: .widget)
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
        // We can support multiple sizes, but let's start with medium.
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])    }
}

// --- 5. (Bonus) A Shape for the Markers ---
// This is a separate shape to draw just the 'o' markers from your script.
struct BinaryMarkerShape: Shape {
    let digits: [Int]
    let markerSize: CGFloat = 5.0 // Size of the circle

    func path(in rect: CGRect) -> Path {
        var path = Path()
        guard digits.count == 4 else { return path }
        
        let xStep = rect.width / 3.0
        let yAmplitude = rect.height * 1.0
        let yOffset = rect.height * 0.0
        
        func point(at index: Int) -> CGPoint {
            let x = CGFloat(index) * xStep
            let y = yOffset + (1.0 - CGFloat(digits[index])) * yAmplitude
            return CGPoint(x: x, y: y)
        }

        // Add a circle at each of the 4 points
        for i in 0..<4 {
            let center = point(at: i)
            let markerRect = CGRect(
                x: center.x - markerSize / 2,
                y: center.y - markerSize / 2,
                width: markerSize,
                height: markerSize
            )
            path.addEllipse(in: markerRect)
        }
        
        return path
    }
}

// --- 6. (Bonus) A Preview ---
// This helps you see your widget in Xcode's preview canvas
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
