import SwiftUI

struct PersonalRecordsView: View {
    let records: [PersonalRecord]
    @State private var expandedRecordId: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Personal Records")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(SisyphusTheme.textPrimary)

                Spacer()

                Image(systemName: "trophy.fill")
                    .font(.system(size: 16))
                    .foregroundColor(SisyphusTheme.accent)
            }

            ForEach(records) { record in
                SisyphusCard(padding: 0) {
                    VStack(spacing: 0) {
                        // Main row
                        Button(action: {
                            withAnimation(.spring(response: 0.3)) {
                                expandedRecordId = expandedRecordId == record.id ? nil : record.id
                            }
                        }) {
                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(record.exerciseName)
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(SisyphusTheme.textPrimary)
                                        .lineLimit(1)
                                }

                                Spacer()

                                if let bestWeight = record.bestWeight {
                                    VStack(alignment: .trailing, spacing: 2) {
                                        Text("\(bestWeight.cleanString) kg")
                                            .font(.system(size: 18, weight: .bold, design: .rounded))
                                            .foregroundColor(SisyphusTheme.accent)
                                        Text("Best Weight")
                                            .font(.system(size: 11))
                                            .foregroundColor(SisyphusTheme.textTertiary)
                                    }
                                }

                                Image(systemName: expandedRecordId == record.id ? "chevron.up" : "chevron.down")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(SisyphusTheme.textTertiary)
                            }
                            .padding(16)
                        }

                        // Expanded detail
                        if expandedRecordId == record.id {
                            Divider()
                                .background(SisyphusTheme.cardBorder)

                            HStack(spacing: 0) {
                                PRDetailItem(
                                    title: "Best Weight",
                                    value: record.bestWeight.map { "\($0.cleanString) kg" } ?? "-",
                                    date: record.bestWeightDate?.relativeString
                                )
                                PRDetailItem(
                                    title: "Best Volume",
                                    value: record.bestVolume.map { "\($0.cleanString) kg" } ?? "-",
                                    date: record.bestVolumeDate?.relativeString
                                )
                                PRDetailItem(
                                    title: "Best Reps",
                                    value: record.bestReps.map { "\($0)" } ?? "-",
                                    date: record.bestRepsDate?.relativeString
                                )
                            }
                            .padding(.vertical, 12)
                            .padding(.horizontal, 8)
                        }
                    }
                }
            }
        }
    }
}

struct PRDetailItem: View {
    let title: String
    let value: String
    let date: String?

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(SisyphusTheme.textPrimary)

            Text(title)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(SisyphusTheme.textSecondary)

            if let date = date {
                Text(date)
                    .font(.system(size: 10))
                    .foregroundColor(SisyphusTheme.textTertiary)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    ScrollView {
        PersonalRecordsView(records: [
            PersonalRecord(
                exerciseId: "1",
                exerciseName: "Bench Press",
                bestWeight: 100,
                bestWeightDate: Date(),
                bestVolume: 1200,
                bestVolumeDate: Date(),
                bestReps: 15,
                bestRepsDate: Date()
            ),
            PersonalRecord(
                exerciseId: "2",
                exerciseName: "Squat",
                bestWeight: 140,
                bestWeightDate: Date(),
                bestVolume: 2100,
                bestVolumeDate: Date(),
                bestReps: 12,
                bestRepsDate: Date()
            ),
        ])
        .padding()
    }
    .background(SisyphusTheme.background)
}
