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
                            x: .value("Date", item.date, unit: .day),
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
                        AxisMarks(values: .stride(by: .day, count: 7)) { value in
                            AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                                .foregroundStyle(SisyphusTheme.cardBorder)
                            if let dateStr = value.as(String.self) {
                                AxisValueLabel(formatDateLabel(dateStr))
                                    .foregroundStyle(SisyphusTheme.textTertiary)
                                    .font(.system(size: 10))
                            }
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
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Workout frequency chart, \(data.count) days with \(data.reduce(0) { $0 + $1.count }) total workouts")
    }

    private func formatDateLabel(_ dateStr: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(identifier: "UTC")
        guard let date = formatter.date(from: dateStr) else { return dateStr }
        let displayFormatter = DateFormatter()
        displayFormatter.dateFormat = "d/M"
        return displayFormatter.string(from: date)
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
