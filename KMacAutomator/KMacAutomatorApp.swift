//
//  KMacAutomatorApp.swift
//  KMacAutomator
//
//  Created by MysteryM1 on 25/12/25.
//

import SwiftUI
import AppKit
import ApplicationServices
import CoreGraphics

@main
struct KMacAutomatorApp: App {
    @StateObject private var menubarManager = MenubarManager()
    
    init() {
        checkAccessibilityPermissions()
    }
    
    var body: some Scene {
        WindowGroup {
        }
        .commands {
            CommandGroup(replacing: .appSettings) {
                EmptyView()
            }
        }
        .defaultLaunchBehavior(.suppressed)
    }
    
    private func checkAccessibilityPermissions() {
        // Request permissions - this will make the app appear in Accessibility settings
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
        let accessEnabled = AXIsProcessTrustedWithOptions(options as CFDictionary)
        
        // Also try to create a CGEvent to trigger the system to show the app in Accessibility settings
        // This helps ensure the app appears in the list even if permissions aren't granted yet
        if !accessEnabled {
            // Attempt to create an event source - this will help trigger the permission system
            // to recognize the app and add it to the Accessibility list
            _ = CGEventSource(stateID: .hidSystemState)
            
            // Try to create a dummy event (won't post without permissions, but helps trigger the system)
            let mouseLocation = NSEvent.mouseLocation
            _ = CGEvent(mouseEventSource: nil, 
                       mouseType: .leftMouseDown, 
                       mouseCursorPosition: CGPoint(x: mouseLocation.x, y: mouseLocation.y), 
                       mouseButton: .left)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                showAccessibilityAlert()
            }
        }
    }
    
    private func showAccessibilityAlert() {
        let alert = NSAlert()
        alert.messageText = "Accessibility Permission Required"
        alert.informativeText = "This app needs Accessibility permissions to automate mouse clicks. Please enable it in System Settings > Privacy & Security > Accessibility."
        alert.alertStyle = .informational
        alert.addButton(withTitle: "Open System Settings")
        alert.addButton(withTitle: "Cancel")
        
        if alert.runModal() == .alertFirstButtonReturn {
            if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
                NSWorkspace.shared.open(url)
            }
        }
    }
}
