import SwiftUI

struct EditRemindersView: View {
    @EnvironmentObject var userManager: UserManager
    @Environment(\.presentationMode) var presentationMode
    @State private var editingReminder: Reminder?
    @State private var showingAddReminder = false
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.backgroundColor
                    .ignoresSafeArea()
                
                if userManager.reminders.isEmpty {
                    emptyStateView
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(userManager.reminders) { reminder in
                                ReminderEditCard(
                                    reminder: reminder,
                                    onEdit: {
                                        editingReminder = reminder
                                    },
                                    onDelete: {
                                        userManager.deleteReminder(reminder)
                                    }
                                )
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Edit Reminders")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(AppTheme.primaryColor)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddReminder = true
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(AppTheme.primaryColor)
                    }
                }
            }
            .sheet(isPresented: $showingAddReminder) {
                AddEditReminderView(reminder: nil) { reminder in
                    userManager.addReminder(reminder)
                }
            }
            .sheet(item: $editingReminder) { reminder in
                AddEditReminderView(reminder: reminder) { updatedReminder in
                    userManager.updateReminder(updatedReminder)
                    editingReminder = nil
                }
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "bell.slash")
                .font(.system(size: 60))
                .foregroundColor(AppTheme.textSecondaryColor.opacity(0.5))
            
            Text("No Reminders")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(AppTheme.textPrimaryColor)
            
            Text("Tap the + button to add your first reminder")
                .font(.subheadline)
                .foregroundColor(AppTheme.textSecondaryColor)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

struct ReminderEditCard: View {
    let reminder: Reminder
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 15) {
            ZStack {
                Circle()
                    .fill(reminder.color.opacity(0.15))
                    .frame(width: 50, height: 50)
                
                Image(systemName: reminder.icon)
                    .font(.system(size: 22))
                    .foregroundColor(reminder.color)
            }
            
            Text(reminder.text)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(AppTheme.textPrimaryColor)
            
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
            RoundedRectangle(cornerRadius: 12)
                .fill(AppTheme.cardBackgroundColor)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
    }
}

struct AddEditReminderView: View {
    @Environment(\.presentationMode) var presentationMode
    let reminder: Reminder?
    let onSave: (Reminder) -> Void
    
    @State private var text: String = ""
    @State private var selectedIcon: String = "bell.fill"
    @State private var selectedColorHex: String = "5E60CE"
    
    let availableIcons = [
        "bell.fill", "drop.fill", "flame.fill", "heart.fill", "moon.zzz.fill",
        "tortoise.fill", "wineglass", "cube.transparent.fill", "figure.walk",
        "dumbbell.fill", "bolt.fill", "star.fill", "leaf.fill", "sun.max.fill"
    ]
    
    let availableColors: [(name: String, hex: String)] = [
        ("Purple", "5E60CE"),
        ("Cyan", "64DFDF"),
        ("Red", "FF5A5F"),
        ("Orange", "FF8C42"),
        ("Pink", "B5179E"),
        ("Blue", "4EA8DE"),
        ("Green", "38EF7D"),
        ("Yellow", "FFD93D")
    ]
    
    var isValid: Bool {
        !text.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Reminder Text")) {
                    TextField("Enter reminder text", text: $text)
                        .onChange(of: text) { _, newValue in
                            if newValue.count > 100 {
                                text = String(newValue.prefix(100))
                            }
                        }
                }
                
                Section(header: Text("Icon")) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(availableIcons, id: \.self) { icon in
                                Button(action: {
                                    selectedIcon = icon
                                }) {
                                    ZStack {
                                        Circle()
                                            .fill(selectedIcon == icon ? Color(hex: selectedColorHex).opacity(0.2) : Color.gray.opacity(0.1))
                                            .frame(width: 50, height: 50)
                                        
                                        Image(systemName: icon)
                                            .font(.system(size: 22))
                                            .foregroundColor(selectedIcon == icon ? Color(hex: selectedColorHex) : AppTheme.textSecondaryColor)
                                    }
                                }
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
                
                Section(header: Text("Color")) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(availableColors, id: \.hex) { color in
                                Button(action: {
                                    selectedColorHex = color.hex
                                }) {
                                    ZStack {
                                        Circle()
                                            .fill(Color(hex: color.hex))
                                            .frame(width: 50, height: 50)
                                        
                                        if selectedColorHex == color.hex {
                                            Image(systemName: "checkmark")
                                                .foregroundColor(.white)
                                                .font(.system(size: 18, weight: .bold))
                                        }
                                    }
                                    .overlay(
                                        Circle()
                                            .stroke(selectedColorHex == color.hex ? Color.primary : Color.clear, lineWidth: 3)
                                    )
                                }
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
            .navigationTitle(reminder == nil ? "Add Reminder" : "Edit Reminder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveReminder()
                    }
                    .fontWeight(.semibold)
                    .disabled(!isValid)
                }
            }
            .onAppear {
                if let reminder = reminder {
                    text = reminder.text
                    selectedIcon = reminder.icon
                    selectedColorHex = reminder.colorHex
                }
            }
        }
    }
    
    private func saveReminder() {
        let reminderToSave = Reminder(
            id: reminder?.id ?? UUID(),
            text: text.trimmingCharacters(in: .whitespaces),
            icon: selectedIcon,
            colorHex: selectedColorHex
        )
        onSave(reminderToSave)
        presentationMode.wrappedValue.dismiss()
    }
}

#if DEBUG
struct EditRemindersView_Previews: PreviewProvider {
    static var previews: some View {
        EditRemindersView()
            .environmentObject(UserManager())
    }
}
#endif

