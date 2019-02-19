//
//  SpotifyController.swift
//  SendTrack
//
//  Created by Steve Lederer on 2/7/19.
//  Copyright © 2019 Steve Lederer. All rights reserved.
//

import Foundation

class SpotifyController {
    
    static let baseSpotifyURL = URL(string: "https://api.spotify.com")
    
    static func fetchSpotifySongs(withSearchTerm searchTerm: String, completion: @escaping ([SpotifySong]?) -> Void) {
        APITokenController.getSpotifyAccessToken { (bearerToken) in
            guard let spotifyBearerToken = bearerToken else { return }
            let spotifyBearer = "Bearer \(spotifyBearerToken)"
            
            guard let url = baseSpotifyURL?.appendingPathComponent("v1").appendingPathComponent("search") else { completion(nil) ; return }
            
            var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
            let searchTermQueryItem = URLQueryItem(name: "q", value: searchTerm)
            let typeQueryItem = URLQueryItem(name: "type", value: "track")
            components?.queryItems = [searchTermQueryItem, typeQueryItem]
            
            guard let requestURL = components?.url else { completion(nil) ; return }
            
            let headers = ["Authorization" : spotifyBearer]
            
            var request = URLRequest(url: requestURL,
                                     timeoutInterval: 10.0)
            request.allHTTPHeaderFields = headers
            
            let session = URLSession.shared
            let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
                if let error = error {
                    print("❌ There was an error in \(#function) ; \(error.localizedDescription) ❌")
                    completion(nil) ; return
                }
                
//                guard let httpResponse = response as? HTTPURLResponse else { completion(nil) ; return }
//                print(httpResponse as Any)
                
                guard let data = data else { completion(nil) ; return }
                
                do {
                    let topLevelDictionary = try JSONDecoder().decode(SpotifyTrack.self, from: data)
                    let songs = topLevelDictionary.tracks.spotifySongs
                    completion(songs)
                } catch {
                    print("❌ There was an error in \(#function) ; \(error.localizedDescription)❌")
                    completion(nil) ; return
                }
            })
            dataTask.resume()
        }
    }
    
    static func fetchSpotifySong(fromSpotifyLink spotifyLink: String, completion: @escaping (SpotifySong?) -> Void) {
        // incoming link format: https://open.spotify.com/track/7z0JDE4w67HXt5lEWsU2Hj?si=C450BIAmTCmiFoWe-eGeuA
        APITokenController.getSpotifyAccessToken { (bearerToken) in
            guard let spotifyBearerToken = bearerToken else { return }
            let spotifyBearer = "Bearer \(spotifyBearerToken)"
            
            guard let incomingURL = URL(string: spotifyLink) else { return }
            let spotifyID = incomingURL.lastPathComponent
            
            guard let url = baseSpotifyURL?.appendingPathComponent("v1").appendingPathComponent("tracks").appendingPathComponent(spotifyID) else { completion(nil) ; return }
            
            print(url)
            
            let components = URLComponents(url: url, resolvingAgainstBaseURL: true)
            
            guard let requestURL = components?.url else { completion(nil) ; return }
            
            let headers = ["Authorization" : spotifyBearer]
            
            var request = URLRequest(url: requestURL,
                                     timeoutInterval: 10.0)
            request.allHTTPHeaderFields = headers
            
            let session = URLSession.shared
            let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
                if let error = error {
                    print("❌ There was an error in \(#function) ; \(error.localizedDescription) ❌")
                    completion(nil) ; return
                }
                
//                guard let httpResponse = response as? HTTPURLResponse else { completion(nil) ; return }
//                print(httpResponse as Any)
                
                guard let data = data else { completion(nil) ; return }
                
                do {
                    let song = try JSONDecoder().decode(SpotifySong.self, from: data)
                    completion(song)
                } catch {
                    print("❌ There was an error in \(#function) ; \(error.localizedDescription)❌")
                    completion(nil) ; return
                }
            })
            dataTask.resume()
        }
        
    }
    
    static func matchSpotifySong(byISRC isrc: String, completion: @escaping ([SpotifySong]?) -> Void) {
        APITokenController.getSpotifyAccessToken { (bearerToken) in
            guard let spotifyBearerToken = bearerToken else { return }
            let spotifyBearer = "Bearer \(spotifyBearerToken)"
            
            guard let url = baseSpotifyURL?.appendingPathComponent("v1").appendingPathComponent("search") else { completion(nil) ; return }
            
            var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
            let typeQueryItem = URLQueryItem(name: "type", value: "track")
            let isrcQueryItem = URLQueryItem(name: "q", value: "isrc:\(isrc)")
            components?.queryItems = [typeQueryItem, isrcQueryItem]
            
            guard let requestURL = components?.url else { completion(nil) ; return }
            
            let headers = ["Authorization" : spotifyBearer]
            
            var request = URLRequest(url: requestURL,
                                     timeoutInterval: 10.0)
            request.allHTTPHeaderFields = headers
            
            let session = URLSession.shared
            let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
                if let error = error {
                    print("❌ There was an error in \(#function) ; \(error.localizedDescription) ❌")
                    completion(nil) ; return
                }
                
//                guard let httpResponse = response as? HTTPURLResponse else { completion(nil) ; return }
//                print(httpResponse as Any)
                
                guard let data = data else { completion(nil) ; return }
                
                do {
                    let topLevelDictionary = try JSONDecoder().decode(SpotifyTrack.self, from: data)
                    let songs = topLevelDictionary.tracks.spotifySongs
                    completion(songs)
                } catch {
                    print("❌ There was an error in \(#function) ; \(error.localizedDescription)❌")
                    completion(nil) ; return
                }
            })
            dataTask.resume()
        }
    }
    
    static func matchSpotifySong(bySongName songName: String, artistName: String, albumName: String, completion: @escaping ([SpotifySong]?) -> Void) {
        APITokenController.getSpotifyAccessToken { (bearerToken) in
            guard let spotifyBearerToken = bearerToken else { return }
            let spotifyBearer = "Bearer \(spotifyBearerToken)"
            
            guard let url = baseSpotifyURL?.appendingPathComponent("v1").appendingPathComponent("search") else { completion(nil) ; return }
            
            var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
            let searchTerm = "album:\"\(albumName)\" artist:\"\(artistName)\" track:\"\(songName)\""
            let searchTermQueryItem = URLQueryItem(name: "q", value: searchTerm)
            let typeQueryItem = URLQueryItem(name: "type", value: "track")
            components?.queryItems = [searchTermQueryItem, typeQueryItem]
            
            guard let requestURL = components?.url else { completion(nil) ; return }
            print("😱😱😱😱 URL to inspect: \(requestURL.absoluteString)")
            
            let headers = ["Authorization" : spotifyBearer]
            
            var request = URLRequest(url: requestURL,
                                     timeoutInterval: 10.0)
            request.allHTTPHeaderFields = headers
            
            let session = URLSession.shared
            let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
                if let error = error {
                    print("❌ There was an error in \(#function) ; \(error.localizedDescription) ❌")
                    completion(nil) ; return
                }
                
//                guard let httpResponse = response as? HTTPURLResponse else { completion(nil) ; return }
//                print(httpResponse as Any)
                
                guard let data = data else { completion(nil) ; return }
                
                do {
                    let topLevelDictionary = try JSONDecoder().decode(SpotifyTrack.self, from: data)
                    let songs = topLevelDictionary.tracks.spotifySongs
                    completion(songs)
                } catch {
                    print("❌ There was an error in \(#function) ; \(error.localizedDescription)❌")
                    completion(nil) ; return
                }
            })
            dataTask.resume()
        }
    }
    
}
