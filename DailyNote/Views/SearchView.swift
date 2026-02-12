import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()
    
    var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView()
            } else if viewModel.filteredEntries.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    Text("no_search_results")
                        .foregroundColor(.secondary)
                }
                .frame(maxHeight: .infinity)
            } else {
                List(viewModel.filteredEntries) { entry in
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
                            .lineLimit(2)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle("search")
        .searchable(text: $viewModel.query, prompt: Text("search_placeholder"))
        .onAppear {
            viewModel.load()
        }
    }
}
