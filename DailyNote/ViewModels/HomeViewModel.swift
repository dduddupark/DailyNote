import Foundation
import Combine
import SwiftUI

class HomeViewModel: ObservableObject {
    @Published var entries: [NoteEntry] = []
    @Published var todayContent: String = ""
    @Published var canEditToday: Bool = true
    @Published var isLoading: Bool = false
    @Published var isTodayEntryExisted: Bool = false
    @Published var toastMessage: String? = nil
    
    private var todayEntry: NoteEntry?
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    var todayId: String {
        return dateFormatter.string(from: Date())
    }
    
    func loadData() {
        isLoading = true
        self.fetchTodayEntry()
        self.fetchAllEntries()
    }
    
    private func fetchTodayEntry() {
        FirestoreService.shared.fetchTodayEntry(dateId: todayId) { entry in
            DispatchQueue.main.async {
                if let entry = entry {
                    self.todayEntry = entry
                    self.todayContent = entry.content
                    self.canEditToday = entry.editCount < 9 // 0 to 9 allow saves (total 10)
                    self.isTodayEntryExisted = true
                } else {
                    self.todayEntry = nil
                    self.todayContent = ""
                    self.canEditToday = true
                    self.isTodayEntryExisted = false
                }
                self.isLoading = false
            }
        }
    }
    
    private func fetchAllEntries() {
        FirestoreService.shared.fetchEntries { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let entries):
                    self.entries = entries.filter { $0.id != self.todayId }
                case .failure(let error):
                    print("Error fetching entries: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func saveTodayEntry() {
        isLoading = true
        let newEditCount = (todayEntry?.editCount ?? -1) + 1
        let entry = NoteEntry(
            id: todayId,
            content: todayContent,
            updatedAt: todayId,
            editCount: newEditCount
        )
        
        FirestoreService.shared.saveEntry(entry) { error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error saving entry: \(error.localizedDescription)")
                    self.isLoading = false
                    return
                }
                
                let successMessage = self.isTodayEntryExisted ? "update_success" : "save_success"
                self.showToast(message: successMessage)
                
                self.fetchTodayEntry()
                self.fetchAllEntries()
            }
        }
    }
    
    private func showToast(message: String) {
        self.toastMessage = message
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation {
                self.toastMessage = nil
            }
        }
    }
}
