import Foundation
import CoreLocation

class AirQualityService: ObservableObject {
    private let apiKey = "9b2c97d5fe367e14fc2e50331f70770f"
    @Published var currentAirQuality: AirQualityData?
    
    func fetchAirQuality(latitude: Double, longitude: Double) {
        let urlString = "https://api.openweathermap.org/data/2.5/air_pollution?lat=\(latitude)&lon=\(longitude)&appid=\(apiKey)"
        print("Fetching air quality for location: \(latitude), \(longitude)")
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            if let error = error {
                print("Network error: \(error.localizedDescription)")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Status Code: \(httpResponse.statusCode)")
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            
            do {
                if let responseString = String(data: data, encoding: .utf8) {
                    print("Raw response: \(responseString)")
                }
                
                let response = try JSONDecoder().decode(AirQualityResponse.self, from: data)
                print("Received air quality data: \(response)")
                
                DispatchQueue.main.async {
                    if let aqi = response.list.first?.main.aqi {
                        self?.currentAirQuality = AirQualityData(aqi: aqi)
                        print("Updated air quality: \(aqi)")
                    }
                }
            } catch {
                print("Decoding error: \(error)")
                if let responseString = String(data: data, encoding: .utf8) {
                    print("Raw response: \(responseString)")
                }
            }
        }
        
        task.resume()
    }
} 