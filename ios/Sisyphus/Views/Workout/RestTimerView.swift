import SwiftUI

struct RestTimerView: View {
    let timeRemaining: Int
    let totalTime: Int
    let onDismiss: () -> Void
    let onChangeTime: (Int) -> Void

    private let presets = [30, 60, 90, 120, 180]

    var progress: Double {
        guard totalTime > 0 else { return 0 }
        return Double(timeRemaining) / Double(totalTime)
    }

    var body: some View {
        SisyphusCard {
            VStack(spacing: 16) {
                HStack {
                    Text("Rest Timer")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(SisyphusTheme.textSecondary)

                    Spacer()

                    Button(action: onDismiss) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(SisyphusTheme.textTertiary)
                    }
                }

                // Timer display
                ZStack {
                    Circle()
                        .stroke(SisyphusTheme.cardBorder, lineWidth: 6)
                        .frame(width: 100, height: 100)

                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(
                            SisyphusTheme.accent,
                            style: StrokeStyle(lineWidth: 6, lineCap: .round)
                        )
                        .frame(width: 100, height: 100)
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 1), value: progress)

                    VStack(spacing: 2) {
                        Text(formatTime(timeRemaining))
                            .font(.system(size: 28, weight: .bold, design: .monospaced))
                            .foregroundColor(SisyphusTheme.textPrimary)
                    }
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Rest timer: \(formatTime(timeRemaining)) remaining")

                // Duration presets
                HStack(spacing: 8) {
                    ForEach(presets, id: \.self) { seconds in
                        Button(action: { onChangeTime(seconds) }) {
                            Text(formatPreset(seconds))
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(
                                    totalTime == seconds ? .black : SisyphusTheme.textSecondary
                                )
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(
                                    totalTime == seconds ? SisyphusTheme.accent : SisyphusTheme.background
                                )
                                .cornerRadius(6)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(
                                            totalTime == seconds ? Color.clear : SisyphusTheme.cardBorder,
                                            lineWidth: 1
                                        )
                                )
                        }
                    }
                }

                // Skip button
                Button(action: onDismiss) {
                    Text("Skip Rest")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(SisyphusTheme.textSecondary)
                }
            }
        }
    }

    private func formatTime(_ seconds: Int) -> String {
        let min = seconds / 60
        let sec = seconds % 60
        return String(format: "%d:%02d", min, sec)
    }

    private func formatPreset(_ seconds: Int) -> String {
        if seconds >= 60 {
            let min = seconds / 60
            let sec = seconds % 60
            return sec > 0 ? "\(min):\(String(format: "%02d", sec))" : "\(min)m"
        }
        return "\(seconds)s"
    }
}

#Preview {
    RestTimerView(
        timeRemaining: 45,
        totalTime: 90,
        onDismiss: {},
        onChangeTime: { _ in }
    )
    .padding()
    .background(SisyphusTheme.background)
}
