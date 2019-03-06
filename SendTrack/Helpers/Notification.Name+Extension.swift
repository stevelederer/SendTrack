//
//  Notification.Name+Extension.swift
//  SendTrack
//
//  Created by Steve Lederer on 2/14/19.
//  Copyright © 2019 Steve Lederer. All rights reserved.
//

import Foundation

extension Notification.Name {
    static let playPauseButtonTappedNotification = Notification.Name("playPauseButtonTappedNotification")
    
    static let expandMessageView = Notification.Name("expandMessageView")
    
    static let messageViewIsExpanded = Notification.Name("messageViewIsExpanded")
    
    static let playerTimeChangeNotification = Notification.Name("playerTimeChangeNotification")
}
