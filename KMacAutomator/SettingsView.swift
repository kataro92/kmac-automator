//
//  SettingsView.swift
//  KMacAutomator
//
//  Created by MysteryM1 on 25/12/25.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var settings: Settings
    @ObservedObject var automationController: AutomationController
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Mouse Automation")
                .font(.headline)
                .padding(.bottom, 4)
            
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Start after:")
                    Spacer()
                    TextField("0", value: $settings.startAfter, format: .number)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 80)
                    Text("seconds")
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Duration:")
                    Spacer()
                    TextField("10", value: $settings.duration, format: .number)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 80)
                    Text("seconds")
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Click on each:")
                    Spacer()
                    TextField("1000", value: $settings.clickInterval, format: .number)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 80)
                    Text("ms")
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Click delay:")
                    Spacer()
                    TextField("10", value: $settings.clickDelay, format: .number)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 80)
                    Text("ms")
                        .foregroundColor(.secondary)
                }
            }
            
            Divider()
            
            // Status and control
            VStack(spacing: 8) {
                statusView
                
                Button(action: {
                    if automationController.state == .running || automationController.state == .waiting {
                        automationController.stop()
                    } else {
                        automationController.start(settings: settings)
                    }
                }) {
                    Text(buttonText)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }
        }
        .padding(20)
        .frame(width: 300)
    }
    
    private var statusView: some View {
        HStack {
            Circle()
                .fill(statusColor)
                .frame(width: 8, height: 8)
            Text(statusText)
                .font(.caption)
                .foregroundColor(.secondary)
            Spacer()
            if automationController.state == .running {
                Text(formatTime(automationController.timeRemaining))
                    .font(.caption)
                    .monospacedDigit()
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var statusColor: Color {
        switch automationController.state {
        case .idle, .completed:
            return .gray
        case .waiting:
            return .yellow
        case .running:
            return .green
        }
    }
    
    private var statusText: String {
        switch automationController.state {
        case .idle:
            return "Idle"
        case .waiting:
            return "Waiting to start..."
        case .running:
            return "Running"
        case .completed:
            return "Completed"
        }
    }
    
    private var buttonText: String {
        switch automationController.state {
        case .idle, .completed:
            return "Start"
        case .waiting, .running:
            return "Stop"
        }
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

