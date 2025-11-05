//
//  TagsManagementView.swift
//  AURZA
//

import SwiftUI

struct TagsManagementView: View {
    @EnvironmentObject var localStore: LocalStore
    @State private var showingAddTag = false
    @State private var tagToEdit: Tag?
    
    var body: some View {
        List {
            ForEach(localStore.tags) { tag in
                HStack {
                    Circle()
                        .fill(Color(rgbaColor: tag.color))
                        .frame(width: 24, height: 24)

                    Text(tag.name)
                    
                    Spacer()
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    tagToEdit = tag
                    showingAddTag = true
                }
            }
            .onDelete { indices in
                for index in indices {
                    localStore.deleteTag(localStore.tags[index])
                }
            }
            
            Button(action: {
                tagToEdit = nil
                showingAddTag = true
            }) {
                Label(NSLocalizedString("add_tag", comment: ""), systemImage: "plus.circle")
            }
        }
        .navigationTitle(NSLocalizedString("manage_tags", comment: ""))
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingAddTag) {
            TagFormView(tag: tagToEdit) { newTag in
                if tagToEdit != nil {
                    localStore.updateTag(newTag)
                } else {
                    localStore.addTag(newTag)
                }
                tagToEdit = nil
            }
        }
    }
}

struct TagFormView: View {
    let tag: Tag?
    let onSave: (Tag) -> Void
    
    @State private var name = ""
    @State private var color = Color.blue
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                TextField(NSLocalizedString("tag_name", comment: ""), text: $name)
                
                ColorPicker(NSLocalizedString("tag_color", comment: ""), selection: $color)
            }
            .navigationTitle(tag != nil ? NSLocalizedString("edit_tag", comment: "") : NSLocalizedString("new_tag", comment: ""))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(NSLocalizedString("cancel", comment: "")) {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(NSLocalizedString("save", comment: "")) {
                        let newTag = Tag(
                            id: tag?.id ?? UUID(),
                            name: name,
                            color: color.rgbaColor
                        )
                        onSave(newTag)
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
        .onAppear {
            if let tag = tag {
                name = tag.name
                color = Color(rgbaColor: tag.color)
            }
        }
    }
}
