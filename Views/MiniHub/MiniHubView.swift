//
//  MiniHubView.swift
//  AURZA
//

import SwiftUI

struct MiniHubView: View {
    @EnvironmentObject var localStore: LocalStore
    @EnvironmentObject var purchaseService: PurchaseService
    
    @StateObject private var viewModel: MiniHubViewModel
    @State private var showingPaywall = false
    
    init() {
        _viewModel = StateObject(wrappedValue: MiniHubViewModel(
            localStore: LocalStore(),
            purchaseService: PurchaseService()
        ))
    }
    
    var body: some View {
        NavigationView {
            if viewModel.isProRequired {
                VStack(spacing: 20) {
                    Image(systemName: "book.closed.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.secondary)
                    
                    Text(NSLocalizedString("minihub_pro_title", comment: ""))
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text(NSLocalizedString("minihub_pro_description", comment: ""))
                        .font(.body)
                        .foregroundColor(.secondary)
                                                .multilineTextAlignment(.center)
                                                .padding(.horizontal, 40)
                                            
                                            Button(action: { showingPaywall = true }) {
                                                Text(NSLocalizedString("unlock_pro", comment: ""))
                                                    .fontWeight(.medium)
                                                    .frame(maxWidth: .infinity)
                                                    .padding()
                                                    .background(Color.accentColor)
                                                    .foregroundColor(.white)
                                                    .cornerRadius(10)
                                            }
                                            .padding(.horizontal, 40)
                                        }
                                        .navigationTitle(NSLocalizedString("mini_hub", comment: ""))
                                        .sheet(isPresented: $showingPaywall) {
                                            PaywallView(isPresented: $showingPaywall)
                                                .environmentObject(purchaseService)
                                        }
                                    } else {
                                        if viewModel.combinedView {
                                            // Combined view
                                            ScrollView {
                                                VStack(spacing: 16) {
                                                    // Search bar
                                                    HStack {
                                                        Image(systemName: "magnifyingglass")
                                                            .foregroundColor(.secondary)
                                                        TextField(NSLocalizedString("search", comment: ""), text: $viewModel.searchText)
                                                    }
                                                    .padding(10)
                                                    .background(Color(UIColor.secondarySystemGroupedBackground))
                                                    .cornerRadius(10)
                                                    .padding(.horizontal)
                                                    
                                                    // Combined content
                                                    ForEach(getCombinedContent(), id: \.id) { item in
                                                        if let entry = item as? JournalEntry {
                                                            JournalEntryCard(entry: entry) {
                                                                viewModel.entryToEdit = entry
                                                                viewModel.showingEntryForm = true
                                                            }
                                                            .padding(.horizontal)
                                                        } else if let note = item as? Note {
                                                            NoteCard(note: note) {
                                                                viewModel.noteToEdit = note
                                                                viewModel.showingNoteForm = true
                                                            }
                                                            .padding(.horizontal)
                                                        }
                                                    }
                                                }
                                                .padding(.vertical)
                                            }
                                            .navigationTitle(NSLocalizedString("mini_hub", comment: ""))
                                        } else {
                                            // Tabbed view
                                            VStack {
                                                // Tab selector
                                                Picker("", selection: $viewModel.selectedTab) {
                                                    Text(NSLocalizedString("diary", comment: "")).tag(0)
                                                    Text(NSLocalizedString("notes", comment: "")).tag(1)
                                                }
                                                .pickerStyle(SegmentedPickerStyle())
                                                .padding()
                                                
                                                if viewModel.selectedTab == 0 {
                                                    DiaryView()
                                                        .environmentObject(localStore)
                                                        .environmentObject(viewModel)
                                                } else {
                                                    NotesView()
                                                        .environmentObject(localStore)
                                                        .environmentObject(viewModel)
                                                }
                                            }
                                            .navigationTitle(NSLocalizedString("mini_hub", comment: ""))
                                        }
                                        
                                        .toolbar {
                                            ToolbarItem(placement: .navigationBarTrailing) {
                                                Button(action: {
                                                    if viewModel.selectedTab == 0 {
                                                        viewModel.showingEntryForm = true
                                                    } else {
                                                        viewModel.showingNoteForm = true
                                                    }
                                                }) {
                                                    Image(systemName: "plus.circle.fill")
                                                        .font(.title2)
                                                }
                                            }
                                        }
                                        .sheet(isPresented: $viewModel.showingEntryForm) {
                                            DiaryEntryFormView(
                                                entry: viewModel.entryToEdit,
                                                selectedDate: viewModel.selectedDate,
                                                onSave: { entry in
                                                    if viewModel.entryToEdit != nil {
                                                        viewModel.updateJournalEntry(entry)
                                                    } else {
                                                        viewModel.addJournalEntry(entry)
                                                    }
                                                    viewModel.entryToEdit = nil
                                                }
                                            )
                                            .environmentObject(localStore)
                                        }
                                        .sheet(isPresented: $viewModel.showingNoteForm) {
                                            NoteFormView(
                                                note: viewModel.noteToEdit,
                                                onSave: { note in
                                                    if viewModel.noteToEdit != nil {
                                                        viewModel.updateNote(note)
                                                    } else {
                                                        viewModel.addNote(note)
                                                    }
                                                    viewModel.noteToEdit = nil
                                                }
                                            )
                                            .environmentObject(localStore)
                                        }
                                    }
                                }
                            }
                            
                            private func getCombinedContent() -> [Any] {
                                var combined: [(item: Any, date: Date)] = []
                                
                                for entry in viewModel.journalEntries {
                                    combined.append((entry, entry.date))
                                }
                                
                                for note in viewModel.notes {
                                    combined.append((note, note.updatedAt))
                                }
                                
                                return combined
                                    .sorted { $0.date > $1.date }
                                    .map { $0.item }
                            }
                        }

                        struct JournalEntryCard: View {
                            let entry: JournalEntry
                            let onTap: () -> Void
                            
                            var body: some View {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text("📓")
                                            .font(.caption)
                                        
                                        Text(entry.date, style: .date)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        
                                        Spacer()
                                        
                                        Text(entry.mood.displayValue)
                                            .font(.title3)
                                        
                                        if entry.isPinned {
                                            Image(systemName: "pin.fill")
                                                .font(.caption)
                                                .foregroundColor(.orange)
                                        }
                                    }
                                    
                                    if let question = entry.dailyQuestion {
                                        Text(question)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                            .italic()
                                    }
                                    
                                    Text(entry.text)
                                        .font(.body)
                                        .lineLimit(3)
                                    
                                    HStack {
                                        ForEach(entry.tags.prefix(3)) { tag in
                                            TagChipView(tag: tag, size: .small)
                                        }
                                        
                                        Spacer()
                                        
                                        if !entry.photoURLs.isEmpty {
                                            Image(systemName: "photo")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        
                                        if !entry.audioURLs.isEmpty {
                                            Image(systemName: "mic.fill")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                }
                                .padding()
                                .background(Color(UIColor.secondarySystemGroupedBackground))
                                .cornerRadius(12)
                                .onTapGesture {
                                    onTap()
                                }
                            }
                        }

                        struct NoteCard: View {
                            let note: Note
                            let onTap: () -> Void
                            
                            var body: some View {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text("📝")
                                            .font(.caption)
                                        
                                        Text(note.title)
                                            .font(.headline)
                                        
                                        Spacer()
                                        
                                        if note.isPinned {
                                            Image(systemName: "pin.fill")
                                                .font(.caption)
                                                .foregroundColor(.orange)
                                        }
                                        
                                        if note.isArchived {
                                            Image(systemName: "archivebox.fill")
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }
                                    }
                                    
                                    if note.isChecklist {
                                        VStack(alignment: .leading, spacing: 4) {
                                            ForEach(note.checklistItems.prefix(3)) { item in
                                                HStack(spacing: 8) {
                                                    Image(systemName: item.isDone ? "checkmark.circle.fill" : "circle")
                                                        .font(.caption)
                                                        .foregroundColor(item.isDone ? .green : .secondary)
                                                    
                                                    Text(item.text)
                                                        .font(.caption)
                                                        .strikethrough(item.isDone)
                                                }
                                            }
                                            
                                            if note.checklistItems.count > 3 {
                                                Text("+ \(note.checklistItems.count - 3) more")
                                                    .font(.caption2)
                                                    .foregroundColor(.secondary)
                                            }
                                        }
                                    } else if let text = note.text {
                                        Text(text)
                                            .font(.body)
                                            .lineLimit(3)
                                    }
                                    
                                    HStack {
                                        ForEach(note.tags.prefix(3)) { tag in
                                            TagChipView(tag: tag, size: .small)
                                        }
                                        
                                        Spacer()
                                        
                                        if note.isChecklist {
                                            Text("\(note.completedChecklistCount)/\(note.checklistItems.count)")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                }
                                .padding()
                                .background(Color(UIColor.secondarySystemGroupedBackground))
                                .cornerRadius(12)
                                .onTapGesture {
                                    onTap()
                                }
                            }
                        }
