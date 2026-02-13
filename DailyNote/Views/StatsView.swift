import SwiftUI

struct StatsView: View {
    @Binding var isPresented: Bool
    let entries: [NoteEntry]
    
    @State private var streak: Int = 0
    @State private var maxStreak: Int = 0
    @State private var totalEntries: Int = 0
    
    private let calendar = Calendar.current
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Summary Section
                    HStack(spacing: 20) {
                        StatCard(title: "current_streak", value: "\(streak)", unit: "days")
                        StatCard(title: "longest_streak", value: "\(maxStreak)", unit: "days")
                        StatCard(title: "total_entries", value: "\(totalEntries)", unit: "count_unit")
                    }
                    .padding(.horizontal)
                    
                    // Calendar Section
                    VStack(alignment: .leading, spacing: 20) {
                        Text("activity_log")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        // Yearly Calendar View
                        // Assuming current year, or maybe last 12 months.
                        // The user image shows "2026", a full year view.
                        // Let's implement dynamic year viewing.
                        
                        let year = calendar.component(.year, from: Date())
                        
                        Text(String(year))
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 1), spacing: 24) {
                            ForEach(1...12, id: \.self) { month in
                                MonthView(month: month, year: year, entries: entries)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("statistics")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("close") {
                        isPresented = false
                    }
                }
            }
            .onAppear {
                calculateStats()
            }
        }
    }
    
    private func calculateStats() {
        totalEntries = entries.count
        
        let sorted = entries.sorted { $0.id > $1.id }
        
        var current = 0
        var maxS = 0
        
        let today = Date()
        let todayStr = formatDate(today)
        let yesterdayStr = formatDate(calendar.date(byAdding: .day, value: -1, to: today)!)
        
        let hasToday = sorted.contains { $0.id == todayStr }
        let hasYesterday = sorted.contains { $0.id == yesterdayStr }
        
        let entrySet = Set(sorted.map { $0.id })
        
        var checkDate = hasToday ? today : (hasYesterday ? calendar.date(byAdding: .day, value: -1, to: today)! : nil)
        
        if let start = checkDate {
            while entrySet.contains(formatDate(checkDate!)) {
                current += 1
                checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate!)
            }
        }
        
        // Calculate Max Streak
        if !sorted.isEmpty {
            var streakCount = 1
            for i in 0..<(sorted.count - 1) {
                let date1 = getDate(from: sorted[i].id)
                let date2 = getDate(from: sorted[i+1].id)
                
                if let d1 = date1, let d2 = date2,
                   calendar.dateComponents([.day], from: d2, to: d1).day == 1 {
                    streakCount += 1
                } else {
                    maxS = max(maxS, streakCount)
                    streakCount = 1
                }
            }
            maxS = max(maxS, streakCount)
        }
        
        self.streak = current
        self.maxStreak = maxS
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    private func getDate(from str: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: str)
    }
}

struct MonthView: View {
    let month: Int
    let year: Int
    let entries: [NoteEntry]
    
    private let calendar = Calendar.current
    private let days: [String] = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(monthName)
                .font(.headline)
                .foregroundColor(.red) // Month title in red like the reference image
            
            // Weekday headers
            HStack {
                ForEach(days, id: \.self) { day in
                    Text(LocalizedStringKey(day)) // Localization key needs to be handled or just use fixed
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            
            // Days Grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                ForEach(generateDays(), id: \.self) { dateWrapper in
                    if let date = dateWrapper.date {
                        DayCell(date: date, entry: getEntry(for: date))
                    } else {
                        // Empty spacer
                        Color.clear
                            .frame(height: 20)
                    }
                }
            }
        }
        .padding()
        //.background(Color(uiColor: .secondarySystemGroupedBackground))
        //.cornerRadius(12)
    }
    
    // Helper to get localized month name
    private var monthName: String {
        let formatter = DateFormatter()
        return formatter.monthSymbols[month - 1]
    }
    
    private func getEntry(for date: Date) -> NoteEntry? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let id = formatter.string(from: date)
        return entries.first(where: { $0.id == id })
    }
    
    struct DateWrapper: Hashable {
        let id = UUID()
        let date: Date?
    }
    
    private func generateDays() -> [DateWrapper] {
        var days: [DateWrapper] = []
        
        let dateComponents = DateComponents(year: year, month: month, day: 1)
        guard let firstDayOfMonth = calendar.date(from: dateComponents),
              let range = calendar.range(of: .day, in: .month, for: firstDayOfMonth) else {
            return []
        }
        
        // Calculate weekday offset (Sunday = 1)
        let weekday = calendar.component(.weekday, from: firstDayOfMonth)
        let offset = weekday - 1
        
        // Add empty slots for offset
        for _ in 0..<offset {
            days.append(DateWrapper(date: nil))
        }
        
        // Add actual days
        for day in 1...range.count {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDayOfMonth) {
                days.append(DateWrapper(date: date))
            }
        }
        
        return days
    }
}

struct DayCell: View {
    let date: Date
    let entry: NoteEntry?
    
    private var dayString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    var body: some View {
        ZStack {
            if let entry = entry {
                Circle()
                    .fill(getColor(for: entry))
                    .frame(width: 30, height: 30)
            }
            
            Text(dayString)
                .font(.caption)
                .foregroundColor(entry != nil ? .white : .primary)
        }
        .frame(height: 30)
    }
    
    private func getColor(for entry: NoteEntry) -> Color {
        let count = entry.content.count
        // Red theme like the reference image? Or stick to Green?
        // Reference image shows a red month header and red selected date.
        // Let's stick to Green for "Grass" (contribution graph) but maybe style it round?
        // User asked for "Activity Grass" (Jan-di) in "Calendar Form".
        // Usually grass is green.
        if count > 100 { return Color.green.opacity(1.0) }
        if count > 50 { return Color.green.opacity(0.8) }
        if count > 20 { return Color.green.opacity(0.6) }
        return Color.green.opacity(0.4)
    }
}

// ... StatCard remains same ...
struct StatCard: View {
    let title: String
    let value: String
    let unit: String
    
    var body: some View {
        VStack(spacing: 8) {
            Text(LocalizedStringKey(title))
                .font(.caption)
                .foregroundColor(.secondary)
            
            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                Text(LocalizedStringKey(unit))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
}
