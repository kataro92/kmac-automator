//
//  MenubarManager.swift
//  KMacAutomator
//
//  Created by MysteryM1 on 25/12/25.
//

import AppKit
import SwiftUI
import Combine

class MenubarManager: ObservableObject {
    private var statusItem: NSStatusItem?
    private var popover: NSPopover?
    private let settings = Settings()
    private let automationController = AutomationController()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupStatusItem()
        setupPopover()
        observeAutomationState()
    }
    
    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "cursorarrow.click", accessibilityDescription: "Mouse Automation")
            button.image?.isTemplate = true
            button.action = #selector(togglePopover)
            button.target = self
        }
    }
    
    private func setupPopover() {
        popover = NSPopover()
        popover?.contentSize = NSSize(width: 300, height: 200)
        popover?.behavior = .transient
        popover?.contentViewController = NSHostingController(
            rootView: SettingsView(settings: settings, automationController: automationController)
        )
    }
    
    @objc private func togglePopover() {
        guard let button = statusItem?.button else { return }
        
        if let popover = popover {
            if popover.isShown {
                popover.performClose(nil)
            } else {
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            }
        }
    }
    
    private func observeAutomationState() {
        automationController.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.updateStatusIcon(for: state)
            }
            .store(in: &cancellables)
    }
    
    private func updateStatusIcon(for state: AutomationState) {
        guard let button = statusItem?.button else { return }
        
        let iconName: String
        switch state {
        case .idle, .completed:
            iconName = "cursorarrow.click"
        case .waiting:
            iconName = "clock"
        case .running:
            iconName = "cursorarrow.click.2"
        }
        
        button.image = NSImage(systemSymbolName: iconName, accessibilityDescription: "Mouse Automation")
        button.image?.isTemplate = true
    }
}

