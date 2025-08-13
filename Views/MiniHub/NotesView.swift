//
//  NotesView.swift
//  AURZA
//

import SwiftUI

struct NotesView: View {
    @EnvironmentObject var localStore: LocalStore
    @EnvironmentObject var viewModel: MiniHubViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Search and filter bar
                HStack {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        TextField(NSLocalizedString("search_notes", comment: ""), text: $viewModel.searchText)
                    }
                    .padding(10)
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    .cornerRadius(10)
                    
                    Button(action: { viewModel.showArchivedNotes.toggle() }) {
                        Image(systemName: viewModel.showArchivedNotes ? "archivebox.fill" : "archivebox")
                            .font(.title3)
                            .foregroundColor(viewModel.showArchivedNotes ? .accentColor : .secondary)
                    }
                }
                .padding(.horizontal)
                
                // Notes list
                if viewModel.notes.isEmpty {
                    EmptyStateView(
                        icon: "note.text",
                        title: viewModel.showArchivedNotes ? NSLocalizedString("no_archived_notes_title", comment: "") : NSLocalizedString("no_notes_title", comment: ""),
                        description: viewModel.showArchivedNotes ? NSLocalizedString("no_archived_notes_description", comment: "") : NSLocalizedString("no_notes_description", comment: ""),
                        actionTitle: viewModel.showArchivedNotes ? nil : NSLocalizedString("create_note", comment: ""),
                        action: viewModel.showArchivedNotes ? nil : { viewModel.showingNoteForm = true }
                    )
                    .frame(height: 300)
                } else {
                    ForEach(viewModel.notes) { note in
                        NoteCard(note: note) {
                            viewModel.noteToEdit = note
                            viewModel.showingNoteForm = true
                        }
                        .padding(.horizontal)
                        .contextMenu {
                            Button(action: {
                                viewModel.noteToEdit = note
                                viewModel.showingNoteForm = true
                            }) {
                                Label(NSLocalizedString("edit", comment: ""), systemImage: "pencil")
                            }
                            
                            Button(action: {
                                viewModel.toggleNotePin(note)
                            }) {
                                Label(
                                    note.isPinned ? NSLocalizedString("unpin", comment: "") : NSLocalizedString("pin", comment: ""),
                                    systemImage: note.isPinned ? "pin.slash" : "pin"
                                )
                            }
                            
                            Button(action: {
                                viewModel.archiveNote(note)
                            }) {
                                Label(
                                    note.isArchived ? NSLocalizedString("unarchive", comment: "") : NSLocalizedString("archive", comment: ""),
                                    systemImage: note.isArchived ? "archivebox" : "archivebox.fill"
                                )
                            }
                        }
                    }
                }
            }
            .padding(.vertical)
        }
    }
}
