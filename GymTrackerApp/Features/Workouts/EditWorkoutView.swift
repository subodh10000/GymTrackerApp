//
//  EditWorkoutView.swift
//  GymTrackerApp
//
//  Enhanced workout customization with full exercise editing

import SwiftUI

struct EditWorkoutView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var userManager: UserManager

    var workoutIndex: Int
    @State private var editableWorkout: Workout
    @State private var showingAddExercise = false
    @State private var editingExerciseIndex: ExerciseIndex?
    
    // Get workout from userManager when view appears
    private var currentWorkout: Workout? {
        guard workoutIndex < userManager.workouts.count else { return nil }
        return userManager.workouts[workoutIndex]
    }

    init(workoutIndex: Int) {
        self.workoutIndex = workoutIndex
        // Initialize with placeholder - will be set in onAppear
        _editableWorkout = State(initialValue: Workout(id: UUID(), day: "", focus: "", exercises: []))
    }

    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.backgroundColor
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Workout Details Section
                        workoutDetailsSection
                        
                        // Exercises Section
                        exercisesSection
                    }
                    .padding()
                }
            }
            .navigationTitle("Customize Workout")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(AppTheme.textPrimaryColor),
                trailing: Button("Save") {
                    saveWorkout()
                }
                .fontWeight(.semibold)
                .foregroundColor(AppTheme.primaryColor)
                .disabled(!canSaveWorkout)
            )
            .sheet(isPresented: $showingAddExercise) {
                AddEditExerciseView(
                    exercise: nil,
                    onSave: { exercise in
                        // Limit to 12 exercises per workout
                        if editableWorkout.exercises.count < 12 {
                            editableWorkout.exercises.append(exercise)
                        }
                    }
                )
            }
            .sheet(item: $editingExerciseIndex) { exerciseIndex in
                AddEditExerciseView(
                    exercise: editableWorkout.exercises[exerciseIndex.value],
                    onSave: { exercise in
                        editableWorkout.exercises[exerciseIndex.value] = exercise
                        editingExerciseIndex = nil
                    }
                )
            }
            .onAppear {
                // Load current workout when view appears
                if let workout = currentWorkout {
                    editableWorkout = workout
                }
            }
        }
    }
    
    private var workoutDetailsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(AppTheme.primaryColor)
                    .font(.title3)
                Text("Workout Details")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(AppTheme.textPrimaryColor)
            }
            
            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Day")
                        .font(.headline)
                        .foregroundColor(AppTheme.textSecondaryColor)
                    TextField("e.g., Monday, Push Day", text: $editableWorkout.day)
                        .textFieldStyle(CustomTextFieldStyle())
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Focus")
                        .font(.headline)
                        .foregroundColor(AppTheme.textSecondaryColor)
                    TextField("e.g., Chest & Triceps", text: $editableWorkout.focus)
                        .textFieldStyle(CustomTextFieldStyle())
                }
            }
            .padding()
            .background(AppTheme.cardBackgroundColor)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
        }
    }
    
    private var exercisesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "dumbbell.fill")
                    .foregroundColor(AppTheme.primaryColor)
                    .font(.title3)
                Text("Exercises")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(AppTheme.textPrimaryColor)
                
                Spacer()
                
                Button(action: {
                    showingAddExercise = true
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "plus.circle.fill")
                        Text("Add Exercise")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        LinearGradient(
                            colors: editableWorkout.exercises.count >= 12 
                                ? [Color.gray, Color.gray.opacity(0.8)]
                                : [AppTheme.primaryColor, AppTheme.secondaryColor],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
                }
                .disabled(editableWorkout.exercises.count >= 12)
                
                if editableWorkout.exercises.count >= 12 {
                    Text("Maximum 12 exercises per workout")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            }
            
            if editableWorkout.exercises.isEmpty {
                emptyExercisesView
            } else {
                ForEach(Array(editableWorkout.exercises.enumerated()), id: \.element.id) { index, exercise in
                    ExerciseEditCard(
                        exercise: exercise,
                        index: index,
                        onEdit: {
                            editingExerciseIndex = ExerciseIndex(value: index)
                        },
                        onDelete: {
                            editableWorkout.exercises.remove(at: index)
                        },
                        onMoveUp: index > 0 ? {
                            editableWorkout.exercises.swapAt(index, index - 1)
                        } : nil,
                        onMoveDown: index < editableWorkout.exercises.count - 1 ? {
                            editableWorkout.exercises.swapAt(index, index + 1)
                        } : nil
                    )
                }
            }
        }
    }
    
    private var emptyExercisesView: some View {
        VStack(spacing: 16) {
            Image(systemName: "dumbbell")
                .font(.system(size: 50))
                .foregroundColor(AppTheme.textSecondaryColor.opacity(0.5))
            
            Text("No exercises yet")
                .font(.headline)
                .foregroundColor(AppTheme.textSecondaryColor)
            
            Text("Tap 'Add Exercise' to create your first exercise")
                .font(.subheadline)
                .foregroundColor(AppTheme.textSecondaryColor)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(AppTheme.cardBackgroundColor)
        .cornerRadius(16)
    }
    
    // Validation for saving workout
    private var canSaveWorkout: Bool {
        !editableWorkout.day.trimmingCharacters(in: .whitespaces).isEmpty &&
        !editableWorkout.focus.trimmingCharacters(in: .whitespaces).isEmpty &&
        !editableWorkout.exercises.isEmpty &&
        editableWorkout.exercises.count <= 12
    }
    
    private func saveWorkout() {
        // Final validation before saving
        guard canSaveWorkout else { return }
        
        // Ensure all exercises have valid sets (max 6)
        for index in editableWorkout.exercises.indices {
            if let setsNum = Int(editableWorkout.exercises[index].sets), setsNum > 6 {
                editableWorkout.exercises[index].sets = "6"
            }
        }
        
        userManager.updateWorkout(at: workoutIndex, with: editableWorkout)
        presentationMode.wrappedValue.dismiss()
    }
}

// MARK: - Exercise Edit Card
struct ExerciseEditCard: View {
    let exercise: Exercise
    let index: Int
    let onEdit: () -> Void
    let onDelete: () -> Void
    let onMoveUp: (() -> Void)?
    let onMoveDown: (() -> Void)?
    
    var body: some View {
        HStack(spacing: 12) {
            // Exercise number
            ZStack {
                Circle()
                    .fill(AppTheme.primaryColor.opacity(0.1))
                    .frame(width: 36, height: 36)
                Text("\(index + 1)")
                    .font(.headline)
                    .foregroundColor(AppTheme.primaryColor)
            }
            
            // Exercise info
            VStack(alignment: .leading, spacing: 6) {
                Text(exercise.name)
                    .font(.headline)
                    .foregroundColor(AppTheme.textPrimaryColor)
                
                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Image(systemName: "repeat")
                            .font(.system(size: 10))
                        Text("\(exercise.sets) sets")
                    }
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 10))
                        Text("\(exercise.reps)")
                    }
                    HStack(spacing: 4) {
                        Image(systemName: "timer")
                            .font(.system(size: 10))
                        Text(exercise.restTime)
                    }
                }
                .font(.caption)
                .foregroundColor(AppTheme.textSecondaryColor)
            }
            
            Spacer()
            
            // Action buttons
            HStack(spacing: 8) {
                if let onMoveUp = onMoveUp {
                    Button(action: onMoveUp) {
                        Image(systemName: "arrow.up")
                            .foregroundColor(AppTheme.textSecondaryColor)
                    }
                }
                
                if let onMoveDown = onMoveDown {
                    Button(action: onMoveDown) {
                        Image(systemName: "arrow.down")
                            .foregroundColor(AppTheme.textSecondaryColor)
                    }
                }
                
                Button(action: onEdit) {
                    Image(systemName: "pencil")
                        .foregroundColor(AppTheme.primaryColor)
                }
                
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
            }
        }
        .padding()
        .background(AppTheme.cardBackgroundColor)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Add/Edit Exercise View
struct AddEditExerciseView: View {
    @Environment(\.presentationMode) var presentationMode
    let exercise: Exercise?
    let onSave: (Exercise) -> Void
    
    @State private var name: String = ""
    @State private var sets: String = "3"
    @State private var reps: String = "10"
    @State private var restTime: String = "60s"
    @State private var description: String = ""
    @State private var category: ExerciseCategory = .strength
    @State private var difficulty: ExerciseDifficulty = .intermediate
    @State private var equipment: String = ""
    
    // Validation
    private var isValidExercise: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !sets.trimmingCharacters(in: .whitespaces).isEmpty &&
        !reps.trimmingCharacters(in: .whitespaces).isEmpty &&
        !restTime.trimmingCharacters(in: .whitespaces).isEmpty &&
        (Int(sets) ?? 0) >= 1 && (Int(sets) ?? 0) <= 6 &&
        (Int(reps.replacingOccurrences(of: "-", with: "").components(separatedBy: CharacterSet.decimalDigits.inverted).joined()) ?? 0) >= 1
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Basic Information")) {
                    TextField("Exercise Name", text: $name)
                        .onChange(of: name) { _, newValue in
                            // Limit exercise name to 50 characters
                            if newValue.count > 50 {
                                name = String(newValue.prefix(50))
                            }
                        }
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                        .onChange(of: description) { _, newValue in
                            // Limit description to 200 characters
                            if newValue.count > 200 {
                                description = String(newValue.prefix(200))
                            }
                        }
                }
                
                Section(header: Text("Workout Details")) {
                    HStack {
                        Text("Sets")
                        Spacer()
                        TextField("Sets", text: $sets)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .onChange(of: sets) { _, newValue in
                                // Limit sets to 1-6
                                if let num = Int(newValue), num > 6 {
                                    sets = "6"
                                } else if let num = Int(newValue), num < 1, !newValue.isEmpty {
                                    sets = "1"
                                }
                            }
                        Text("(Max: 6)")
                            .font(.caption)
                            .foregroundColor(AppTheme.textSecondaryColor)
                    }
                    
                    HStack {
                        Text("Reps")
                        Spacer()
                        TextField("Reps", text: $reps)
                            .multilineTextAlignment(.trailing)
                            .onChange(of: reps) { _, newValue in
                                // Limit reps to reasonable range (1-100)
                                if let num = Int(newValue), num > 100 {
                                    reps = "100"
                                } else if let num = Int(newValue), num < 1, !newValue.isEmpty {
                                    reps = "1"
                                }
                            }
                    }
                    
                    HStack {
                        Text("Rest Time")
                        Spacer()
                        TextField("e.g., 60s", text: $restTime)
                            .multilineTextAlignment(.trailing)
                            .onChange(of: restTime) { _, newValue in
                                // Validate rest time format (should end with 's' or be a number)
                                if !newValue.isEmpty && !newValue.hasSuffix("s") && newValue.allSatisfy({ $0.isNumber }) {
                                    restTime = newValue + "s"
                                }
                            }
                    }
                }
                
                Section(header: Text("Exercise Properties")) {
                    Picker("Category", selection: $category) {
                        ForEach(ExerciseCategory.allCases, id: \.self) { cat in
                            Text(cat.rawValue).tag(cat)
                        }
                    }
                    
                    Picker("Difficulty", selection: $difficulty) {
                        ForEach(ExerciseDifficulty.allCases, id: \.self) { diff in
                            Text(diff.rawValue).tag(diff)
                        }
                    }
                    
                    TextField("Equipment (optional)", text: $equipment)
                        .onChange(of: equipment) { _, newValue in
                            // Limit equipment to 50 characters
                            if newValue.count > 50 {
                                equipment = String(newValue.prefix(50))
                            }
                        }
                }
            }
            .navigationTitle(exercise == nil ? "Add Exercise" : "Edit Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    saveExercise()
                }
                .fontWeight(.semibold)
                .disabled(!isValidExercise)
            )
            .onAppear {
                if let exercise = exercise {
                    name = exercise.name
                    sets = exercise.sets
                    reps = exercise.reps
                    restTime = exercise.restTime
                    description = exercise.description
                    category = exercise.category
                    difficulty = exercise.difficulty
                    equipment = exercise.equipment ?? ""
                }
            }
        }
    }
    
    private func saveExercise() {
        // Ensure sets is within limit
        let validatedSets = min(max(Int(sets) ?? 3, 1), 6)
        
        // Ensure rest time has 's' suffix
        var validatedRestTime = restTime
        if !validatedRestTime.hasSuffix("s") && validatedRestTime.allSatisfy({ $0.isNumber }) {
            validatedRestTime = validatedRestTime + "s"
        }
        
        let newExercise = Exercise(
            id: exercise?.id ?? UUID(),
            name: name.trimmingCharacters(in: .whitespaces),
            sets: String(validatedSets),
            reps: reps.trimmingCharacters(in: .whitespaces),
            restTime: validatedRestTime,
            description: description.trimmingCharacters(in: .whitespaces),
            category: category,
            equipment: equipment.isEmpty ? nil : equipment.trimmingCharacters(in: .whitespaces),
            difficulty: difficulty,
            isCompleted: exercise?.isCompleted ?? false
        )
        onSave(newExercise)
        presentationMode.wrappedValue.dismiss()
    }
}

// MARK: - Custom Text Field Style
struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(12)
            .background(AppTheme.backgroundColor)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
    }
}

// MARK: - Wrapper for Exercise Index
struct ExerciseIndex: Identifiable {
    let id = UUID()
    let value: Int
}
