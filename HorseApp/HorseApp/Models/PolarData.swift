//
//  PolarData.swift
//  HorseApp
//
//  Created by Jorge Padilla on 2025-01-02.
//
import Foundation

struct HeartRatePoint: Identifiable, Codable {
    var id: UUID
    let heartRate: Double
    let timestamp: Date
    
    init(id: UUID = UUID(), heartRate: Double, timestamp: Date) {
        self.id = id
        self.heartRate = heartRate
        self.timestamp = timestamp
    }
}

struct PolarData {
    let heartRate: Double
    let timestamp: UInt64
    var measurements: [HeartRatePoint]
    
    static let zero = PolarData(
        heartRate: 0,
        timestamp: 0,
        measurements: []
    )
}
