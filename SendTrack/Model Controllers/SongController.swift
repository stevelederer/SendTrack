//
//  SongController.swift
//  SendTrack
//
//  Created by Steve Lederer on 2/6/19.
//  Copyright © 2019 Steve Lederer. All rights reserved.
//

import Foundation

class SongController {
    static let baseSpotifyURL = URL(string: "https://api.spotify.com")
    static let baseAppleURL = URL(string: "https://api.music.apple.com")
    
    
    /**
     This function takes my clientID and clientSecret from the APIKeys.plist file and retrieves the Access Token needed for further interaction with the Spotify API.
     
     - Returns: This function completes with a string of the desired token
     */
    static func getSpotifyAccessToken(completion: @escaping(String?) -> Void) {
        guard let spotifyBasicAPIKey = spotifyBasicAPIKey() else { return }
        
        let headers = [
            "Authorization" : "Basic \(spotifyBasicAPIKey)",
            "Content-Type": "application/x-www-form-urlencoded",
            "cache-control": "no-cache",
            "Postman-Token": "f79e695c-5009-4abe-b128-2e8206060816"
        ]
        
        let body =
            "grant_type=client_credentials".data(using: .utf8)!
        
        var request = URLRequest(url: URL(string: "https://accounts.spotify.com/api/token")!,
                                 cachePolicy: .useProtocolCachePolicy,
                                 timeoutInterval: 10.0)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = body
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if let error = error {
                print(error.localizedDescription)
                completion(nil) ; return
            }
            print(response)
            
            guard let data = data else { completion(nil) ; return }
            do {
                guard let topLevelDictionary = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any],
                    let accessToken = topLevelDictionary["access_token"] as? String else { completion(nil) ; return }
                completion(accessToken)
            } catch {
                print("❌ There was an error in \(#function) ; \(error.localizedDescription)❌")
            }
        })
        
        dataTask.resume()
        
    }
    
    
    
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
}
