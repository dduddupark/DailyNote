import Foundation
import Combine
import SwiftUI

@MainActor
class HomeViewModel: ObservableObject {
    @Published var entries: [NoteEntry] = []
    @Published var todayTitle: String = ""
    @Published var todayContent: String = ""
    @Published var canEditToday: Bool = true
    @Published var isLoading: Bool = false
    @Published var isTodayEntryExisted: Bool = false
    @Published var toastMessage: String? = nil
    
    private var todayEntry: NoteEntry?
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    var todayId: String {
        return dateFormatter.string(from: Date())
    }
    
    func loadData() {
        isLoading = true
        Task {
            await fetchTodayEntry()
            await fetchAllEntries()
            isLoading = false
        }
    }
    
    private func fetchTodayEntry() async {
        do {
            let entry = try await FirestoreService.shared.fetchTodayEntry(dateId: todayId)
            if let entry = entry {
                self.todayEntry = entry
                self.todayTitle = entry.title
                self.todayContent = entry.content
                self.canEditToday = entry.editCount < 9
                self.isTodayEntryExisted = true
            } else {
                self.todayEntry = nil
                self.todayTitle = ""
                self.todayContent = ""
                self.canEditToday = true
                self.isTodayEntryExisted = false
            }
        } catch {
            print("Fetch failed: \(error.localizedDescription)")
        }
    }

    private func fetchAllEntries() async {
        do {
            let allEntries = try await FirestoreService.shared.fetchEntries()
            let nonToday = allEntries.filter { $0.id != self.todayId }
            let unique = Dictionary(grouping: nonToday, by: { $0.id })
                .compactMap { (_, group) in
                    group.max(by: { $0.editCount < $1.editCount })
                }
                .sorted(by: { $0.id > $1.id })
            self.entries = unique
        } catch {
            print("Fetch entries error: \(error.localizedDescription)")
        }
    }
    
    func saveTodayEntry() {
        isLoading = true
        let newEditCount = (todayEntry?.editCount ?? -1) + 1
        let entry = NoteEntry(
            id: todayId,
            title: todayTitle,
            content: todayContent,
            updatedAt: todayId,
            editCount: newEditCount
        )
        Task {
            do {
                try await FirestoreService.shared.saveEntry(entry)
                let wasExisted = self.isTodayEntryExisted
                self.todayEntry = entry
                self.isTodayEntryExisted = true
                self.canEditToday = entry.editCount < 9
                showToast(message: wasExisted ? "update_success" : "save_success")
                await fetchAllEntries()
            } catch {
                showToast(message: "save_failed")
            }
            isLoading = false
        }
    }

    func deleteEntry(dateId: String) {
        isLoading = true
        Task {
            do {
                try await FirestoreService.shared.deleteEntry(dateId: dateId)
                if dateId == todayId {
                    self.todayEntry = nil
                    self.todayTitle = ""
                    self.todayContent = ""
                    self.isTodayEntryExisted = false
                    self.canEditToday = true
                }
                showToast(message: "delete_success")
                await fetchAllEntries()
            } catch {
                showToast(message: "delete_failed")
            }
            isLoading = false
        }
    }

    func updateEntry(_ entry: NoteEntry) {
        isLoading = true
        let updated = NoteEntry(
            id: entry.id,
            title: entry.title,
            content: entry.content,
            updatedAt: todayId,
            editCount: entry.editCount + 1
        )
        Task {
            do {
                try await FirestoreService.shared.saveEntry(updated)
                if updated.id == todayId {
                    self.todayEntry = updated
                    self.todayTitle = updated.title
                    self.todayContent = updated.content
                    self.canEditToday = updated.editCount < 9
                    self.isTodayEntryExisted = true
                }
                showToast(message: "update_success")
                await fetchAllEntries()
            } catch {
                showToast(message: "save_failed")
            }
            isLoading = false
        }
    }

    private func showToast(message: String) {
        self.toastMessage = message
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation {
                if self.toastMessage == message {
                    self.toastMessage = nil
                }
            }
        }
    }
}
