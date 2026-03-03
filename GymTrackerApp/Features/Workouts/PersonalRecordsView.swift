//
//  PersonalRecordsView.swift
//  GymTrackerApp
//
//  Created by Subodh Kathayat on 10/15/25.
//


// PersonalRecordsView.swift

import SwiftUI

struct PersonalRecordsView: View {
    @EnvironmentObject var userManager: UserManager
    @State private var showingEditSheet = false

    // Define the grid layout
    private let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 15),
        GridItem(.flexible(), spacing: 15)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("Personal Records")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(AppTheme.textPrimaryColor)
                Spacer()
                Button("Edit") {
                    showingEditSheet = true
                }
                .foregroundColor(AppTheme.primaryColor)
            }

            LazyVGrid(columns: columns, spacing: 15) {
                ForEach(userManager.personalRecords) { record in
                    RecordCardView(record: record)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(AppTheme.cardBackgroundColor)
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
        )
        .sheet(isPresented: $showingEditSheet) {
            EditRecordsSheetView()
        }
    }
}

// MARK: - Reusable Card View
struct RecordCardView: View {
    let record: PersonalRecord

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: record.iconName)
                .font(.title2)
                .foregroundColor(AppTheme.primaryColor)
                .frame(width: 40, height: 40)
                .background(AppTheme.primaryColor.opacity(0.1))
                .cornerRadius(10)

            Text(record.exerciseName)
                .font(.headline)
                .foregroundColor(AppTheme.textPrimaryColor)

            Text(record.recordDetail)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(AppTheme.textPrimaryColor)

            Text(record.date, style: .date)
                .font(.caption)
                .foregroundColor(AppTheme.textSecondaryColor)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(AppTheme.cardBackgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(AppTheme.textSecondaryColor.opacity(0.12), lineWidth: 1)
                )
        )
    }
}


// MARK: - Edit Sheet Views
struct EditRecordsSheetView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var userManager: UserManager
    @State private var editingRecord: PersonalRecord?
    @State private var showingAddRecord = false
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.backgroundColor
                    .ignoresSafeArea()
                
                if userManager.personalRecords.isEmpty {
                    emptyStateView
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(userManager.personalRecords) { record in
                                RecordEditCard(
                                    record: record,
                                    onEdit: { editingRecord = record },
                                    onDelete: { delete(record) }
                                )
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Edit Records")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(AppTheme.primaryColor)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddRecord = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(AppTheme.primaryColor)
                    }
                }
            }
            .sheet(isPresented: $showingAddRecord) {
                AddEditRecordView(record: nil) { newRecord in
                    userManager.addRecord(newRecord)
                }
            }
            .sheet(item: $editingRecord) { record in
                AddEditRecordView(record: record) { updatedRecord in
                    userManager.updateRecord(updatedRecord)
                    editingRecord = nil
                }
            }
        }
    }
    
    private func delete(_ record: PersonalRecord) {
        userManager.deleteRecord(record)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "chart.bar.doc.horizontal")
                .font(.system(size: 60))
                .foregroundColor(AppTheme.textSecondaryColor.opacity(0.5))
            
            Text("No Personal Records")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(AppTheme.textPrimaryColor)
            
            Text("Tap the + button to add your first personal record.")
                .font(.subheadline)
                .foregroundColor(AppTheme.textSecondaryColor)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding()
    }
}

struct RecordEditCard: View {
    let record: PersonalRecord
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(AppTheme.primaryColor.opacity(0.12))
                    .frame(width: 50, height: 50)
                
                Image(systemName: record.iconName)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(AppTheme.primaryColor)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(record.exerciseName)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimaryColor)
                Text(record.recordDetail)
                    .font(.subheadline)
                    .foregroundColor(AppTheme.textSecondaryColor)
                Text(record.date, style: .date)
                    .font(.caption)
                    .foregroundColor(AppTheme.textSecondaryColor.opacity(0.8))
            }
            
            Spacer()
            
            HStack(spacing: 12) {
                Button(action: onEdit) {
                    Image(systemName: "pencil")
                        .foregroundColor(AppTheme.primaryColor)
                        .font(.system(size: 18))
                }
                
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                        .font(.system(size: 18))
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(AppTheme.cardBackgroundColor)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
    }
}

// MARK: - Add/Edit Form
struct AddEditRecordView: View {
    @Environment(\.presentationMode) var presentationMode
    let record: PersonalRecord?
    let onSave: (PersonalRecord) -> Void
    
    @State private var exerciseName: String = ""
    @State private var recordDetail: String = ""
    @State private var date: Date = Date()
    @State private var iconName: String = "figure.strengthtraining.traditional"
    
    private let icons = [
        "figure.strengthtraining.traditional",
        "flame.fill",
        "bolt.fill",
        "target",
        "stopwatch.fill",
        "figure.walk",
        "dumbbell.fill",
        "medal.fill"
    ]
    
    private var isValid: Bool {
        !exerciseName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !recordDetail.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.backgroundColor
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        inputField(
                            title: "Exercise Name",
                            text: $exerciseName,
                            placeholder: "e.g., Bench Press",
                            icon: "dumbbell.fill"
                        )
                        
                        inputField(
                            title: "Record Detail",
                            text: $recordDetail,
                            placeholder: "e.g., 225 lbs x 5 reps",
                            icon: "star.fill"
                        )
                        
                        datePickerField
                        iconSelectionField
                    }
                    .padding()
                }
            }
            .navigationTitle(record == nil ? "Add Record" : "Edit Record")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(AppTheme.primaryColor)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveRecord()
                    }
                    .fontWeight(.semibold)
                    .disabled(!isValid)
                }
            }
            .onAppear {
                if let record = record {
                    exerciseName = record.exerciseName
                    recordDetail = record.recordDetail
                    date = record.date
                    iconName = record.iconName
                }
            }
        }
    }
    
    private func inputField(
        title: String,
        text: Binding<String>,
        placeholder: String,
        icon: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(AppTheme.textSecondaryColor)
            
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(AppTheme.primaryColor)
                TextField(placeholder, text: text)
                    .textInputAutocapitalization(.words)
            }
            .padding()
            .background(AppTheme.cardBackgroundColor)
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(AppTheme.textSecondaryColor.opacity(0.2), lineWidth: 1)
            )
        }
    }
    
    private var datePickerField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Date")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(AppTheme.textSecondaryColor)
            
            DatePicker("", selection: $date, displayedComponents: .date)
                .datePickerStyle(.graphical)
                .accentColor(AppTheme.primaryColor)
                .background(
                    RoundedRectangle(cornerRadius: 18)
                        .fill(AppTheme.cardBackgroundColor)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(AppTheme.textSecondaryColor.opacity(0.2), lineWidth: 1)
                )
        }
    }
    
    private var iconSelectionField: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Icon")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(AppTheme.textSecondaryColor)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(icons, id: \.self) { icon in
                        Button {
                            iconName = icon
                        } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(iconName == icon ? AppTheme.primaryColor.opacity(0.2) : AppTheme.textSecondaryColor.opacity(0.08))
                                    .frame(width: 60, height: 60)
                                
                                Image(systemName: icon)
                                    .font(.system(size: 24))
                                    .foregroundColor(iconName == icon ? AppTheme.primaryColor : AppTheme.textSecondaryColor)
                            }
                        }
                    }
                }
                .padding(.vertical, 6)
            }
        }
    }
    
    private func saveRecord() {
        let recordToSave = PersonalRecord(
            id: record?.id ?? UUID(),
            exerciseName: exerciseName.trimmingCharacters(in: .whitespaces),
            recordDetail: recordDetail.trimmingCharacters(in: .whitespaces),
            date: date,
            iconName: iconName
        )
        onSave(recordToSave)
        presentationMode.wrappedValue.dismiss()
    }
}
