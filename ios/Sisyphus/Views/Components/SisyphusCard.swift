import SwiftUI

struct SisyphusCard<Content: View>: View {
    var padding: CGFloat = 16
    var showBorder: Bool = true
    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .padding(padding)
            .background(SisyphusTheme.cardBackground)
            .overlay(
                RoundedRectangle(cornerRadius: SisyphusTheme.cardRadius)
                    .stroke(showBorder ? SisyphusTheme.cardBorder : Color.clear, lineWidth: 1)
            )
            .cornerRadius(SisyphusTheme.cardRadius)
    }
}

#Preview {
    SisyphusCard {
        HStack {
            Text("Card Content")
                .foregroundColor(.white)
            Spacer()
        }
    }
    .padding()
    .background(SisyphusTheme.background)
}
