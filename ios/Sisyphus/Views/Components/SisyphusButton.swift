import SwiftUI

struct SisyphusButton: View {
    let title: String
    var icon: String?
    var style: ButtonStyle = .primary
    var isLoading: Bool = false
    var isDisabled: Bool = false
    let action: () -> Void

    enum ButtonStyle {
        case primary
        case secondary
        case destructive
        case ghost
    }

    var body: some View {
        Button(action: {
            if !isLoading && !isDisabled {
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
                action()
            }
        }) {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView()
                        .tint(textColor)
                        .scaleEffect(0.8)
                } else if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                }
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundColor(textColor)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(backgroundColor)
            .overlay(
                RoundedRectangle(cornerRadius: SisyphusTheme.buttonRadius)
                    .stroke(borderColor, lineWidth: borderWidth)
            )
            .cornerRadius(SisyphusTheme.buttonRadius)
            .opacity(isDisabled ? 0.5 : 1.0)
        }
        .disabled(isLoading || isDisabled)
    }

    private var backgroundColor: Color {
        switch style {
        case .primary:
            return SisyphusTheme.accent
        case .secondary:
            return Color.clear
        case .destructive:
            return SisyphusTheme.destructive
        case .ghost:
            return Color.clear
        }
    }

    private var textColor: Color {
        switch style {
        case .primary:
            return Color.black
        case .secondary:
            return SisyphusTheme.accent
        case .destructive:
            return Color.white
        case .ghost:
            return SisyphusTheme.textSecondary
        }
    }

    private var borderColor: Color {
        switch style {
        case .primary:
            return Color.clear
        case .secondary:
            return SisyphusTheme.accent.opacity(0.5)
        case .destructive:
            return Color.clear
        case .ghost:
            return SisyphusTheme.cardBorder
        }
    }

    private var borderWidth: CGFloat {
        switch style {
        case .primary, .destructive:
            return 0
        case .secondary:
            return 1.5
        case .ghost:
            return 1
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        SisyphusButton(title: "Start Workout", icon: "play.fill", style: .primary) {}
        SisyphusButton(title: "View Details", style: .secondary) {}
        SisyphusButton(title: "Delete", icon: "trash", style: .destructive) {}
        SisyphusButton(title: "Cancel", style: .ghost) {}
        SisyphusButton(title: "Loading...", style: .primary, isLoading: true) {}
    }
    .padding()
    .background(SisyphusTheme.background)
}
