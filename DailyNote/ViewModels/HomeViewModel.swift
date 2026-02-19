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
    
    var allEntriesForStats: [NoteEntry] {
        if let today = todayEntry {
            return entries + [today]
        }
        return entries
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
                
                // Update Reminders: Today is written
                NotificationService.shared.updateDailyReminders(isTodayWritten: true)
            } else {
                self.todayEntry = nil
                self.todayTitle = ""
                self.todayContent = ""
                self.canEditToday = true
                self.isTodayEntryExisted = false
                
                // Update Reminders: Today is NOT written
                NotificationService.shared.updateDailyReminders(isTodayWritten: false)
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
            showToast(message: "Fetch Error: \(error.localizedDescription)")
        }
    }
    
    func saveTodayEntry() {
        isLoading = true
        let newEditCount = (todayEntry?.editCount ?? -1) + 1
        var entry = NoteEntry(
            id: todayId,
            title: todayTitle,
            content: todayContent,
            updatedAt: todayId,
            editCount: newEditCount
        )
        // AI Analysis
        let analysis = NoteAnalysisService.shared.analyze(text: todayContent)
        entry.emotion = analysis.emotion
        entry.tags = analysis.tags
        Task {
            do {
                try await FirestoreService.shared.saveEntry(entry)
                let wasExisted = self.isTodayEntryExisted
                self.todayEntry = entry
                self.isTodayEntryExisted = true
                self.canEditToday = entry.editCount < 9
                showToast(message: wasExisted ? "update_success" : "save_success")
                
                // Update Reminders: Today is written
                NotificationService.shared.updateDailyReminders(isTodayWritten: true)
                
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
                    
                    // Update Reminders: Today is NOT written (deleted)
                    NotificationService.shared.updateDailyReminders(isTodayWritten: false)
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
        var updated = NoteEntry(
            id: entry.id,
            title: entry.title,
            content: entry.content,
            updatedAt: todayId,
            editCount: entry.editCount + 1
        )
        // AI Analysis
        let analysis = NoteAnalysisService.shared.analyze(text: entry.content)
        updated.emotion = analysis.emotion
        updated.tags = analysis.tags
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
                self.entries = [] // Force clear to trigger UI refresh
                await fetchAllEntries()
            } catch {
                showToast(message: "save_failed")
            }
            isLoading = false
        }
    }

    func showToast(message: String) {
        self.toastMessage = message
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation {
                if self.toastMessage == message {
                    self.toastMessage = nil
                }
            }
        }
    }
    
    func analyzeAllEntries() {
        isLoading = true
        showToast(message: "analyzing_past_data")
        Task {
            var updatedCount = 0
            for entry in entries {
                let analysis = NoteAnalysisService.shared.analyze(text: entry.content)
                if entry.emotion != analysis.emotion || entry.tags != analysis.tags {
                    var updated = entry
                    updated.emotion = analysis.emotion
                    updated.tags = analysis.tags
                    
                    do {
                        try await FirestoreService.shared.saveEntry(updated)
                        updatedCount += 1
                    } catch {
                        print("Failed to update entry \(entry.id): \(error)")
                    }
                }
            }
            showToast(message: "Analysis Complete: \(updatedCount) updated")
            await fetchAllEntries()
            isLoading = false
        }
    }

    func injectTestData() {
        isLoading = true
        Task {
            let calendar = Calendar.current
            let year = 2026
            
            var dates: [Date] = []
            
            // 1. Jan 1, 2, 3
            for day in 1...3 {
                if let date = calendar.date(from: DateComponents(year: year, month: 1, day: day)) {
                    dates.append(date)
                }
            }
            
            // 2. Jan 20~30
            for day in 20...30 {
                if let date = calendar.date(from: DateComponents(year: year, month: 1, day: day)) {
                    dates.append(date)
                }
            }
            
            // 3. Feb 10~18
            for day in 10...18 {
                if let date = calendar.date(from: DateComponents(year: year, month: 2, day: day)) {
                    dates.append(date)
                }
            }
            
            let sampleTitles = [
                "오늘의 운동 기록", "새로운 맛집 발견!", "업무 미팅 후기", "주말 여행 계획", "책 읽은 소감",
                "비 오는 날의 생각", "친구와 저녁 약속", "새로운 프로젝트 시작", "잠이 안 오는 밤", "기분 전환 산책"
            ]
            
            let sampleContents = [
                "오늘은 정말 힘들었지만 보람찬 하루였다. 운동을 열심히 했더니 몸이 개운하다.",
                "우연히 들어간 카페의 커피가 너무 맛있었다. 다음에 또 와야지.",
                "미팅에서 좋은 아이디어가 많이 나왔다. 내일 바로 적용해봐야겠다.",
                "이번 주말에는 어디로 떠날까? 바다가 보고 싶기도 하고 산이 좋기도 하다.",
                "책을 읽으면서 많은 위로를 받았다. 작가의 문체가 정말 마음에 든다.",
                "비 오는 소리를 들으니 마음이 차분해진다. 따뜻한 차 한 잔 마시고 싶다.",
                "오랜만에 친구를 만나서 수다를 떨었더니 스트레스가 다 풀린다.",
                "새로운 일을 시작하는 건 언제나 설레고 두려운 일이다. 하지만 잘 해낼 수 있을 거야.",
                "생각이 많아서 잠이 오지 않는다. 내일 일찍 일어나야 하는데 걱정이다.",
                "날씨가 좋아서 공원을 걸었다. 바람이 시원하고 햇살이 따뜻했다."
            ]
            
            let emotions = ["happy", "sad", "neutral", "excited", "tired"]
            let tagsList = [["exercise", "health"], ["food", "cafe"], ["work", "idea"], ["travel", "plan"], ["reading", "book"]]

            for (index, date) in dates.enumerated() {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                formatter.locale = Locale(identifier: "en_US_POSIX")
                let id = formatter.string(from: date)
                
                let randomTitle = sampleTitles[index % sampleTitles.count]
                let randomContent = sampleContents[index % sampleContents.count]
                let randomEmotion = emotions[index % emotions.count]
                let randomTags = tagsList[index % tagsList.count]
                
                var entry = NoteEntry(
                    id: id,
                    title: randomTitle,
                    content: randomContent,
                    updatedAt: id,
                    editCount: Int.random(in: 0...5)
                )
                entry.emotion = randomEmotion
                entry.tags = randomTags
                
                do {
                    try await FirestoreService.shared.saveEntry(entry)
                    print("Injected: \(id) - \(randomTitle)")
                } catch {
                    print("Failed to inject \(id): \(error)")
                }
            }
            
            await fetchAllEntries()
            isLoading = false
            showToast(message: "Test Data Injected")
        }
    }
}
