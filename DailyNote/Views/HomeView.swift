import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @FocusState private var isTextFieldFocused: Bool
    
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
                                    }) {
                                        Text(viewModel.isTodayEntryExisted ? "update" : "save")
                                            .fontWeight(.semibold)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 8)
                                            .background(Color.blue)
                                            .foregroundColor(.white)
                                            .cornerRadius(20)
                                    }
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
                                            Text(entry.content)
                                                .font(.body)
                                        }
                                        Spacer()
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
        .onAppear {
            viewModel.loadData()
        }
    }
}

#Preview {
    HomeView()
}
