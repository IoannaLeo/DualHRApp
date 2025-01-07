import Foundation
import SwiftUI

struct AirQualityData: Codable {
    let aqi: Int
    
    var qualityLevel: String {
        switch aqi {
        case 1: return "Good"
        case 2: return "Fair"
        case 3: return "Moderate"
        case 4: return "Poor"
        case 5: return "Very Poor"
        default: return "Unknown"
        }
    }
    
    var color: Color {
        switch aqi {
        case 1: return .green
        case 2: return .blue
        case 3: return .yellow
        case 4: return .orange
        case 5: return .red
        default: return .gray
        }
    }
}

struct AirQualityResponse: Codable {
    let list: [AirQualityList]
}

struct AirQualityList: Codable {
    let main: AirQualityMain
}

struct AirQualityMain: Codable {
    let aqi: Int
} 