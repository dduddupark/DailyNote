import SwiftUI

struct EntryEditorView: View {
    let dateId: String
    @State private var title: String
    @State private var content: String

    var onCancel: () -> Void
    var onSave: (_ title: String, _ content: String) -> Void

    @State private var showDiscardAlert = false

    let initialTitle: String
    let initialContent: String

    var isChanged: Bool {
        return title != initialTitle || content != initialContent
    }

    init(
        entry: NoteEntry,
        onCancel: @escaping () -> Void,
        onSave: @escaping (_ title: String, _ content: String) -> Void
    ) {
        self.dateId = entry.id
        self.initialTitle = entry.title
        self.initialContent = entry.content
        _title = State(initialValue: entry.title)
        _content = State(initialValue: entry.content)
        self.onCancel = onCancel
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("title_placeholder", text: $title)
                        .onChange(of: title) { newValue in
                            if newValue.count > 20 {
                                title = String(newValue.prefix(20))
                            }
                        }
                    TextField("content_placeholder", text: $content, axis: .vertical)
                        .lineLimit(5...15) // Limit max height to ensure scrolling
                        .frame(minHeight: 150) // Ensure reasonable size
                } header: {
                    Text(dateId)
                }
            }
            .navigationTitle("edit_entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("cancel") {
                        if isChanged {
                            showDiscardAlert = true
                        } else {
                            onCancel()
                        }
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("save") { onSave(title, content) }
                        .fontWeight(.semibold)
                }
            }
            .interactiveDismissDisabled(isChanged)
            .confirmationDialog("discard_changes_title", isPresented: $showDiscardAlert) {
                Button("discard_changes_button", role: .destructive) { onCancel() }
                Button("continue_editing_button", role: .cancel) { }
            } message: {
                Text("discard_changes_message")
            }
        }
    }
}
