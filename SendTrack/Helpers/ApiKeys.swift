//
//  ApiKeys.swift
//  SendTrack
//
//  Created by Steve Lederer on 2/6/19.
//  Copyright © 2019 Steve Lederer. All rights reserved.
//

import Foundation

extension String {
    
    func toBase64() -> String? {
        guard let data = self.data(using: String.Encoding.utf8) else { return nil }
        return data.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0))
    }
    
//    func fromBase64() -> String? {
//        guard let data = Data(base64Encoded: self, options: Data.Base64DecodingOptions(rawValue: 0)) else { return nil }
//        return String(data: data, encoding: String.Encoding.utf8)
//    }
    
}

func getSpotifyBasicAPIKey() -> String? {
    guard let filePath = Bundle.main.path(forResource: "APIKeys", ofType: "plist") else { return nil }
    let plist = NSDictionary(contentsOfFile: filePath)
    guard let clientID: String = plist?.object(forKey: "SpotifyClientID") as? String,
        let clientSecret: String = plist?.object(forKey: "SpotifyClientSecret") as? String,
        let basicAPIKeyBase64: String = ("\(clientID):\(clientSecret)").toBase64() else { return nil }

    return basicAPIKeyBase64
}

func getAppleMusicID(for key: AppleIDs) -> String? {
    guard let filePath = Bundle.main.path(forResource: "APIKeys", ofType: "plist") else { return nil }
    let plist = NSDictionary(contentsOfFile: filePath)
    guard let appleMusicID: String = plist?.object(forKey: key) as? String else { return nil }
    return appleMusicID
}

enum AppleIDs: String {
    case keyID = "AppleMusicKeyID"
    case teamID = "AppleMusicTeamID"
}
