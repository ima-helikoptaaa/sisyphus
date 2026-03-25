import SwiftUI

struct ActiveWorkoutBanner: View {
    @EnvironmentObject var workoutViewModel: WorkoutViewModel
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Pulsing indicator
                Circle()
                    .fill(SisyphusTheme.accent)
                    .frame(width: 10, height: 10)
                    .overlay(
                        Circle()
                            .stroke(SisyphusTheme.accent.opacity(0.4), lineWidth: 2)
                            .scaleEffect(1.5)
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text("Workout in Progress")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(SisyphusTheme.textPrimary)

                    Text(workoutViewModel.elapsedTimeFormatted)
                        .font(.system(size: 13, weight: .medium, design: .monospaced))
                        .foregroundColor(SisyphusTheme.accent)
                }

                Spacer()

                Text("Resume")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.black)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(SisyphusTheme.accent)
                    .cornerRadius(SisyphusTheme.smallRadius)
            }
            .padding(16)
            .background(SisyphusTheme.accent.opacity(0.1))
            .overlay(
                RoundedRectangle(cornerRadius: SisyphusTheme.cardRadius)
                    .stroke(SisyphusTheme.accent.opacity(0.3), lineWidth: 1)
            )
            .cornerRadius(SisyphusTheme.cardRadius)
        }
        .buttonStyle(ScaleButtonStyle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Workout in progress, \(workoutViewModel.elapsedTimeFormatted) elapsed")
        .accessibilityHint("Tap to resume workout")
    }
}

#Preview {
    ActiveWorkoutBanner {
        // tap
    }
    .environmentObject(WorkoutViewModel())
    .padding()
    .background(SisyphusTheme.background)
}
