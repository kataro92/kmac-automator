//
//  AutomationController.swift
//  KMacAutomator
//
//  Created by MysteryM1 on 25/12/25.
//

import Foundation
import AppKit
import CoreGraphics
import Combine
import ApplicationServices

enum AutomationState {
    case idle
    case waiting
    case running
    case completed
}

class AutomationController: ObservableObject {
    @Published var state: AutomationState = .idle
    @Published var timeRemaining: TimeInterval = 0.0
    
    private var startDelayTimer: Timer?
    private var clickTimer: Timer?
    private var durationTimer: Timer?
    private var settings: Settings?
    private var startTime: Date?
    
    func start(settings: Settings) {
        guard state == .idle || state == .completed else { return }
        
        // Check accessibility permissions before starting
        guard hasAccessibilityPermissions() else {
            requestAccessibilityPermissions()
            return
        }
        
        self.settings = settings
        state = .waiting
        timeRemaining = settings.durationSeconds
        
        // Start delay timer
        startDelayTimer = Timer.scheduledTimer(withTimeInterval: settings.startAfterSeconds, repeats: false) { [weak self] _ in
            self?.beginClicking()
        }
    }
    
    static func hasAccessibilityPermissions() -> Bool {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: false]
        return AXIsProcessTrustedWithOptions(options as CFDictionary)
    }
    
    func hasAccessibilityPermissions() -> Bool {
        return Self.hasAccessibilityPermissions()
    }
    
    func requestAccessibilityPermissions() {
        // Request permissions by attempting to use accessibility features
        // This will trigger the system to show the app in Accessibility settings
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
        _ = AXIsProcessTrustedWithOptions(options as CFDictionary)
        
        // Also try to create a CGEvent - this helps trigger the permission system
        _ = CGEventSource(stateID: .hidSystemState)
        
        // Show alert to user
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.messageText = "Accessibility Permission Required"
            alert.informativeText = "KMacAutomator needs Accessibility permissions to automate mouse clicks.\n\nPlease enable it in System Settings > Privacy & Security > Accessibility, then try again."
            alert.alertStyle = .informational
            alert.addButton(withTitle: "Open System Settings")
            alert.addButton(withTitle: "OK")
            
            if alert.runModal() == .alertFirstButtonReturn {
                if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
                    NSWorkspace.shared.open(url)
                }
            }
        }
    }
    
    func stop() {
        startDelayTimer?.invalidate()
        clickTimer?.invalidate()
        durationTimer?.invalidate()
        
        startDelayTimer = nil
        clickTimer = nil
        durationTimer = nil
        
        state = .idle
        timeRemaining = 0.0
    }
    
    private func beginClicking() {
        guard let settings = settings else { return }
        
        state = .running
        startTime = Date()
        
        // Perform first click immediately
        performClick()
        
        // Set up click interval timer
        clickTimer = Timer.scheduledTimer(withTimeInterval: settings.clickIntervalSeconds, repeats: true) { [weak self] _ in
            self?.performClick()
        }
        
        // Set up duration timer
        durationTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self, let startTime = self.startTime else { return }
            let elapsed = Date().timeIntervalSince(startTime)
            let remaining = settings.durationSeconds - elapsed
            
            if remaining <= 0 {
                self.complete()
            } else {
                self.timeRemaining = remaining
            }
        }
    }
    
    private func performClick() {
        guard state == .running else { return }
        
        // Check permissions before attempting click
        guard hasAccessibilityPermissions() else {
            stop()
            requestAccessibilityPermissions()
            return
        }
        
        // Capture mouse position once to ensure clickDown and clickUp use the same position
        // NSEvent.mouseLocation uses Cocoa coordinate system (origin at bottom-left)
        // CGEvent uses Quartz coordinate system (origin at top-left)
        // We need to convert the y-coordinate by subtracting from screen height
        let mouseLocation = NSEvent.mouseLocation
        guard let mainScreen = NSScreen.main else { return }
        let screenHeight = mainScreen.frame.height
        
        // Convert from Cocoa (bottom-left origin) to Quartz (top-left origin)
        let cgLocation = CGPoint(x: mouseLocation.x, y: screenHeight - mouseLocation.y)
        
        // Create event source
        guard let eventSource = CGEventSource(stateID: .hidSystemState) else { return }
        
        // Create mouse down event at captured mouse position
        guard let clickDown = CGEvent(mouseEventSource: eventSource, 
                                     mouseType: .leftMouseDown, 
                                     mouseCursorPosition: cgLocation, 
                                     mouseButton: .left) else { return }
        
        // Explicitly set the location to ensure consistency
        clickDown.location = cgLocation
        
        // Post mouse down event
        clickDown.post(tap: .cghidEventTap)
        
        // Delay between mouse down and mouse up using RunLoop
        // This is better than Thread.sleep as it allows the run loop to process other events
        guard let settings = settings else { return }
        let futureDate = Date(timeIntervalSinceNow: settings.clickDelaySeconds)
        RunLoop.current.run(until: futureDate)
        
        // Create mouse up event using the same location
        // Create it from the clickDown event to ensure exact same position
        guard let clickUp = clickDown.copy() else { return }
        clickUp.type = .leftMouseUp
        // Explicitly set the location again to be absolutely sure
        clickUp.location = cgLocation
        
        clickUp.post(tap: .cghidEventTap)
    }
    
    private func complete() {
        stop()
        state = .completed
        
        // Reset to idle after a brief moment
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.state = .idle
        }
    }
}

