import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()
    @State private var editingEntry: NoteEntry?
    @State private var deletingEntryId: String?
    
    var body: some View {
        ZStack {
            Color(uiColor: .systemGroupedBackground).ignoresSafeArea()
            
            VStack {
                if viewModel.isLoading {
                    ProgressView()
                } else if viewModel.filteredEntries.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)
                        Text("검색 결과가 없습니다")
                            .foregroundColor(.secondary)
                    }
                    .frame(maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.filteredEntries) { entry in
                                NoteRowView(
                                    entry: entry,
                                    showActions: false,
                                    onEdit: { editingEntry = entry },
                                    onDelete: { deletingEntryId = entry.id }
                                )
                            }
                        }
                        .padding(.vertical)
                    }
                }
            }
        }
        .navigationTitle("search")
        .searchable(text: $viewModel.query, prompt: Text("search_placeholder"))
        .onAppear {
            viewModel.load()
        }
        .sheet(item: $editingEntry) { entry in
            EntryEditorView(
                entry: entry,
                onCancel: { editingEntry = nil },
                onSave: { title, content in
                    let updated = NoteEntry(
                        id: entry.id,
                        title: title,
                        content: content,
                        updatedAt: entry.updatedAt,
                        editCount: entry.editCount,
                        emotion: entry.emotion,
                        tags: entry.tags
                    )
                    // Re-analyze on update (Optional, but consistent with Home)
                    let analysis = NoteAnalysisService.shared.analyze(text: content)
                    var finalUpdated = updated
                    finalUpdated.emotion = analysis.emotion
                    finalUpdated.tags = analysis.tags
                    
                    viewModel.updateEntry(finalUpdated)
                    editingEntry = nil
                }
            )
        }
        .alert("delete_confirm_title", isPresented: Binding(
            get: { deletingEntryId != nil },
            set: { if !$0 { deletingEntryId = nil } }
        )) {
            Button("cancel", role: .cancel) { deletingEntryId = nil }
            Button("delete", role: .destructive) {
                if let id = deletingEntryId {
                    viewModel.deleteEntry(dateId: id)
                }
                deletingEntryId = nil
            }
        } message: {
            Text("delete_confirm_message")
        }
    }
}
