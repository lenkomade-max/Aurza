//
//  NotificationService.swift
//  AURZA
//

import Foundation
import UserNotifications

class NotificationService: ObservableObject {
    @Published var isAuthorized = false
    
    init() {
        checkAuthorizationStatus()
    }
    
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                self.isAuthorized = granted
            }
        }
    }
    
    func checkAuthorizationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.isAuthorized = settings.authorizationStatus == .authorized
            }
        }
    }
    
    func scheduleNotification(for item: Any, reminders: [Reminder]) {
        guard isAuthorized else { return }
        
        let content = UNMutableNotificationContent()
        
        if let task = item as? TaskItem {
            content.title = task.emoji + " " + NSLocalizedString("notification_task_title", comment: "")
            content.body = task.title
            content.categoryIdentifier = "TASK"
            
            for reminder in reminders where reminder.isEnabled {
                scheduleNotificationWithContent(content, at: reminder.time, identifier: "\(task.id.uuidString)-\(reminder.id.uuidString)", sound: reminder.soundName)
            }
        } else if let habit = item as? Habit {
            content.title = habit.emoji + " " + NSLocalizedString("notification_habit_title", comment: "")
            content.body = habit.title
            content.categoryIdentifier = "HABIT"
            
            for reminder in reminders where reminder.isEnabled {
                for day in habit.schedule {
                    scheduleWeeklyNotification(content: content, weekday: day, time: reminder.time, identifier: "\(habit.id.uuidString)-\(reminder.id.uuidString)-\(day)", sound: reminder.soundName)
                }
            }
        } else if let goal = item as? Goal {
            content.title = goal.emoji + " " + NSLocalizedString("notification_goal_title", comment: "")
            content.body = goal.title
            content.categoryIdentifier = "GOAL"
            
            for reminder in reminders where reminder.isEnabled {
                scheduleNotificationWithContent(content, at: reminder.time, identifier: "\(goal.id.uuidString)-\(reminder.id.uuidString)", sound: reminder.soundName)
            }
        }
    }
    
    private func scheduleNotificationWithContent(_ content: UNMutableNotificationContent, at date: Date, identifier: String, sound: String?) {
        if let soundName = sound, soundName != "default" {
            content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: soundName + ".m4a"))
        } else {
            content.sound = .default
        }

        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error.localizedDescription)")
            }
        }
    }
    
    private func scheduleWeeklyNotification(content: UNMutableNotificationContent, weekday: Int, time: Date, identifier: String, sound: String?) {
        if let soundName = sound, soundName != "default" {
            content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: soundName + ".m4a"))
        } else {
            content.sound = .default
        }

        let calendar = Calendar.current
        var components = calendar.dateComponents([.hour, .minute], from: time)
        components.weekday = weekday

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule weekly notification: \(error.localizedDescription)")
            }
        }
    }
    
    func removeNotifications(for itemId: UUID) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let identifiersToRemove = requests
                .filter { $0.identifier.contains(itemId.uuidString) }
                .map { $0.identifier }
            
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiersToRemove)
        }
    }
    
    func scheduleDailyQuestion(at time: Date) {
        guard isAuthorized else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "📓 " + NSLocalizedString("notification_daily_question_title", comment: "")
        content.body = getDailyQuestion()
        content.sound = .default
        content.categoryIdentifier = "DAILY_QUESTION"
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: time)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        
        let request = UNNotificationRequest(identifier: "daily-question", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
    
    func removeDailyQuestion() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["daily-question"])
    }
    
    private func getDailyQuestion() -> String {
        let questions = [
            NSLocalizedString("daily_question_1", comment: ""),
            NSLocalizedString("daily_question_2", comment: ""),
            NSLocalizedString("daily_question_3", comment: ""),
            NSLocalizedString("daily_question_4", comment: ""),
            NSLocalizedString("daily_question_5", comment: ""),
            NSLocalizedString("daily_question_6", comment: ""),
            NSLocalizedString("daily_question_7", comment: ""),
            NSLocalizedString("daily_question_8", comment: ""),
            NSLocalizedString("daily_question_9", comment: ""),
            NSLocalizedString("daily_question_10", comment: "")
        ]
        
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        return questions[dayOfYear % questions.count]
    }
}
