//
//  AppleMusicUserController.swift
//  SendTrack
//
//  Created by Steve Lederer on 2/16/19.
//  Copyright © 2019 Steve Lederer. All rights reserved.
//

import Foundation
import StoreKit

//
//
//class AppleMusicUserController: SKCloudServiceController {
//    
//    func getAuthorization() -> SKCloudServiceAuthorizationStatus {
//        var userStatus: SKCloudServiceAuthorizationStatus
//        SKCloudServiceController.requestAuthorization { (status: SKCloudServiceAuthorizationStatus) in
//            switch status {
//            case .authorized:
//                userStatus = .authorized
//            case .denied:
//                userStatus = .denied
//            case .restricted:
//                userStatus = .restricted
//            case .notDetermined:
//                userStatus = .notDetermined
//            }
//        }
//        return userStatus
//    }
//    
//    override func requestUserToken(forDeveloperToken developerToken: String, completionHandler: @escaping (String?, Error?) -> Void) {
//        <#code#>
//    }
//}
