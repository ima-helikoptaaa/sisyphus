import SwiftUI
import Charts

struct VolumeChart: View {
    let data: [DayCount]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Workout Frequency")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(SisyphusTheme.textPrimary)

            SisyphusCard(padding: 12) {
                if data.isEmpty {
                    HStack {
                        Spacer()
                        Text("No workout data yet")
                            .font(.system(size: 14))
                            .foregroundColor(SisyphusTheme.textSecondary)
                        Spacer()
                    }
                    .frame(height: 160)
                } else {
                    Chart(data) { item in
                        BarMark(
                            x: .value("Date", item.date),
                            y: .value("Count", item.count)
                        )
                        .foregroundStyle(
                            item.count > 0
                                ? SisyphusTheme.accent
                                : SisyphusTheme.cardBorder
                        )
                        .cornerRadius(3)
                    }
                    .chartXAxis {
                        AxisMarks(values: .automatic(desiredCount: 7)) { _ in
                            AxisValueLabel()
                                .foregroundStyle(SisyphusTheme.textTertiary)
                                .font(.system(size: 10))
                        }
                    }
                    .chartYAxis {
                        AxisMarks(position: .leading) { _ in
                            AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [5, 5]))
                                .foregroundStyle(SisyphusTheme.cardBorder)
                            AxisValueLabel()
                                .foregroundStyle(SisyphusTheme.textTertiary)
                        }
                    }
                    .frame(height: 160)
                }
            }
        }
    }
}

#Preview {
    VolumeChart(data: [
        DayCount(date: "Mon", count: 1),
        DayCount(date: "Tue", count: 0),
        DayCount(date: "Wed", count: 1),
        DayCount(date: "Thu", count: 0),
        DayCount(date: "Fri", count: 2),
        DayCount(date: "Sat", count: 1),
        DayCount(date: "Sun", count: 0),
    ])
    .padding()
    .background(SisyphusTheme.background)
}
