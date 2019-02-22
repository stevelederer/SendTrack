//
//  AutosearchTimer.swift
//  SendTrack
//
//  Created by Steve Lederer on 2/15/19.
//  Copyright © 2019 Steve Lederer. All rights reserved.
//

import Foundation

class AutosearchTimer {
    
    let shortInterval: TimeInterval
    let longInterval: TimeInterval
    let callback: () -> Void
    
    var shortTimer: Timer?
    var longTimer: Timer?
    
    enum Constants {
        // Autosearch at this interval (minimum) while typing
        static let longAutosearchDelay: TimeInterval = 2.0
        // Automatic search trigger after typing pauses for this length
        static let shortAutosearchDelay: TimeInterval = 0.75
    }
    
    init(short: TimeInterval = Constants.shortAutosearchDelay, long: TimeInterval = Constants.longAutosearchDelay, callback: @escaping () -> Void) {
        shortInterval = short
        longInterval = long
        self.callback = callback
    }
    
    func activate() {
        shortTimer?.invalidate()
        shortTimer = Timer.scheduledTimer(withTimeInterval: shortInterval, repeats: false)
            { [weak self] _ in self?.fire() }
        if longTimer == nil {
            longTimer = Timer.scheduledTimer(withTimeInterval: longInterval, repeats: false)
            { [weak self] _ in self?.fire() }
        }
    }
    
    func cancel() {
        shortTimer?.invalidate()
        longTimer?.invalidate()
        shortTimer = nil; longTimer = nil
    }
    
    private func fire() {
        cancel()
        callback()
    }
    
}
