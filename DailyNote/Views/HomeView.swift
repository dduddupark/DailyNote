import SwiftUI

struct HomeView: View { // ✅ @Composable 함수 역할
    // ✅ ViewModel을 선언하고 관찰(Observe)합니다. (viewModel.todayTitle이 변하면 뷰가 재구성됨)
    @StateObject private var viewModel = HomeViewModel()
    @FocusState private var isTextFieldFocused: Bool
    @FocusState private var isTitleFieldFocused: Bool
    @State private var editingEntry: NoteEntry?
    @State private var deletingEntryId: String?
    @State private var showStats = false
    @State private var showLogoutAlert = false
    
    var body: some View {
        ZStack { // ✅ Compose의 Box 
            Color(uiColor: .systemGroupedBackground).ignoresSafeArea()
            
            ScrollView { // ✅ ScrollableColumn (Lazy 안쓸때)
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
                                .onChange(of: viewModel.todayTitle) { newValue in
                                    if newValue.count > 20 {
                                        viewModel.todayTitle = String(newValue.prefix(20))
                                    }
                                }
                            
                            TextField("today_placeholder", text: $viewModel.todayContent, axis: .vertical)
                                .lineLimit(3...10) // Increase max lines
                                .frame(maxHeight: 300) // Ensure it doesn't grow indefinitely, triggering scroll
                                .focused($isTextFieldFocused)
                                .disabled(!viewModel.canEditToday)
                                .font(.system(size: 18, weight: .medium, design: .serif))
                                .onChange(of: viewModel.todayContent) { newValue in
                                    if newValue.count > 100 {
                                        viewModel.todayContent = String(newValue.prefix(100))
                                    }
                                    viewModel.updateTextCount(text: newValue)
                                }

                            Text(String(format: NSLocalizedString("text_count", comment: ""), viewModel.textCount))
                                .font(.system(size: 10, weight: .light, design: .serif))
                                .foregroundColor(viewModel.textCount > 100 ? Color.red : Color.gray)
                                .frame(maxWidth: .infinity, alignment:.trailing)
            
                            
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
                                            .background(Color.accentColor)
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
                                    NoteRowView(
                                        entry: entry,
                                        onEdit: { editingEntry = entry },
                                        onDelete: { deletingEntryId = entry.id }
                                    )
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
                HStack {
                    NavigationLink {
                        SearchView()
                    } label: {
                        Image(systemName: "magnifyingglass")
                    }
                    .accessibilityLabel(Text("search"))

                    Menu {
                        Button {
                            showStats = true
                        } label: {
                            Label("statistics", systemImage: "chart.bar.xaxis")
                        }
                        
                        Button {
                            viewModel.analyzeAllEntries()
                        } label: {
                            Label("analyze_all", systemImage: "sparkles")
                        }
                        
                        Button {
                            viewModel.injectTestData()
                        } label: {
                            Label("Inject Test Data", systemImage: "flask")
                        }
                        
                        Divider()
                        
                        Button(role: .destructive) {
                            showLogoutAlert = true
                        } label: {
                            Label("logout", systemImage: "rectangle.portrait.and.arrow.right")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
        .sheet(isPresented: $showStats) {
            StatsView(isPresented: $showStats, entries: viewModel.allEntriesForStats)
        }
        .alert("logout_confirm_title", isPresented: $showLogoutAlert) {
             Button("cancel", role: .cancel) { }
             Button("logout", role: .destructive) {
                 AuthService.shared.signOut()
             }
         } message: {
             if AuthService.shared.isAnonymous {
                 Text("logout_confirm_message_guest")
             } else {
                 Text("logout_confirm_message")
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
        .onAppear { // ✅ Compose의 LaunchedEffect(Unit) 과 비슷하게, 뷰가 그려질 때 
            viewModel.loadData()
            
            if AuthService.shared.shouldShowLoginToast {
                viewModel.showToast(message: NSLocalizedString("login_success", comment: ""))
                AuthService.shared.shouldShowLoginToast = false
            }
        }
    }
}
