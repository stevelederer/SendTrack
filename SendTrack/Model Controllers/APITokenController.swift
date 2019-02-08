//
//  APITokenController.swift
//  SendTrack
//
//  Created by Steve Lederer on 2/6/19.
//  Copyright © 2019 Steve Lederer. All rights reserved.
//

import Foundation
import CupertinoJWT

class APITokenController {
    
    /**
     This function takes my SpotifyClientID and SpotifyClientSecret from the APIKeys.plist file and retrieves the Access Token needed for further interaction with the Spotify API.
     - Parameter completion: escapes with an optional string containing the Spotify token
     - Returns: Void
     */
    static func getSpotifyAccessToken(completion: @escaping(String?) -> Void) {
        
        if let bearerToken = fetchSpotifyBearerTokenLocally() {
            completion(bearerToken)
            return
        }
        
        guard let spotifyBasicAPIKey = getSpotifyBasicAPIKey() else { return }
        
        let headers = [
            "Authorization" : "Basic \(spotifyBasicAPIKey)",
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        
        let body =
            "grant_type=client_credentials".data(using: .utf8)!
        
        var request = URLRequest(url: URL(string: "https://accounts.spotify.com/api/token")!,
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
            
            if let response = response {
                print(response)
            }
            
            guard let data = data else { completion(nil) ; return }
            do {
                guard let topLevelDictionary = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any] else { completion(nil) ; return }
                let accessToken = topLevelDictionary["access_token"] as? String
                UserDefaults.standard.set(accessToken, forKey: "spotifyBearerToken")
                if let expirationTimeInterval = topLevelDictionary["expires_in"] as? TimeInterval {
                    let expirationDate = Date(timeIntervalSinceNow: expirationTimeInterval)
                    UserDefaults.standard.set(expirationDate, forKey: "spotifyTokenExpirationDate")
                }
                completion(accessToken)
            } catch {
                print("❌ There was an error in \(#function) ; \(error.localizedDescription)❌")
            }
        })
        
        dataTask.resume()
        
    }
    
    static func fetchSpotifyBearerTokenLocally() -> String? {
        guard let experationTime = UserDefaults.standard.value(forKey: "spotifyTokenExpirationDate") as? Date,
            experationTime > Date() else { return nil }
        return UserDefaults.standard.value(forKey: "spotifyBearerToken") as? String
    }
    
    /**
     This function takes my AppleMusicKeyID and AppleMusicTeamID from the APIKeys.plist file and creates the Access Token needed for further interaction with the AppleMusic API.
     
     - Returns: String?: Optional string containing the desired Apple Music token
     */
    static func getAppleMusicAccessToken() -> String? {
        
        if let bearerToken = fetchAppleMusicBearerTokenLocally() {
            return (bearerToken)
        }
        
        var privateKey: String?
        if let filePath = Bundle.main.path(forResource: "MusicKit", ofType: "p8") {
            do {
                let contents = try String(contentsOfFile: filePath)
                privateKey = contents
            } catch {
                print("❌ There was an error in \(#function) ; \(error.localizedDescription)❌")
            }
        } else {
            print("🚨 MusicKey.p8 file not found!")
        }
        
        guard let keyID = getAppleMusicID(for: .keyID),
            let teamID = getAppleMusicID(for: .teamID) else { return nil }
        let appleMusicJWT = JWT(keyID: keyID, teamID: teamID, issueDate: Date(), expireDuration: 15777000)
        do {
            guard let privateKey = privateKey else { return nil }
            let token = try appleMusicJWT.sign(with: privateKey)
            UserDefaults.standard.set(token, forKey: "appleMusicBearerToken")
            let expirationDate = Date(timeIntervalSinceNow: 15773400)
            UserDefaults.standard.set(expirationDate, forKey: "appleMusicTokenExpirationDate")
            return token
        } catch {
            print("❌ There was an error in \(#function) ; \(error.localizedDescription)❌")
        }
        return nil
    }
    
    static func fetchAppleMusicBearerTokenLocally() -> String? {
        guard let experationTime = UserDefaults.standard.value(forKey: "appleMusicTokenExpirationDate") as? Date,
            experationTime > Date() else { return nil }
        return UserDefaults.standard.value(forKey: "appleMusicBearerToken") as? String
    }
    
}
