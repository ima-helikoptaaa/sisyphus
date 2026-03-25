import SwiftUI

struct SettingsView: View {
    @AppStorage("api_base_url") private var apiBaseURL = "http://localhost:3000"
    @AppStorage("default_rest_timer") private var defaultRestTimer = 90
    @AppStorage("weight_unit") private var weightUnit = "kg"
    @State private var showingURLEditor = false
    @State private var tempURL = ""

    private let restTimerOptions = [30, 45, 60, 90, 120, 180]
    private let weightUnits = ["kg", "lbs"]

    var body: some View {
        ZStack {
            SisyphusTheme.background
                .ignoresSafeArea()

            List {
                // General section
                Section {
                    // Weight Unit
                    HStack {
                        Label("Weight Unit", systemImage: "scalemass")
                            .foregroundColor(SisyphusTheme.textPrimary)
                        Spacer()
                        Picker("", selection: $weightUnit) {
                            ForEach(weightUnits, id: \.self) { unit in
                                Text(unit).tag(unit)
                            }
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 120)
                    }

                    // Default Rest Timer
                    HStack {
                        Label("Rest Timer", systemImage: "timer")
                            .foregroundColor(SisyphusTheme.textPrimary)
                        Spacer()
                        Picker("", selection: $defaultRestTimer) {
                            ForEach(restTimerOptions, id: \.self) { seconds in
                                Text(formatRestTime(seconds)).tag(seconds)
                            }
                        }
                        .tint(SisyphusTheme.accent)
                    }
                } header: {
                    Text("General")
                        .foregroundColor(SisyphusTheme.textSecondary)
                }
                .listRowBackground(SisyphusTheme.cardBackground)

                // Developer section
                Section {
                    Button(action: {
                        tempURL = apiBaseURL
                        showingURLEditor = true
                    }) {
                        HStack {
                            Label("API URL", systemImage: "server.rack")
                                .foregroundColor(SisyphusTheme.textPrimary)
                            Spacer()
                            Text(apiBaseURL)
                                .font(.system(size: 13, design: .monospaced))
                                .foregroundColor(SisyphusTheme.textSecondary)
                                .lineLimit(1)
                        }
                    }
                } header: {
                    Text("Developer")
                        .foregroundColor(SisyphusTheme.textSecondary)
                }
                .listRowBackground(SisyphusTheme.cardBackground)

                // About section
                Section {
                    HStack {
                        Label("Version", systemImage: "info.circle")
                            .foregroundColor(SisyphusTheme.textPrimary)
                        Spacer()
                        Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0")
                            .foregroundColor(SisyphusTheme.textSecondary)
                    }

                    HStack {
                        Label("Build", systemImage: "hammer")
                            .foregroundColor(SisyphusTheme.textPrimary)
                        Spacer()
                        Text(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1")
                            .foregroundColor(SisyphusTheme.textSecondary)
                    }
                } header: {
                    Text("About")
                        .foregroundColor(SisyphusTheme.textSecondary)
                } footer: {
                    VStack(spacing: 8) {
                        Text("SISYPHUS")
                            .font(.system(size: 14, weight: .bold))
                            .tracking(4)
                            .foregroundColor(SisyphusTheme.accent.opacity(0.5))

                        Text("Push your limits. Every day.")
                            .font(.system(size: 12))
                            .foregroundColor(SisyphusTheme.textTertiary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 24)
                }
                .listRowBackground(SisyphusTheme.cardBackground)
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.large)
        .alert("API Base URL", isPresented: $showingURLEditor) {
            TextField("URL", text: $tempURL)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
            Button("Save") {
                if let url = URL(string: tempURL), url.scheme != nil, url.host != nil {
                    apiBaseURL = tempURL
                }
            }
            Button("Reset") {
                apiBaseURL = "http://localhost:3000"
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Enter the base URL for the API server.")
        }
    }

    private func formatRestTime(_ seconds: Int) -> String {
        if seconds >= 60 {
            let min = seconds / 60
            let sec = seconds % 60
            return sec > 0 ? "\(min)m \(sec)s" : "\(min)m"
        }
        return "\(seconds)s"
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
