//
//  PolarView.swift
//  HorseApp
//
//  Created by Jorge Padilla on 2025-01-02.
//

import SwiftUI
import CoreBluetooth
import Charts

struct PolarView: View {
    @StateObject private var viewModel1 = PolarViewModel(monitorId: UUID(), monitorName: "Heart Rate Human")
    @StateObject private var viewModel2 = PolarViewModel(monitorId: UUID(), monitorName: "Heart Rate Horse")
    @ObservedObject private var dualMonitorManager = DualMonitorManager.shared
    @StateObject private var airQualityService = AirQualityService()
    @StateObject private var locationManager = LocationManager()
    
    var body: some View {
        VStack {
            // Header con título y air quality
            HStack {
                Text("Dual HR App")
                    .font(.title)
                
                Spacer()
                
                // Air Quality Box
                VStack(alignment: .leading, spacing: 4) {
                    Text("Air Quality")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    if let airQuality = airQualityService.currentAirQuality {
                        HStack(spacing: 8) {
                            Circle()
                                .fill(airQuality.color)
                                .frame(width: 10, height: 10)
                            
                            Text(airQuality.qualityLevel)
                                .font(.subheadline)
                                .bold()
                        }
                    } else {
                        Text("Loading...")
                            .font(.subheadline)
                    }
                }
                .padding(8)
                .background(Color.white)
                .cornerRadius(8)
                .shadow(radius: 2)
            }
            .padding(.horizontal)
            
            HStack(spacing: 20) {
                // Human Monitor
                VStack {
                    Text("Human")
                        .font(.headline)
                    
                    monitorView(viewModel: viewModel1)
                }
                .frame(maxWidth: .infinity)
                
                Divider()
                
                // Horse Monitor
                VStack {
                    Text("Horse")
                        .font(.headline)
                    
                    monitorView(viewModel: viewModel2)
                }
                .frame(maxWidth: .infinity)
            }
            .padding()
            
            // Start/Stop Measuring Button
            Button(action: {
                if dualMonitorManager.isMeasuring {
                    dualMonitorManager.stopMeasuring()
                } else {
                    dualMonitorManager.startMeasuring()
                }
            }) {
                Text(dualMonitorManager.isMeasuring ? "Stop Measuring" : "Start Measuring")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        (viewModel1.isConnected && viewModel2.isConnected)
                        ? Color.green
                        : Color.gray
                    )
                    .cornerRadius(10)
            }
            .disabled(!viewModel1.isConnected || !viewModel2.isConnected)
            .padding(.horizontal)
            
            // Charts
            CombinedHeartRateChart()
            
            Spacer()
        }
        .task {
            // Solicitar ubicación inmediatamente al cargar la vista
            print("Requesting location permissions...")
            locationManager.requestLocation()
        }
        .onChange(of: locationManager.location) { newLocation in
            if let location = newLocation {
                print("Location updated: \(location.coordinate.latitude), \(location.coordinate.longitude)")
                airQualityService.fetchAirQuality(
                    latitude: location.coordinate.latitude,
                    longitude: location.coordinate.longitude
                )
            }
        }
        .onChange(of: locationManager.authorizationStatus) { status in
            print("Location authorization status changed: \(String(describing: status))")
            if status == .authorizedWhenInUse {
                locationManager.requestLocation()
            }
        }
    }
    
    @ViewBuilder
    private func monitorView(viewModel: PolarViewModel) -> some View {
        VStack {
            // Status Indicator
            Circle()
                .fill(viewModel.isConnected ? .green : .gray)
                .frame(width: 15, height: 15)
            
            // Connection Controls
            if !viewModel.isConnected {
                VStack(spacing: 10) {
                    Button(viewModel.isScanning ? "Stop Scan" : "Scan") {
                        if viewModel.isScanning {
                            viewModel.stopScanning()
                        } else {
                            viewModel.startScanning()
                        }
                    }
                    .buttonStyle(.bordered)
                    
                    // Device List
                    if viewModel.isScanning {
                        ScrollView {
                            VStack(spacing: 8) {
                                ForEach(viewModel.discoveredDevices, id: \.identifier) { device in
                                    Button(action: {
                                        viewModel.connect(to: device)
                                    }) {
                                        Text(device.name ?? "Unknown Device")
                                            .padding(8)
                                            .frame(maxWidth: .infinity)
                                            .background(Color.gray.opacity(0.1))
                                            .cornerRadius(8)
                                    }
                                }
                            }
                        }
                        .frame(maxHeight: 150)
                    }
                }
            } else {
                Button("Disconnect") {
                    viewModel.disconnect()
                }
                .buttonStyle(.bordered)
                .tint(.red)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.gray.opacity(0.1))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(viewModel.isConnected ? .green : .gray, lineWidth: 2)
        )
    }
}
