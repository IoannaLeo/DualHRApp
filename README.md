# Dual Heart Rate Monitor

A SwiftUI application that allows simultaneous monitoring of two Polar heart rate sensors. Perfect for comparing heart rates between two subjects or monitoring dual heart rate measurements.

## Features

- Simultaneous connection to two Polar heart rate monitors
- Real-time heart rate monitoring
- Individual connection management for each monitor
- Live heart rate visualization with separate charts
- Automatic reconnection to previously connected devices
- Clean and intuitive user interface

## Requirements

- iOS 16.0+
- Xcode 14.0+
- Two Polar heart rate monitors (H7, H10, or compatible models)
- Device with Bluetooth 4.0+ capability

## Installation

1. Clone this repository
2. Open the project in Xcode
3. Build and run the application on your iOS device

## Usage

1. Launch the application
2. For each monitor:
   - Tap "Scan" to search for available Polar devices
   - Select your device from the list to connect
   - Wait for the connection to establish (indicated by green status)
3. Once both monitors are connected, tap "Start Measuring"
4. The app will display real-time heart rate data for both monitors
5. Tap "Stop Measuring" to end the session

## Technical Details

- Built with SwiftUI and Combine
- Uses Core Bluetooth for BLE communication
- Implements the Bluetooth Heart Rate Service (0x180D)
- Supports background reconnection
- Real-time data visualization using Swift Charts

## Project Structure

  HorseApp/
├── Models/
│ ├── PolarData.swift
│ └── Services/
│ └── PolarService.swift
├── ViewModels/
│ ├── PolarViewModel.swift
│ └── DualMonitorManager.swift
└── Views/
├── PolarView.swift
└── CombinedHeartRateChart.swift


## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

