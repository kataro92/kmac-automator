//
//  Settings.swift
//  KMacAutomator
//
//  Created by MysteryM1 on 25/12/25.
//

import Foundation
import SwiftUI
import Combine

class Settings: ObservableObject {
    @Published var startAfter: Double = 2.0  // seconds
    @Published var duration: Double = 3.0   // seconds
    @Published var clickInterval: Double = 360.0  // milliseconds
    @Published var clickDelay: Double = 10.0  // milliseconds
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Observe clickInterval changes and auto-adjust clickDelay if needed
        $clickInterval
            .sink { [weak self] newInterval in
                guard let self = self else { return }
                if newInterval < self.clickDelay {
                    self.clickDelay = newInterval - 1
                }
                if self.clickDelay <= 0 {
                    self.clickDelay = 1
                }
            }
            .store(in: &cancellables)
    }
    
    var startAfterSeconds: TimeInterval {
        startAfter
    }
    
    var durationSeconds: TimeInterval {
        duration
    }
    
    var clickIntervalSeconds: TimeInterval {
        clickInterval / 1000.0
    }
    
    var clickDelaySeconds: TimeInterval {
        clickDelay / 1000.0
    }
}

