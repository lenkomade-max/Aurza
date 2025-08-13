//
//  NoteFormView.swift
//  AURZA
//

import SwiftUI
import PhotosUI

struct NoteFormView: View {
    let note: Note?
    let onSave: (Note) -> Void
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var localStore: LocalStore
    
    @State private var title = ""
    @State private var text = ""
    @State private var isChecklist = false
    @State private var checklistItems: [ChecklistItem] = []
    @State private var newChecklistItemText = ""
    @State private var selectedTags: Set<Tag> = []
    @State private var photoItems: [PhotosPickerItem] = []
    @State private var photoURLs: [URL] = []
    @State private var audioURLs: [URL] = []
    @State private var isPinned = false
    @State private var showingPhotoPicker = false
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField(NSLocalizedString("note_title", comment: ""), text: $title)
                        .font(.headline)
                    
                    Toggle(NSLocalizedString("checklist", comment: ""), isOn: $isChecklist)
                }
                
                if isChecklist {
                    Section(header: Text(NSLocalizedString("checklist_items", comment: ""))) {
                        ForEach(checklistItems) { item in
                            HStack {
                                Button(action: { toggleChecklistItem(item) }) {
                                    Image(systemName: item.isDone ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(item.isDone ? .green : .secondary)
                                }
                                
                                Text(item.text)
                                    .strikethrough(item.isDone)
                                
                                Spacer()
                            }
                        }
                        .onDelete { indices in
                            checklistItems.remove(atOffsets: indices)
                        }
                        
                        HStack {
                            TextField(NSLocalizedString("new_item", comment: ""), text: $newChecklistItemText)
                            
                            Button(action: addChecklistItem) {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(.accentColor)
                            }
                            .disabled(newChecklistItemText.isEmpty)
                        }
                    }
                } else {
                    Section(header: Text(NSLocalizedString("content", comment: ""))) {
                        TextEditor(text: $text)
                            .frame(minHeight: 150)
                    }
                }
                
                Section(header: Text(NSLocalizedString("attachments", comment: ""))) {
                    HStack {
                        Button(action: { showingPhotoPicker = true }) {
                            Label(NSLocalizedString("add_photos", comment: ""), systemImage: "photo")
                        }
                        
                        Spacer()
                        
                        Button(action: { }) {
                            Label(NSLocalizedString("record_audio", comment: ""), systemImage: "mic.circle")
                        }
                    }
                    
                    if !photoURLs.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(photoURLs, id: \.self) { url in
                                    Image(systemName: "photo")
                                        .frame(width: 60, height: 60)
                                        .background(Color.gray.opacity(0.2))
                                        .cornerRadius(8)
                                }
                            }
                        }
                    }
                }
                
                Section(header: Text(NSLocalizedString("organization", comment: ""))) {
                    Toggle(NSLocalizedString("pin_note", comment: ""), isOn: $isPinned)
                    
                    Text(NSLocalizedString("tags", comment: ""))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    FlowLayout(spacing: 8) {
                        ForEach(localStore.tags) { tag in
                            TagChipView(
                                tag: tag,
                                size: .regular,
                                isSelected: selectedTags.contains(tag),
                                onTap: {
                                    if selectedTags.contains(tag) {
                                        selectedTags.remove(tag)
                                    } else {
                                        selectedTags.insert(tag)
                                    }
                                }
                            )
                        }
                    }
                }
            }
            .navigationTitle(note != nil ? NSLocalizedString("edit_note", comment: "") : NSLocalizedString("new_note", comment: ""))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(NSLocalizedString("cancel", comment: "")) {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(NSLocalizedString("save", comment: "")) {
                        saveNote()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
        .photosPicker(
            isPresented: $showingPhotoPicker,
            selection: $photoItems,
            maxSelectionCount: 5,
            matching: .images
        )
        .onAppear {
            if let note = note {
                title = note.title
                text = note.text ?? ""
                isChecklist = note.isChecklist
                checklistItems = note.checklistItems
                selectedTags = Set(note.tags)
                photoURLs = note.photoURLs
                audioURLs = note.audioURLs
                isPinned = note.isPinned
            }
        }
    }
    
    private func toggleChecklistItem(_ item: ChecklistItem) {
        if let index = checklistItems.firstIndex(where: { $0.id == item.id }) {
            checklistItems[index].isDone.toggle()
        }
    }
    
    private func addChecklistItem() {
        let newItem = ChecklistItem(
            text: newChecklistItemText,
            order: checklistItems.count
        )
        checklistItems.append(newItem)
        newChecklistItemText = ""
    }
    
    private func saveNote() {
        let newNote = Note(
            id: note?.id ?? UUID(),
            title: title,
            text: isChecklist ? nil : (text.isEmpty ? nil : text),
            isChecklist: isChecklist,
            checklistItems: isChecklist ? checklistItems : [],
            tags: Array(selectedTags),
            photoURLs: photoURLs,
            audioURLs: audioURLs,
            isPinned: isPinned,
            isArchived: note?.isArchived ?? false,
            createdAt: note?.createdAt ?? Date(),
            updatedAt: Date()
        )
        
        onSave(newNote)
        dismiss()
    }
}
