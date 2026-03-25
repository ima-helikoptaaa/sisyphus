import SwiftUI

struct AddSplitSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var selectedEmoji = "\u{1F4AA}"
    @State private var selectedColor = "C8E64E"
    @State private var isSaving = false
    @State private var errorMessage: String?

    /// Returns nil on success, or an error message string on failure.
    let onSave: (String, String, String) async -> String?

    private let emojis = [
        "\u{1F4AA}", "\u{1F3CB}", "\u{1F3C3}", "\u{1F6B4}",
        "\u{1F9D8}", "\u{26F9}", "\u{1F938}", "\u{1F3CA}",
        "\u{1F3AF}", "\u{2B50}", "\u{1F525}", "\u{26A1}",
        "\u{1F48E}", "\u{1F680}", "\u{1F3C6}", "\u{1F4A5}"
    ]

    private let colors = [
        "C8E64E", "FF6B6B", "4ECDC4", "45B7D1",
        "96CEB4", "FFEAA7", "DDA0DD", "FF9500",
        "FF3B30", "34C759", "007AFF", "AF52DE"
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                SisyphusTheme.background
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        if let error = errorMessage {
                            Text(error)
                                .font(.system(size: 14))
                                .foregroundColor(SisyphusTheme.destructive)
                                .padding(12)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(SisyphusTheme.destructive.opacity(0.1))
                                .cornerRadius(SisyphusTheme.smallRadius)
                        }

                        // Name field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Name")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(SisyphusTheme.textSecondary)

                            TextField("e.g., Push Day, Leg Day", text: $name)
                                .font(.system(size: 17))
                                .foregroundColor(SisyphusTheme.textPrimary)
                                .padding(14)
                                .background(SisyphusTheme.cardBackground)
                                .cornerRadius(SisyphusTheme.smallRadius)
                                .overlay(
                                    RoundedRectangle(cornerRadius: SisyphusTheme.smallRadius)
                                        .stroke(name.count > 50 ? SisyphusTheme.destructive : SisyphusTheme.cardBorder, lineWidth: 1)
                                )
                                .onChange(of: name) { _, newValue in
                                    if newValue.count > 50 {
                                        name = String(newValue.prefix(50))
                                    }
                                }
                        }

                        // Emoji picker
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Icon")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(SisyphusTheme.textSecondary)

                            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 8), spacing: 12) {
                                ForEach(emojis, id: \.self) { emoji in
                                    Button(action: { selectedEmoji = emoji }) {
                                        Text(emoji)
                                            .font(.system(size: 28))
                                            .frame(width: 44, height: 44)
                                            .background(
                                                selectedEmoji == emoji
                                                    ? Color(hex: selectedColor).opacity(0.3)
                                                    : SisyphusTheme.cardBackground
                                            )
                                            .cornerRadius(SisyphusTheme.smallRadius)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: SisyphusTheme.smallRadius)
                                                    .stroke(
                                                        selectedEmoji == emoji
                                                            ? Color(hex: selectedColor)
                                                            : SisyphusTheme.cardBorder,
                                                        lineWidth: selectedEmoji == emoji ? 2 : 1
                                                    )
                                            )
                                    }
                                }
                            }
                        }

                        // Color picker
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Color")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(SisyphusTheme.textSecondary)

                            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 6), spacing: 12) {
                                ForEach(colors, id: \.self) { color in
                                    Button(action: { selectedColor = color }) {
                                        Circle()
                                            .fill(Color(hex: color))
                                            .frame(width: 40, height: 40)
                                            .overlay(
                                                Circle()
                                                    .stroke(Color.white, lineWidth: selectedColor == color ? 3 : 0)
                                                    .padding(2)
                                            )
                                            .overlay(
                                                Image(systemName: "checkmark")
                                                    .font(.system(size: 14, weight: .bold))
                                                    .foregroundColor(.white)
                                                    .opacity(selectedColor == color ? 1 : 0)
                                            )
                                    }
                                }
                            }
                        }

                        // Preview
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Preview")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(SisyphusTheme.textSecondary)

                            SisyphusCard {
                                HStack(spacing: 12) {
                                    Text(selectedEmoji)
                                        .font(.system(size: 28))
                                        .frame(width: 48, height: 48)
                                        .background(Color(hex: selectedColor).opacity(0.15))
                                        .cornerRadius(SisyphusTheme.smallRadius)

                                    VStack(alignment: .leading) {
                                        Text(name.isEmpty ? "Split Name" : name)
                                            .font(.system(size: 17, weight: .semibold))
                                            .foregroundColor(name.isEmpty ? SisyphusTheme.textTertiary : SisyphusTheme.textPrimary)
                                        Text("0 exercises")
                                            .font(.system(size: 13))
                                            .foregroundColor(SisyphusTheme.textSecondary)
                                    }
                                    Spacer()
                                }
                            }
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle("New Split")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(SisyphusTheme.textSecondary)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        isSaving = true
                        errorMessage = nil
                        Task {
                            let error = await onSave(name, selectedEmoji, selectedColor)
                            isSaving = false
                            if let error {
                                errorMessage = error
                            } else {
                                dismiss()
                            }
                        }
                    } label: {
                        if isSaving {
                            ProgressView()
                                .tint(SisyphusTheme.accent)
                                .scaleEffect(0.8)
                        } else {
                            Text("Save")
                                .font(.system(size: 16, weight: .semibold))
                        }
                    }
                    .foregroundColor(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? SisyphusTheme.textTertiary : SisyphusTheme.accent)
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || name.count > 50 || isSaving)
                }
            }
        }
    }
}

#Preview {
    AddSplitSheet { _, _, _ in nil }
}
