//
//  ChartView.swift
//  HorseApp
//
//  Created by Jorge Padilla on 2025-01-02.
//

import SwiftUI
import Charts

struct ChartView: View {
    let measurements: [HeartRatePoint]
    
    var body: some View {
        VStack {
            Text("Heart Rate Measurements")
                .font(.title2)
            
            Chart(measurements) { point in
                LineMark(
                    x: .value("Time", point.timestamp),
                    y: .value("BPM", point.heartRate)
                )
                .foregroundStyle(.red)
            }
            .frame(width: 300, height: 200)
            .padding()
            .chartYScale(domain: 40...200)
            .chartXAxis {
                AxisMarks(values: .automatic(desiredCount: 5))
            }
        }
        .padding()
        .background(Color.white)
    }
} 