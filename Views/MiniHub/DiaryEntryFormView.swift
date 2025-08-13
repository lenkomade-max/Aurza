//
//  DiaryEntryFormView.swift
//  AURZA
//

import SwiftUI
import PhotosUI

struct DiaryEntryFormView: View {
    let entry: JournalEntry?
    let selectedDate: Date
    let onSave: (JournalEntry) -> Void
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var localStore: LocalStore
    
    @State private var date: Date
    @State private var moodType = 0 // 0: emoji, 1: scale
    @State private var moodEmoji = "😊"
    @State private var moodScale = 3
    @State private var text = ""
    @State private var selectedTags: Set<Tag> = []
    @State private var photoItems: [PhotosPickerItem] = []
    @State private var photoURLs: [URL] = []
    @State private var audioURLs: [URL] = []
    @State private var isPinned = false
    @State private var dailyAnswer = ""
    @State private var showingPhotoPicker = false
    @State private var isRecording = false
    
    init(entry: JournalEntry?, selectedDate: Date, onSave: @escaping (JournalEntry) -> Void) {
        self.entry = entry
        self.selectedDate = selectedDate
        self.onSave = onSave
        self._date = State(initialValue: entry?.date ?? selectedDate)
    }
    
    var dailyQuestion: String? {
        guard localStore.settings.dailyQuestionEnabled else { return nil }
        let questions = [
            NSLocalizedString("daily_question_1", comment: ""),
            NSLocalizedString("daily_question_2", comment: ""),
            NSLocalizedString("daily_question_3", comment: ""),
            NSLocalizedString("daily_question_4", comment: ""),
            NSLocalizedString("daily_question_5", comment: ""),
            NSLocalizedString("daily_question_6", comment: ""),
            NSLocalizedString("daily_question_7", comment: ""),
            NSLocalizedString("daily_question_8", comment: ""),
            NSLocalizedString("daily_question_9", comment: ""),
            NSLocalizedString("daily_question_10", comment: "")
        ]
        
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: date) ?? 1
        return questions[dayOfYear % questions.count]
    }
    
    let moodEmojis = ["😢", "😕", "😐", "🙂", "😄", "😍", "😎", "🤔", "😴", "🤗"]
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    DatePicker(NSLocalizedString("date", comment: ""), selection: $date, displayedComponents: .date)
                    
                    Toggle(NSLocalizedString("pin_entry", comment: ""), isOn: $isPinned)
                }
                
                Section(header: Text(NSLocalizedString("mood", comment: ""))) {
                    Picker("", selection: $moodType) {
                        Text(NSLocalizedString("emoji", comment: "")).tag(0)
                        Text(NSLocalizedString("scale", comment: "")).tag(1)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    if moodType == 0 {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(moodEmojis, id: \.self) { emoji in
                                    Text(emoji)
                                        .font(.title)
                                        .frame(width: 50, height: 50)
                                        .background(moodEmoji == emoji ? Color.accentColor.opacity(0.2) : Color.gray.opacity(0.1))
                                        .cornerRadius(10)
                                        .onTapGesture {
                                            moodEmoji = emoji
                                        }
                                }
                            }
                        }
                    } else {
                        HStack {
                            ForEach(1...5, id: \.self) { value in
                                Button(action: { moodScale = value }) {
                                    VStack {
                                        Text(["😢", "😕", "😐", "🙂", "😄"][value - 1])
                                            .font(.title2)
                                        Text("\(value)")
                                            .font(.caption)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                                    .background(moodScale == value ? Color.accentColor.opacity(0.2) : Color.gray.opacity(0.1))
                                    .cornerRadius(8)
                                }
                            }
                        }
                    }
                }
                
                if let question = dailyQuestion {
                    Section(header: Text(NSLocalizedString("daily_question", comment: ""))) {
                        Text(question)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .italic()
                        
                        TextField(NSLocalizedString("your_answer", comment: ""), text: $dailyAnswer, axis: .vertical)
                            .lineLimit(3...6)
                    }
                }
                
                Section(header: Text(NSLocalizedString("entry", comment: ""))) {
                    TextEditor(text: $text)
                        .frame(minHeight: 150)
                }
                
                Section(header: Text(NSLocalizedString("attachments", comment: ""))) {
                    HStack {
                        Button(action: { showingPhotoPicker = true }) {
                            Label(NSLocalizedString("add_photos", comment: ""), systemImage: "photo")
                        }
                        
                        Spacer()
                        
                        Button(action: { toggleRecording() }) {
                            Label(
                                isRecording ? NSLocalizedString("stop_recording", comment: "") : NSLocalizedString("record_audio", comment: ""),
                                systemImage: isRecording ? "stop.circle.fill" : "mic.circle"
                            )
                            .foregroundColor(isRecording ? .red : .accentColor)
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
                    
                    if !audioURLs.isEmpty {
                        VStack(alignment: .leading) {
                            ForEach(audioURLs, id: \.self) { url in
                                HStack {
                                    Image(systemName: "waveform")
                                    Text(url.lastPathComponent)
                                        .font(.caption)
                                    Spacer()
                                }
                            }
                        }
                    }
                }
                
                Section(header: Text(NSLocalizedString("tags", comment: ""))) {
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
            .navigationTitle(entry != nil ? NSLocalizedString("edit_entry", comment: "") : NSLocalizedString("new_entry", comment: ""))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(NSLocalizedString("cancel", comment: "")) {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(NSLocalizedString("save", comment: "")) {
                        saveEntry()
                    }
                    .disabled(text.isEmpty)
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
            if let entry = entry {
                date = entry.date
                switch entry.mood {
                case .emoji(let emoji):
                    moodType = 0
                    moodEmoji = emoji
                case .scale(let value):
                    moodType = 1
                    moodScale = value
                }
                text = entry.text
                selectedTags = Set(entry.tags)
                photoURLs = entry.photoURLs
                audioURLs = entry.audioURLs
                isPinned = entry.isPinned
                dailyAnswer = entry.dailyAnswer ?? ""
            }
        }
    }
    
    private func saveEntry() {
        let mood: JournalEntry.Mood = moodType == 0 ? .emoji(moodEmoji) : .scale(moodScale)
        
        let newEntry = JournalEntry(
            id: entry?.id ?? UUID(),
            date: date,
            mood: mood,
            text: text,
            tags: Array(selectedTags),
            photoURLs: photoURLs,
            audioURLs: audioURLs,
            isPinned: isPinned,
            dailyQuestion: dailyQuestion,
            dailyAnswer: dailyAnswer.isEmpty ? nil : dailyAnswer,
            createdAt: entry?.createdAt ?? Date(),
            updatedAt: Date()
        )
        
        onSave(newEntry)
        dismiss()
    }
    
    private func toggleRecording() {
        // Simplified audio recording toggle
        isRecording.toggle()
        if !isRecording {
            // Save audio URL (placeholder)
            let url = URL(fileURLWithPath: "audio_\(Date().timeIntervalSince1970).m4a")
            audioURLs.append(url)
        }
    }
}
