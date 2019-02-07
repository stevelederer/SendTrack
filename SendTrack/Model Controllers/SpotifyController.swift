//
//  SpotifyController.swift
//  SendTrack
//
//  Created by Steve Lederer on 2/7/19.
//  Copyright © 2019 Steve Lederer. All rights reserved.
//

import Foundation


//    static func fetchSpotifySongs(with searchTerm: String, completion: @escaping ([SpotifyTrack]?) -> Void) {
//        guard let url = baseSpotifyURL?.appendingPathComponent("v1").appendingPathComponent("search") else { completion(nil) ; return }
//        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
//        let searchTermQueryItem = URLQueryItem(name: "q", value: searchTerm)
//        let typeQueryItem = URLQueryItem(name: "type", value: "track")
//        components?.queryItems = [searchTermQueryItem, typeQueryItem]
//
//        guard let requestURL = components?.url else { completion(nil) ; return }
//
//        let headers = [
//            "Authorization" : "Bearer \(spotifyToken)",
//        ]
//
//
//        print("📡📡📡 Spotify URL: \(requestURL.absoluteString)")
//
//        let request = URLRequest(url: requestURL)
//
//
//    }
