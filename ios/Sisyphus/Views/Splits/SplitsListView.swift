import SwiftUI

struct SplitsListView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = SplitsViewModel()
    @State private var showingAddSplit = false
    @State private var splitToDelete: WorkoutSplit?
    @State private var showDeleteConfirmation = false
    var showCloseButton = false

    var body: some View {
        ZStack {
            SisyphusTheme.background
                .ignoresSafeArea()

            if viewModel.splits.isEmpty && !viewModel.isLoading {
                EmptyStateView(
                    icon: "rectangle.stack",
                    title: "No Workout Splits",
                    subtitle: "Create splits to organize your exercises into workout routines.",
                    actionTitle: "Create Split"
                ) {
                    showingAddSplit = true
                }
            } else {
                List {
                    ForEach(viewModel.splits) { split in
                        NavigationLink {
                            SplitDetailView(splitId: split.id)
                        } label: {
                            SplitRowView(split: split)
                        }
                        .listRowBackground(SisyphusTheme.cardBackground)
                        .listRowSeparatorTint(SisyphusTheme.cardBorder)
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                splitToDelete = split
                                showDeleteConfirmation = true
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .refreshable {
                    await viewModel.loadSplits()
                }
            }
        }
        .navigationTitle("Workout Splits")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            if showCloseButton {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(SisyphusTheme.textSecondary)
                    }
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingAddSplit = true }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(SisyphusTheme.accent)
                }
            }
        }
        .sheet(isPresented: $showingAddSplit) {
            AddSplitSheet { name, emoji, color in
                return await viewModel.createSplit(name: name, emoji: emoji, color: color)
            }
            .presentationDetents([.medium])
        }
        .alert("Delete Split", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                if let split = splitToDelete {
                    Task {
                        _ = await viewModel.deleteSplit(id: split.id)
                    }
                }
            }
        } message: {
            Text("Are you sure you want to delete \"\(splitToDelete?.name ?? "")\"? This cannot be undone.")
        }
        .task {
            await viewModel.loadSplits()
        }
    }
}

struct SplitRowView: View {
    let split: WorkoutSplit

    var body: some View {
        HStack(spacing: 14) {
            Text(split.emoji)
                .font(.system(size: 24))
                .frame(width: 44, height: 44)
                .background(Color(hex: split.color).opacity(0.15))
                .cornerRadius(10)

            VStack(alignment: .leading, spacing: 3) {
                Text(split.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(SisyphusTheme.textPrimary)

                if let count = split.exerciseCount {
                    Text("\(count) exercises")
                        .font(.system(size: 13))
                        .foregroundColor(SisyphusTheme.textSecondary)
                }
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        SplitsListView()
    }
}
