import SwiftUI

struct DailyLogView: View {
    @StateObject private var viewModel = DailyLogViewModel()
    @AppStorage("weight_unit") private var weightUnit = "kg"
    @FocusState private var focusedField: Field?

    enum Field: Hashable {
        case weight, protein, calories, water, sleep, notes
    }

    var body: some View {
        ZStack {
            SisyphusTheme.background
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    // Date header
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Today")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(SisyphusTheme.textSecondary)
                            Text(Date().fullDateString)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(SisyphusTheme.textPrimary)
                        }
                        Spacer()
                        if viewModel.todayLog != nil {
                            Label("Logged", systemImage: "checkmark.circle.fill")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(SisyphusTheme.success)
                        }
                    }

                    // Tracking cards
                    trackerCard(
                        icon: "scalemass.fill",
                        iconColor: .purple,
                        title: "Body Weight",
                        value: $viewModel.weightInput,
                        unit: weightUnit,
                        placeholder: "0",
                        field: .weight
                    )

                    trackerCard(
                        icon: "fork.knife",
                        iconColor: .orange,
                        title: "Protein",
                        value: $viewModel.proteinInput,
                        unit: "g",
                        placeholder: "0",
                        field: .protein
                    )

                    trackerCard(
                        icon: "flame.fill",
                        iconColor: .red,
                        title: "Calories",
                        value: $viewModel.caloriesInput,
                        unit: "kcal",
                        placeholder: "0",
                        field: .calories
                    )

                    trackerCard(
                        icon: "drop.fill",
                        iconColor: .cyan,
                        title: "Water",
                        value: $viewModel.waterInput,
                        unit: "ml",
                        placeholder: "0",
                        field: .water
                    )

                    trackerCard(
                        icon: "moon.fill",
                        iconColor: .indigo,
                        title: "Sleep",
                        value: $viewModel.sleepInput,
                        unit: "hrs",
                        placeholder: "0",
                        field: .sleep
                    )

                    // Notes
                    SisyphusCard {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack(spacing: 8) {
                                Image(systemName: "note.text")
                                    .font(.system(size: 14))
                                    .foregroundColor(SisyphusTheme.textSecondary)
                                Text("Notes")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(SisyphusTheme.textPrimary)
                            }

                            TextField("How are you feeling today?", text: $viewModel.notesInput, axis: .vertical)
                                .font(.system(size: 15))
                                .foregroundColor(SisyphusTheme.textPrimary)
                                .lineLimit(3...6)
                                .focused($focusedField, equals: .notes)
                        }
                    }

                    // Save button
                    Button(action: {
                        focusedField = nil
                        Task { await viewModel.save() }
                    }) {
                        HStack(spacing: 8) {
                            if viewModel.isSaving {
                                ProgressView()
                                    .tint(.black)
                            }
                            Text(viewModel.todayLog != nil ? "Update" : "Save")
                                .font(.system(size: 16, weight: .bold))
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(SisyphusTheme.accent)
                        .foregroundColor(.black)
                        .cornerRadius(SisyphusTheme.buttonRadius)
                    }
                    .disabled(viewModel.isSaving)

                    if let error = viewModel.errorMessage {
                        Text(error)
                            .font(.system(size: 13))
                            .foregroundColor(SisyphusTheme.destructive)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 32)
            }
            .disabled(viewModel.isSaving)

            if viewModel.isLoading && viewModel.todayLog == nil {
                ProgressView()
                    .tint(SisyphusTheme.accent)
            }
        }
        .navigationTitle("Daily Log")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") { focusedField = nil }
                    .foregroundColor(SisyphusTheme.accent)
            }
        }
        .task {
            await viewModel.loadToday()
        }
    }

    private func trackerCard(
        icon: String,
        iconColor: Color,
        title: String,
        value: Binding<String>,
        unit: String,
        placeholder: String,
        field: Field
    ) -> some View {
        SisyphusCard {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(iconColor)
                    .frame(width: 40, height: 40)
                    .background(iconColor.opacity(0.15))
                    .cornerRadius(10)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(SisyphusTheme.textSecondary)

                    HStack(spacing: 4) {
                        TextField(placeholder, text: value)
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(SisyphusTheme.textPrimary)
                            .keyboardType(.decimalPad)
                            .focused($focusedField, equals: field)
                            .frame(maxWidth: 100)

                        Text(unit)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(SisyphusTheme.textTertiary)
                    }
                }

                Spacer()
            }
        }
    }
}

#Preview {
    NavigationStack {
        DailyLogView()
    }
}
