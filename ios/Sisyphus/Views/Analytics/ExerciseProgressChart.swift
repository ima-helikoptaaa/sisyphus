import SwiftUI
import Charts

enum ProgressChartMode: String, CaseIterable {
    case weight = "Weight"
    case volume = "Volume"
    case reps = "Reps"
}

struct ExerciseProgressChart: View {
    let data: [ExerciseProgressPoint]
    @State private var chartMode: ProgressChartMode = .weight

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Exercise Progress")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(SisyphusTheme.textPrimary)

                Spacer()

                Picker("Mode", selection: $chartMode) {
                    ForEach(ProgressChartMode.allCases, id: \.self) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 200)
            }

            SisyphusCard(padding: 12) {
                if data.isEmpty {
                    Text("No data available")
                        .font(.system(size: 14))
                        .foregroundColor(SisyphusTheme.textSecondary)
                        .frame(height: 200)
                        .frame(maxWidth: .infinity)
                } else {
                    Chart(data) { point in
                        LineMark(
                            x: .value("Date", point.date),
                            y: .value(chartMode.rawValue, valueForPoint(point))
                        )
                        .foregroundStyle(SisyphusTheme.accent)
                        .lineStyle(StrokeStyle(lineWidth: 2))

                        AreaMark(
                            x: .value("Date", point.date),
                            y: .value(chartMode.rawValue, valueForPoint(point))
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [SisyphusTheme.accent.opacity(0.3), SisyphusTheme.accent.opacity(0.0)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )

                        PointMark(
                            x: .value("Date", point.date),
                            y: .value(chartMode.rawValue, valueForPoint(point))
                        )
                        .foregroundStyle(SisyphusTheme.accent)
                        .symbolSize(30)
                    }
                    .chartXAxis {
                        AxisMarks(values: .automatic(desiredCount: 5)) { _ in
                            AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                                .foregroundStyle(SisyphusTheme.cardBorder)
                            AxisValueLabel()
                                .foregroundStyle(SisyphusTheme.textTertiary)
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
                    .frame(height: 200)
                }
            }
        }
    }

    private func valueForPoint(_ point: ExerciseProgressPoint) -> Double {
        switch chartMode {
        case .weight:
            return point.maxWeight
        case .volume:
            return point.totalVolume
        case .reps:
            return Double(point.maxReps)
        }
    }
}

#Preview {
    ExerciseProgressChart(data: [])
        .padding()
        .background(SisyphusTheme.background)
}
