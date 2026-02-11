import Foundation
import Combine
import UserNotifications
import WatchKit
import CoreMotion

enum Activity: String {
    case stationary = "Stationary"
    case running = "Running"
    case walking = "Walking"
    case unknown = "Unknown"
}

class ActivityCoachManager: ObservableObject {
    // MARK: - Published Propties
    @Published var currentActivity: Activity?
    @Published var steps: Int = 0
    @Published var stepGoal: Int = 10000
    @Published var inactivityMinutes: Int = 0
    @Published var lastMilestone: Int = 0
    @Published var showCelebration = false
    @Published var isMonitoring = false
    
    // MARK: - Settings
    @Published var inactivityAlertMinutes: Int = 30
    @Published var notificationEnabled: Bool = true
    
    // MARK: - Private Properties
    private let motionManager = CMMotionManager()
    private let activityManager = CMMotionActivityManager()
    private let pedometer = CMPedometer()
    private var inactivityTimer: Timer?
    private var stationaryStartTime: Date?
    private var milestones = [25, 50, 75, 100]
    
    var stepProgress: Double {
        Double(steps) / Double(stepGoal)
    }
    
    var stepProgressPercentage: Int {
        Int(stepProgress * 100)
    }
    
    
    init() {
        motionManager.accelerometerUpdateInterval = 10.0
    }
    
    // MARK: - Permissions
    func requestPermissions() async {
        let center = UNUserNotificationCenter.current()
        
        do {
            notificationEnabled = try await center.requestAuthorization(options: [.alert, .badge, .sound])
        } catch  {
            notificationEnabled = false
        }
    }
    
    // MARK: - Activity Monitoring
    func startMonitoring() {
        guard !isMonitoring else { return }
        
        startActivityMonitoring()
        startPedometerUpdates()
        startInactivityTimer()
        
        isMonitoring = true
        WKInterfaceDevice.current().play(.start)
    }
    
    func stopMonitoring() {
        activityManager.stopActivityUpdates()
        pedometer.stopUpdates()
        inactivityTimer?.invalidate()
        motionManager.stopAccelerometerUpdates()
        
        isMonitoring = false
    }
    
    private func startActivityMonitoring() {
        guard CMMotionActivityManager.isActivityAvailable() else { return }
        
        activityManager.startActivityUpdates(to: .main) {[weak self] activity in
            guard let self = self, let activity = activity else { return }
            
            let newActivity: Activity
            if activity.running {
                newActivity = .running
            } else if activity.walking {
                newActivity = .walking
            } else if activity.stationary {
                newActivity = .stationary
            } else {
                newActivity = .unknown
            }
            
            if newActivity == .stationary && self.currentActivity != .stationary {
                self.stationaryStartTime = Date()
            } else if newActivity != .stationary {
                self.stationaryStartTime = nil
                self.inactivityMinutes = 0
            }
            
            self.currentActivity = newActivity
        }
    }
    
    private func startPedometerUpdates() {
        guard CMPedometer.isStepCountingAvailable() else { return }
        
        let startOfDay = Calendar.current.startOfDay(for: Date())
        
        pedometer.startUpdates(from: startOfDay) { [weak self] data, error in
            guard let self = self, let data = data else { return }
            
            DispatchQueue.main.async {
                let newSteps = Int(truncating: data.numberOfSteps)
                let oldProgres = self.stepProgressPercentage
                
                self.steps = newSteps
                
                let newProgress = self.stepProgressPercentage
                
                for milestone in self.milestones {
                    if newProgress >= milestone && oldProgres < milestone && self.lastMilestone < milestone {
                        self.lastMilestone = milestone
                        self.celebrateMilestone(milestone)
                        break
                    }
                }
            }
        }
    }
    
    private func startInactivityTimer() {
        inactivityTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            guard let self = self, let startTime = self.stationaryStartTime else { return }
            
            let minutes = Int(Date().timeIntervalSince(startTime) / 60)
            self.inactivityMinutes = minutes
            
            if minutes >= self.inactivityAlertMinutes {
                sendInactivityReminder()
            }
        }
    }
    
    private func sendInactivityReminder() {
        guard notificationEnabled else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Hey there!"
        content.body = "We noticed you've been inactive for a while. Take a break and move around!"
        
        let request = UNNotificationRequest(identifier: "inactivity-reminder\(Date().timeIntervalSince1970)", content: content, trigger: nil)
        
        UNUserNotificationCenter.current().add(request)
    }

    private func celebrateMilestone(_ milestone: Int) {
        let content = UNMutableNotificationContent()
        
        if milestone == 100 {
            content.title = "Congrats well done budy"
            content.body = "You have completed 100% of your goal"
        } else {
            content.title = "Congrat"
            content.body = "You have completed \(milestone)% of your goal"
        }
        
        let request = UNNotificationRequest(identifier: "milestone \(milestone)", content: content, trigger: nil)
        
        UNUserNotificationCenter.current().add(request)
    }
}
