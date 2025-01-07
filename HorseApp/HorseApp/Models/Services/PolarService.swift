//
//  PolarService.swift
//  HorseApp
//
//  Created by Jorge Padilla on 2025-01-02.
//

import CoreBluetooth

class PolarService: NSObject, ObservableObject {
    // Agregar identificador único para cada instancia
    let serviceId: UUID
    var heartRateCallback: ((Int) -> Void)?
    
    // Solo mantenemos los UUIDs necesarios para Heart Rate
    private let HEART_RATE_SERVICE_UUID = CBUUID(string: "180D")
    private let HEART_RATE_CHARACTERISTIC_UUID = CBUUID(string: "2A37")
    
    // Propiedades básicas
    private var centralManager: CBCentralManager?
    private var connectedPeripheral: CBPeripheral?
    private var heartRateCharacteristic: CBCharacteristic?
    private var lastConnectedPeripheral: CBPeripheral?
    
    // Published properties
    @Published private(set) var discoveredDevices: [CBPeripheral] = []
    @Published private(set) var isConnected = false
    @Published var sensorData = PolarData.zero
    @Published private(set) var isMeasuring = false
    @Published private(set) var isScanning = false
    
    override init() {
        self.serviceId = UUID()
        super.init()
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    // MARK: - Public Methods
    func startScanning() {
        guard centralManager?.state == .poweredOn else { return }
        discoveredDevices.removeAll()
        isScanning = true
        centralManager?.scanForPeripherals(
            withServices: [HEART_RATE_SERVICE_UUID],
            options: [CBCentralManagerScanOptionAllowDuplicatesKey: false]
        )
    }
    
    func stopScanning() {
        centralManager?.stopScan()
        isScanning = false
    }
    
    func connect(to peripheral: CBPeripheral) {
        centralManager?.connect(peripheral)
    }
    
    func disconnect() {
        if let peripheral = connectedPeripheral {
            centralManager?.cancelPeripheralConnection(peripheral)
            cleanupConnection()
        }
    }
    
    func reconnect() {
        if let peripheral = lastConnectedPeripheral {
            print("Intentando reconexión con dispositivo anterior")
            centralManager?.connect(peripheral)
        }
    }
    
    func startHeartRateMeasurement() {
        guard let characteristic = heartRateCharacteristic,
              let peripheral = connectedPeripheral else { return }
        
        peripheral.setNotifyValue(true, for: characteristic)
        isMeasuring = true
    }
    
    func stopHeartRateMeasurement() {
        guard let characteristic = heartRateCharacteristic,
              let peripheral = connectedPeripheral else { return }
        
        peripheral.setNotifyValue(false, for: characteristic)
        isMeasuring = false
    }
    
    // MARK: - Private Methods
    private func cleanupConnection() {
        heartRateCharacteristic = nil
        isConnected = false
        lastConnectedPeripheral = connectedPeripheral
        connectedPeripheral = nil
    }
}

// MARK: - CBCentralManagerDelegate
extension PolarService: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            print("Bluetooth is ready")
            if let peripheral = lastConnectedPeripheral {
                print("Intentando reconexión automática")
                centralManager?.connect(peripheral)
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                       advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if let name = peripheral.name, name.contains("Polar") {
            if !discoveredDevices.contains(where: { $0.identifier == peripheral.identifier }) {
                discoveredDevices.append(peripheral)
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        connectedPeripheral = peripheral
        peripheral.delegate = self
        isConnected = true
        peripheral.discoverServices([HEART_RATE_SERVICE_UUID])
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Dispositivo desconectado")
        cleanupConnection()
        
        if error != nil {
            print("Desconexión inesperada, intentando reconectar...")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                self?.reconnect()
            }
        }
    }
}

// MARK: - CBPeripheralDelegate
extension PolarService: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        
        for service in services {
            if service.uuid == HEART_RATE_SERVICE_UUID {
                print("Heart Rate Service encontrado")
                peripheral.discoverCharacteristics([HEART_RATE_CHARACTERISTIC_UUID], for: service)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        
        for characteristic in characteristics {
            if characteristic.uuid == HEART_RATE_CHARACTERISTIC_UUID {
                print("Heart Rate characteristic encontrado")
                heartRateCharacteristic = characteristic
                peripheral.setNotifyValue(true, for: characteristic)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let data = characteristic.value {
            // El primer byte contiene flags
            let flags = data[0]
            let isHeartRateValueFormat16Bit = (flags & 0x01) != 0
            
            // El valor del ritmo cardíaco está en el segundo byte (y tercer byte si es 16 bit)
            var heartRate: UInt16 = 0
            if isHeartRateValueFormat16Bit {
                // Si es formato 16-bit, combinar bytes 1 y 2
                heartRate = UInt16(data[1]) | (UInt16(data[2]) << 8)
            } else {
                // Si es formato 8-bit, solo usar byte 1
                heartRate = UInt16(data[1])
            }
            
            DispatchQueue.main.async {
                self.sensorData = PolarData(
                    heartRate: Double(heartRate),
                    timestamp: UInt64(Date().timeIntervalSince1970),
                    measurements: self.sensorData.measurements
                )
                self.heartRateCallback?(Int(heartRate))
            }
        }
    }
}
