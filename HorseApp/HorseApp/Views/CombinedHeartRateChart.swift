import SwiftUI
import Charts

struct CombinedHeartRateChart: View {
    @ObservedObject var dualMonitorManager = DualMonitorManager.shared
    
    var currentHumanHeartRate: String {
        if let lastMeasurement = dualMonitorManager.humanMeasurements.last {
            return "\(Int(lastMeasurement.heartRate)) BPM"
        }
        return "-- BPM"
    }
    
    var currentHorseHeartRate: String {
        if let lastMeasurement = dualMonitorManager.horseMeasurements.last {
            return "\(Int(lastMeasurement.heartRate)) BPM"
        }
        return "-- BPM"
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Human Chart
            ZStack {
                Chart {
                    ForEach(dualMonitorManager.humanMeasurements, id: \.timestamp) { measurement in
                        LineMark(
                            x: .value("Time", measurement.timestamp),
                            y: .value("BPM", measurement.heartRate)
                        )
                        .foregroundStyle(.blue)
                        .interpolationMethod(.linear)
                    }
                }
                .chartYScale(domain: 40...200)
                .frame(height: 150)
                
                VStack {
                    HStack {
                        Text("Human")
                            .font(.caption)
                            .foregroundColor(.blue)
                        Spacer()
                        Text(currentHumanHeartRate)
                            .font(.title2)
                            .bold()
                            .foregroundColor(.blue)
                    }
                    .padding(8)
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(8)
                    Spacer()
                }
            }
            .background(Color.white.opacity(0.5))
            .cornerRadius(8)
            
            // Horse Chart
            ZStack {
                Chart {
                    ForEach(dualMonitorManager.horseMeasurements, id: \.timestamp) { measurement in
                        LineMark(
                            x: .value("Time", measurement.timestamp),
                            y: .value("BPM", measurement.heartRate)
                        )
                        .foregroundStyle(.red)
                        .interpolationMethod(.linear)
                    }
                }
                .chartYScale(domain: 40...200)
                .frame(height: 150)
                
                VStack {
                    HStack {
                        Text("Horse")
                            .font(.caption)
                            .foregroundColor(.red)
                        Spacer()
                        Text(currentHorseHeartRate)
                            .font(.title2)
                            .bold()
                            .foregroundColor(.red)
                    }
                    .padding(8)
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(8)
                    Spacer()
                }
            }
            .background(Color.white.opacity(0.5))
            .cornerRadius(8)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
} 
