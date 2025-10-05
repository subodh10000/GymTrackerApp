//
//  EditWorkoutView.swift
//  GymTrackerApp
//
//  Created by Subodh Kathayat on 5/19/25.
//


import SwiftUI

struct EditWorkoutView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var userManager: UserManager

    var workoutIndex: Int
    @State private var editableWorkout: Workout

    init(workoutIndex: Int, userManager: UserManager) {
        self.workoutIndex = workoutIndex
        // Initialize the state with the workout from the userManager
        _editableWorkout = State(initialValue: userManager.workouts[workoutIndex])
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Workout Details")) {
                    TextField("Workout Focus", text: $editableWorkout.focus)
                }

                Section(header: Text("Exercises")) {
                    ForEach($editableWorkout.exercises) { $exercise in
                        VStack(alignment: .leading, spacing: 10) {
                            Text(exercise.name).font(.headline)
                            HStack {
                                Text("Sets:")
                                TextField("Sets", text: $exercise.sets)
                                    .keyboardType(.numberPad)
                            }
                            HStack {
                                Text("Reps:")
                                TextField("Reps", text: $exercise.reps)
                            }
                            HStack {
                                Text("Rest:")
                                TextField("Rest Time", text: $exercise.restTime)
                            }
                        }
                        .padding(.vertical, 5)
                    }
                    .onDelete(perform: deleteExercise)
                }
            }
            .navigationTitle("Edit Workout")
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    userManager.updateWorkout(at: workoutIndex, with: editableWorkout)
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }

    private func deleteExercise(at offsets: IndexSet) {
        editableWorkout.exercises.remove(atOffsets: offsets)
    }
}
