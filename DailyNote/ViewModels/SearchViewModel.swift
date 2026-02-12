import Foundation

final class SearchViewModel: ObservableObject {
    @Published var query: String = ""
    @Published var isLoading: Bool = false
    @Published var entries: [NoteEntry] = []

    var filteredEntries: [NoteEntry] {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return entries }

        let lower = q.lowercased()
        return entries.filter { entry in
            entry.id.lowercased().contains(lower) ||
            entry.title.lowercased().contains(lower) ||
            entry.content.lowercased().contains(lower)
        }
    }

    @MainActor
    func load() {
        isLoading = true
        Task {
            do {
                let fetchedEntries = try await FirestoreService.shared.fetchEntries()
                self.entries = fetchedEntries.sorted(by: { $0.id > $1.id })
            } catch {
                print("Error fetching entries: \(error.localizedDescription)")
                self.entries = []
            }
            self.isLoading = false
        }
    }
}
