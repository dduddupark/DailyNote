import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @FocusState private var isTextFieldFocused: Bool
    @FocusState private var isTitleFieldFocused: Bool
    @State private var editingEntry: NoteEntry?
    @State private var deletingEntryId: String?
    
    var body: some View {
        ZStack {
            Color(uiColor: .systemGroupedBackground).ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Today's Entry Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("today_line")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        VStack {
                            TextField("title_placeholder", text: $viewModel.todayTitle)
                                .focused($isTitleFieldFocused)
                                .disabled(!viewModel.canEditToday)
                                .font(.system(size: 16, weight: .semibold, design: .serif))
                            
                            TextField("today_placeholder", text: $viewModel.todayContent, axis: .vertical)
                                .lineLimit(3...5)
                                .focused($isTextFieldFocused)
                                .disabled(!viewModel.canEditToday)
                                .font(.system(size: 18, weight: .medium, design: .serif))
                            
                            if viewModel.canEditToday {
                                HStack {
                                    Spacer()
                                    Button(action: {
                                        viewModel.saveTodayEntry()
                                        isTextFieldFocused = false
                                        isTitleFieldFocused = false
                                    }) {
                                        Text(viewModel.isTodayEntryExisted ? "update" : "save")
                                            .fontWeight(.semibold)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 8)
                                            .background(Color.blue)
                                            .foregroundColor(.white)
                                            .cornerRadius(20)
                                    }
                                    .disabled(viewModel.isLoading)
                                    .padding(.top, 8)
                                }
                            } else {
                                 Text("edit_limit_reached")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .padding(.top, 4)
                            }
                        }
                        .padding(20)
                        .background(Color(uiColor: .secondarySystemGroupedBackground))
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                    }
                    .padding(.horizontal)
                    
                    // History Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("history")
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                        
                        if viewModel.entries.isEmpty {
                            Text("no_records")
                                .foregroundColor(.secondary)
                                .padding(.horizontal)
                        } else {
                            LazyVStack(alignment: .leading, spacing: 12) {
                                ForEach(viewModel.entries) { entry in
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(entry.id)
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                            if !entry.title.isEmpty {
                                                Text(entry.title)
                                                    .font(.headline)
                                            }
                                            Text(entry.content)
                                                .font(.body)
                                                .foregroundColor(.primary.opacity(0.90))
                                        }
                                        Spacer()
                                        HStack(spacing: 10) {
                                            Button {
                                                editingEntry = entry
                                            } label: {
                                                Image(systemName: "pencil")
                                                    .imageScale(.medium)
                                            }
                                            .buttonStyle(.plain)
                                            .foregroundColor(.blue)

                                            Button {
                                                deletingEntryId = entry.id
                                            } label: {
                                                Image(systemName: "trash")
                                                    .imageScale(.medium)
                                            }
                                            .buttonStyle(.plain)
                                            .foregroundColor(.red)
                                        }
                                    }
                                    .padding()
                                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                                    .cornerRadius(12)
                                    .padding(.horizontal)
                                }
                            }
                        }
                    }
                }
                .padding(.vertical)
            }
            
            if viewModel.isLoading {
                ProgressView()
            }
            
            // Toast Notification
            if let message = viewModel.toastMessage {
                VStack {
                    Spacer()
                    Text(LocalizedStringKey(message))
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color.black.opacity(0.8))
                        .cornerRadius(25)
                        .padding(.bottom, 50)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                .animation(.spring(), value: viewModel.toastMessage)
                .zIndex(1)
            }
        }
        .navigationTitle("app_name")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink {
                    SearchView()
                } label: {
                    Image(systemName: "magnifyingglass")
                }
                .accessibilityLabel(Text("search"))
            }
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
                        editCount: entry.editCount
                    )
                    viewModel.updateEntry(updated)
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
        .onAppear {
            viewModel.loadData()
        }
    }
}
