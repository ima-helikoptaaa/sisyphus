import SwiftUI

struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String
    var actionTitle: String?
    var action: (() -> Void)?

    var body: some View {
        VStack(spacing: 16) {
            Spacer()

            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundColor(SisyphusTheme.textTertiary)

            Text(title)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(SisyphusTheme.textPrimary)

            Text(subtitle)
                .font(.system(size: 15))
                .foregroundColor(SisyphusTheme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            if let actionTitle = actionTitle, let action = action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.black)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(SisyphusTheme.accent)
                        .cornerRadius(SisyphusTheme.buttonRadius)
                }
                .padding(.top, 8)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    EmptyStateView(
        icon: "dumbbell",
        title: "No Workouts Yet",
        subtitle: "Create your first workout split to get started.",
        actionTitle: "Create Split"
    ) {}
    .background(SisyphusTheme.background)
}
