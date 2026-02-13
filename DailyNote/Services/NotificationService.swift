import UserNotifications
import UIKit

class NotificationService {
    static let shared = NotificationService()
    
    private let notificationCenter = UNUserNotificationCenter.current()
    private let dailyReminderIdentifier = "daily_reminder"
    
    private init() {}
    
    // Request Notification Permission
    func requestPermission() {
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification permission granted.")
                self.scheduleDailyReminder()
            } else if let error = error {
                print("Notification permission denied: \(error.localizedDescription)")
            }
        }
    }
    
    // Schedule Daily Reminder at 20:00 (8 PM)
    func scheduleDailyReminder() {
        // Remove existing to avoid duplicates or old schedules
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [dailyReminderIdentifier])
        
        let content = UNMutableNotificationContent()
        content.title = NSLocalizedString("app_name", comment: "DailyNote")
        content.body = NSLocalizedString("daily_reminder_message", comment: "Did you write today?")
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.hour = 20
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let request = UNNotificationRequest(identifier: dailyReminderIdentifier, content: content, trigger: trigger)
        
        notificationCenter.add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            } else {
                print("Daily reminder scheduled for 20:00")
            }
        }
    }
    
    // Cancel Today's Notification (if logic requires specific day cancellation)
    // Since we use a recurring trigger, we can't just cancel "today's instance" easily without removing the recurrence.
    // Strategy: Remove the recurring notification.
    // And then re-schedule it for tomorrow? That's complex.
    // Alternative: Just let it be. If user writes, they write.
    // BUT User said "If not written".
    // Better Strategy:
    // When app enters background: Check if today's entry exists.
    // If NO -> Schedule One-Time Notification for Today 20:00 (if time is before 20:00)
    // If YES -> Do nothing (or Cancel pending if any)
    // AND -> Also schedule the Recurring one?
    
    // Let's stick to the User Request: "If not written today... 1 time daily".
    // 1. Recurring at 20:00.
    // 2. If user writes today, we can temporarily remove the pending request.
    // 3. But removing a recurring request removes it forever.
    // 4. So if we remove it, we must reschedule it for "Tomorrow 20:00" and then recurring?
    // 5. This is getting complicated.
    // Simpler Apple Way:
    // Just schedule it daily. Most apps do this. "Time to write!". If you already wrote, you just ignore or tap and see you wrote.
    // However, to be "Smart":
    // on `saveTodayEntry`, we cancel the notification with `dailyReminderIdentifier`.
    // Then we schedule a NEW one starting from *Tomorrow* 20:00.
    // How to schedule starting tomorrow?
    // We can just schedule a recurring one. If we add it again later, it overwrites.
    
    // Adjusted Logic:
    // 1. `scheduleDailyReminder`: Schedules recurring 20:00.
    // 2. `removeReminder`: Removes it.
    // 3. Flow:
    //    - App Launch: `scheduleDailyReminder` (Ensures it's there).
    //    - `saveTodayEntry`: `removeReminder` (So it doesn't fire *tonight*).
    //    - Next App Launch (tomorrow): `scheduleDailyReminder` (Restores it).
    //    - What if user doesn't open app tomorrow? Then it won't fire tomorrow because we removed it today.
    //    - CRITICAL FLAW: If we remove it today, it's gone for good until app is opened again.
    
    // Correct Logic for "Smart" Reminder without Background Fetch:
    // You cannot easily conditionally cancel *only today's* instance of a recurring local notification without cancelling the future ones.
    // UNLESS we use `UNNotificationServiceExtension` which requires remote push.
    // OR we schedule 64 individual notifications for the next 2 months. 
    // Let's go with the 64 notifications approach. It's robust for local.
    // Limit is 64.
    
    func updateDailyReminders(isTodayWritten: Bool) {
        // 1. Cancel everything
        notificationCenter.removeAllPendingNotificationRequests()
        
        // 2. Schedule for next 30 days
        let content = UNMutableNotificationContent()
        content.title = NSLocalizedString("app_name", comment: "DailyNote")
        content.body = NSLocalizedString("daily_reminder_message", comment: "Did you write today?")
        content.sound = .default
        
        let calendar = Calendar.current
        let now = Date()
        
        for i in 0..<30 {
            // Target date: Today + i days
            guard let targetDate = calendar.date(byAdding: .day, value: i, to: now) else { continue }
            
            // If i == 0 (Today), skip if already written OR if time is past 20:00
            if i == 0 {
                if isTodayWritten { continue }
                if calendar.component(.hour, from: now) >= 20 { continue }
            }
            
            // Set time to 20:00
            var components = calendar.dateComponents([.year, .month, .day], from: targetDate)
            components.hour = 20
            components.minute = 0
            
            let id = "daily_reminder_\(i)" // unique ID per day
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
            
            notificationCenter.add(request)
        }
        
        print("Updated reminders. Today written: \(isTodayWritten)")
    }
}
