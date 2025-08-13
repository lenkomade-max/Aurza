//
//  DiaryView.swift
//  AURZA
//

import SwiftUI

struct DiaryView: View {
    @EnvironmentObject var localStore: LocalStore
    @EnvironmentObject var viewModel: MiniHubViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Diary streak
                HStack {
                    Image(systemName: "flame.fill")
                        .font(.title2)
                        .foregroundColor(.orange)
                    
                    Text("\(viewModel.diaryStreak) " + NSLocalizedString("day_streak", comment: ""))
                        .font(.headline)
                    
                    Spacer()
                    
                    if localStore.settings.dailyQuestionEnabled {
                        Text(viewModel.getDailyQuestion())
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .italic()
                            .lineLimit(1)
                    }
                }
                .padding()
                .background(Color(UIColor.secondarySystemGroupedBackground))
                .cornerRadius(12)
                .padding(.horizontal)
                
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    TextField(NSLocalizedString("search_diary", comment: ""), text: $viewModel.searchText)
                }
                .padding(10)
                .background(Color(UIColor.secondarySystemGroupedBackground))
                .cornerRadius(10)
                .padding(.horizontal)
                
                // Calendar picker
                DatePicker(
                    NSLocalizedString("select_date", comment: ""),
                    selection: $viewModel.selectedDate,
                    displayedComponents: .date
                )
                .datePickerStyle(GraphicalDatePickerStyle())
                .padding(.horizontal)
                
                // Journal entries
                if viewModel.journalEntries.isEmpty {
                    EmptyStateView(
                        icon: "book.closed",
                        title: NSLocalizedString("no_entries_title", comment: ""),
                        description: NSLocalizedString("no_entries_description", comment: ""),
                        actionTitle: NSLocalizedString("write_entry", comment: ""),
                        action: { viewModel.showingEntryForm = true }
                    )
                    .frame(height: 300)
                } else {
                    ForEach(viewModel.journalEntries) { entry in
                        JournalEntryCard(entry: entry) {
                            viewModel.entryToEdit = entry
                            viewModel.showingEntryForm = true
                        }
                        .padding(.horizontal)
                        .contextMenu {
                            Button(action: {
                                viewModel.entryToEdit = entry
                                viewModel.showingEntryForm = true
                            }) {
                                Label(NSLocalizedString("edit", comment: ""), systemImage: "pencil")
                            }
                            
                            Button(action: {
                                viewModel.deleteJournalEntry(entry)
                            }) {
                                Label(NSLocalizedString("delete", comment: ""), systemImage: "trash")
                            }
                        }
                    }
                }
            }
            .padding(.vertical)
        }
    }
}
