//
//  SpotifyAccessToken.swift
//  SendTrack
//
//  Created by Steve Lederer on 2/6/19.
//  Copyright © 2019 Steve Lederer. All rights reserved.
//

import Foundation

struct TopLevelDictionary: Codable {
    let results: SpotifyAccessToken
}

struct SpotifyAccessToken: Codable {
    let accessToken: String
    let tokenType: String
    let expiresIn: TimeInterval
    let scope: String
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case expiresIn = "expires_in"
        case scope = "scope"
    }
}
