//
//  SendTrackTabBarController.swift
//  SendTrack
//
//  Created by Steve Lederer on 2/19/19.
//  Copyright © 2019 Steve Lederer. All rights reserved.
//

import UIKit

class SendTrackTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
    }
}

extension SendTrackTabBarController: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        guard let fromView = selectedViewController?.view, let toView = viewController.view else {
            return false
        }
        
        if fromView != toView {
            UIView.transition(from: fromView, to: toView, duration: 0.3, options: .transitionCrossDissolve, completion: nil)
        }
        
        return true
    }
}
