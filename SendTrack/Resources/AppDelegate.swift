//
//  AppDelegate.swift
//  SendTrack
//
//  Created by Steve Lederer on 2/6/19.
//  Copyright © 2019 Steve Lederer. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        checkPasteboard()
        return true
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        checkPasteboard()
    }
    
    func checkPasteboard() {
        guard  let pasteboardString = UIPasteboard.general.string else { return }
        if pasteboardString.contains("https://music.apple.com") && pasteboardString != UserDefaults.standard.string(forKey: "previousStringFromPasteboard") {
            // switch to search tab
            switchToSeachTab()
        } else if pasteboardString.contains("https://open.spotify.com/") && pasteboardString != UserDefaults.standard.string(forKey: "previousStringFromPasteboard") {
            // switch to search tab
            switchToSeachTab()
        }
    }
    
    func switchToSeachTab() {
        if let tabBarController = self.window?.rootViewController as? UITabBarController {
            tabBarController.selectedIndex = 1
        }
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        checkPasteboard()
    }

}
