import SwiftUI

struct ProgressRing: View {
    let progress: Double
    var lineWidth: CGFloat = 8
    var size: CGFloat = 80
    var backgroundColor: Color = SisyphusTheme.cardBorder
    var foregroundColor: Color = SisyphusTheme.accent
    var showLabel: Bool = true
    var labelText: String?

    @State private var animatedProgress: Double = 0

    var body: some View {
        ZStack {
            Circle()
                .stroke(backgroundColor, lineWidth: lineWidth)
                .frame(width: size, height: size)

            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(
                    foregroundColor,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .frame(width: size, height: size)
                .rotationEffect(.degrees(-90))

            if showLabel {
                Text(labelText ?? "\(Int(progress * 100))%")
                    .font(.system(size: size * 0.22, weight: .bold, design: .rounded))
                    .foregroundColor(SisyphusTheme.textPrimary)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Progress: \(labelText ?? "\(Int(progress * 100))%")")
        .onAppear {
            withAnimation(.easeInOut(duration: 0.8)) {
                animatedProgress = min(progress, 1.0)
            }
        }
        .onChange(of: progress) { _, newValue in
            withAnimation(.easeInOut(duration: 0.5)) {
                animatedProgress = min(newValue, 1.0)
            }
        }
    }
}

#Preview {
    HStack(spacing: 20) {
        ProgressRing(progress: 0.75, size: 60)
        ProgressRing(progress: 0.5, size: 80, foregroundColor: .blue)
        ProgressRing(progress: 1.0, size: 100, labelText: "3/3")
    }
    .padding()
    .background(SisyphusTheme.background)
}
