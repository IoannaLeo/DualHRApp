//
//  PolarViewModel.swift
//  HorseApp
//
//  Created by Jorge Padilla on 2025-01-02.
//

import CoreBluetooth
import Combine
import SwiftUI
import Charts

class PolarViewModel: ObservableObject {
    private let polarService: PolarService
    let monitorId: UUID
    let monitorName: String
    private var cancellables = Set<AnyCancellable>()
    private let dualMonitorManager = DualMonitorManager.shared
    
    @Published var discoveredDevices: [CBPeripheral] = []
    @Published var isConnected = false
    @Published var sensorData = PolarData.zero
    @Published var isMeasuring = false
    @Published var measurements: [HeartRatePoint] = []
    
    var isScanning: Bool {
        polarService.isScanning
    }
    
    init(monitorId: UUID = UUID(), monitorName: String) {
        self.monitorId = monitorId
        self.monitorName = monitorName
        self.polarService = PolarService()
        
        polarService.heartRateCallback = { [weak self] heartRate in
            guard let self = self else { return }
            print("\(self.monitorName): \(heartRate) BPM")
            self.dualMonitorManager.addMeasurement(
                heartRate: Double(heartRate),
                fromMonitor: self.monitorName
            )
        }
        
        setupBindings()
    }
    
    func startScanning() {
        polarService.startScanning()
    }
    
    func stopScanning() {
        polarService.stopScanning()
    }
    
    func connect(to device: CBPeripheral) {
        polarService.connect(to: device)
    }
    
    func disconnect() {
        polarService.disconnect()
    }
    
    func reconnect() {
        polarService.reconnect()
    }
    
    func startMeasurement() {
        measurements = []
        isMeasuring = true
        polarService.startHeartRateMeasurement()
    }
    
    func stopMeasurement() {
        isMeasuring = false
        polarService.stopHeartRateMeasurement()
        saveMeasurements()
    }
    
    func exportToCSV() -> URL? {
        let csvString = "Timestamp,Heart Rate (BPM)\n" + measurements.map { 
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            return "\(dateFormatter.string(from: $0.timestamp)),\($0.heartRate)"
        }.joined(separator: "\n")
        
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        let fileName = "heart_rate_\(dateFormatter.string(from: Date())).csv"
        let fileURL = documentsPath.appendingPathComponent(fileName)
        
        do {
            try csvString.write(to: fileURL, atomically: true, encoding: .utf8)
            return fileURL
        } catch {
            print("Error saving CSV: \(error)")
            return nil
        }
    }
    
    @MainActor
    func generateChartImage() async -> UIImage? {
        let renderer = ImageRenderer(content: ChartView(measurements: measurements))
        renderer.scale = UIScreen.main.scale
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 segundos
        return renderer.uiImage
    }
    
    private func setupBindings() {
        polarService.$discoveredDevices
            .receive(on: RunLoop.main)
            .sink { [weak self] devices in
                self?.discoveredDevices = devices
            }
            .store(in: &cancellables)
        
        polarService.$isConnected
            .receive(on: RunLoop.main)
            .sink { [weak self] connected in
                self?.isConnected = connected
            }
            .store(in: &cancellables)
        
        polarService.$sensorData
            .receive(on: RunLoop.main)
            .sink { [weak self] data in
                self?.sensorData = data
                if self?.isMeasuring == true {
                    self?.measurements = data.measurements
                }
            }
            .store(in: &cancellables)
        
        polarService.$isMeasuring
            .receive(on: RunLoop.main)
            .sink { [weak self] measuring in
                self?.isMeasuring = measuring
            }
            .store(in: &cancellables)
    }
    
    private func saveMeasurements() {
        // Aquí implementaremos el guardado de datos
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(measurements) {
            UserDefaults.standard.set(data, forKey: "lastMeasurement")
        }
    }
}
