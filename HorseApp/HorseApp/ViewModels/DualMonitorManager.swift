import Foundation
import SwiftUI

class DualMonitorManager: ObservableObject {
    static let shared = DualMonitorManager()
    
    @Published var isMeasuring = false
    @Published var humanMeasurements: [(timestamp: Date, heartRate: Double)] = []
    @Published var horseMeasurements: [(timestamp: Date, heartRate: Double)] = []
    
    func startMeasuring() {
        humanMeasurements.removeAll()
        horseMeasurements.removeAll()
        isMeasuring = true
    }
    
    func stopMeasuring() {
        isMeasuring = false
    }
    
    func addMeasurement(heartRate: Double, fromMonitor: String) {
        guard isMeasuring else { return }
        
        let now = Date()
        
        DispatchQueue.main.async {
            if fromMonitor == "Heart Rate Human" {
                self.humanMeasurements.append((timestamp: now, heartRate: heartRate))
                let thirtySecondsAgo = now.addingTimeInterval(-30)
                self.humanMeasurements.removeAll { $0.timestamp < thirtySecondsAgo }
            } else if fromMonitor == "Heart Rate Horse" {
                self.horseMeasurements.append((timestamp: now, heartRate: heartRate))
                let thirtySecondsAgo = now.addingTimeInterval(-30)
                self.horseMeasurements.removeAll { $0.timestamp < thirtySecondsAgo }
            }
        }
    }
} 