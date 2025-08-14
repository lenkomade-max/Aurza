import WidgetKit
import SwiftUI

struct StreakEntry: TimelineEntry {
    let date: Date
    let streakCount: Int
}

struct StreakProvider: TimelineProvider {
    func placeholder(in context: Context) -> StreakEntry {
        StreakEntry(date: Date(), streakCount: 3)
    }

    func getSnapshot(in context: Context, completion: @escaping (StreakEntry) -> ()) {
        let entry = StreakEntry(date: Date(), streakCount: 5)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<StreakEntry>) -> ()) {
        let entry = StreakEntry(date: Date(), streakCount: 7)
        let timeline = Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(60 * 60)))
        completion(timeline)
    }
}

struct StreakWidgetEntryView : View {
    var entry: StreakProvider.Entry

    var body: some View {
        VStack {
            Text("Streak")
                .font(.headline)
            Text("\(entry.streakCount) days")
                .font(.title)
        }
        .padding()
    }
}

struct StreakWidget: Widget {
    let kind: String = "StreakWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: StreakProvider()) { entry in
            StreakWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Streak")
        .description("Shows your current streak.")
        .supportedFamilies([.systemSmall])
    }
}
