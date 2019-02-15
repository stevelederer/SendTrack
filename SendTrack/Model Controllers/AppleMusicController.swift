//
//  AppleMusicController.swift
//  SendTrack
//
//  Created by Steve Lederer on 2/7/19.
//  Copyright © 2019 Steve Lederer. All rights reserved.
//

import UIKit

class AppleMusicController {
    
    static let baseAppleMusicURL = URL(string: "https://api.music.apple.com")
    
    static var thumbnailImageCache: NSCache<NSString, UIImage> = NSCache()
    
    static func fetchAppleMusicSongs(with searchTerm: String, completion: @escaping ([AppleMusicSong]?) -> Void) {
        guard let appleMusicToken = APITokenController.getAppleMusicAccessToken() else { return }
        let appleMusicBearer = "Bearer \(appleMusicToken)"
        
        guard let url = baseAppleMusicURL?.appendingPathComponent("v1").appendingPathComponent("catalog").appendingPathComponent("US").appendingPathComponent("search") else { completion(nil) ; return }
        
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        let searchTermQueryItem = URLQueryItem(name: "term", value: searchTerm)
        let typesQueryItem = URLQueryItem(name: "types", value: "songs")
        let limitQueryItem = URLQueryItem(name: "limit", value: "20")
        components?.queryItems = [searchTermQueryItem, typesQueryItem, limitQueryItem]
        
        guard let requestURL = components?.url else { completion(nil) ; return }
        
        let headers = ["Authorization" : appleMusicBearer]
        
        var request = URLRequest(url: requestURL,
                                 timeoutInterval: 10.0)
        request.allHTTPHeaderFields = headers
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
            if let error = error {
                print("❌ There was an error in \(#function) ; \(error.localizedDescription) ❌")
                completion(nil) ; return
            }
            
//            guard let httpResponse = response as? HTTPURLResponse else { completion(nil) ; return }
//            print(httpResponse as Any)
            
            guard let data = data else { completion(nil) ; return }
            
            do {
                let topLevelDictionary = try JSONDecoder().decode(AppleTrack.self, from: data)
                let songs = topLevelDictionary.results.appleSongResults.data
                completion(songs)
            } catch {
                print("❌ There was an error in \(#function) ; \(error.localizedDescription)❌")
                completion(nil) ; return
            }
        })
        dataTask.resume()
    }
    
    static func fetchAppleMusicTopCharts(completion: @escaping ([AppleMusicSong]?) -> Void) {
        guard let appleMusicToken = APITokenController.getAppleMusicAccessToken() else { return }
        let appleMusicBearer = "Bearer \(appleMusicToken)"
        
        guard let url = baseAppleMusicURL?.appendingPathComponent("v1").appendingPathComponent("catalog").appendingPathComponent("US").appendingPathComponent("charts") else { completion(nil) ; return }
        
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        let typesQueryItem = URLQueryItem(name: "types", value: "songs")
        components?.queryItems = [typesQueryItem]
        
        guard let requestURL = components?.url else { completion(nil) ; return }
        
        let headers = ["Authorization" : appleMusicBearer]
        
        var request = URLRequest(url: requestURL,
                                 timeoutInterval: 10.0)
        request.allHTTPHeaderFields = headers
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
            if let error = error {
                print("❌ There was an error in \(#function) ; \(error.localizedDescription) ❌")
                completion(nil) ; return
            }
            
            //            guard let httpResponse = response as? HTTPURLResponse else { completion(nil) ; return }
            //            print(httpResponse as Any)
            
            guard let data = data else { completion(nil) ; return }
            
            do {
                let topLevelDictionary = try JSONDecoder().decode(AppleTopTrack.self, from: data)
                let songs = topLevelDictionary.chartResults.appleTopSongResults
                var fetchedTopSongs: [AppleMusicSong] = []
                for item in songs {
                    let songs = item.data
                    for data in songs {
                        fetchedTopSongs.append(data)
                    }
                }
                completion(fetchedTopSongs)
            } catch {
                print("❌ There was an error in \(#function) ; \(error.localizedDescription)❌")
                completion(nil) ; return
            }
        })
        dataTask.resume()
    }
    
    static func fetchAppleMusicSong(fromAppleMusicLink appleLink: String, completion: @escaping (AppleMusicSong?) -> Void) {
        
        // incoming link format: https://itunes.apple.com/us/album/strawberry-bubblegum/1441493446?i=1441493594
        guard let appleMusicToken = APITokenController.getAppleMusicAccessToken() else { return }
        let appleMusicBearer = "Bearer \(appleMusicToken)"
        
        guard let incomingURL = URL(string: appleLink),
            let appleMusicID = incomingURL.query?.replacingOccurrences(of: "i=", with: "") else { return }
        
        guard let url = baseAppleMusicURL?.appendingPathComponent("v1").appendingPathComponent("catalog").appendingPathComponent("US").appendingPathComponent("songs").appendingPathComponent(appleMusicID) else { completion(nil) ; return }
        
        print(url)
        
        let components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        
        guard let requestURL = components?.url else { completion(nil) ; return }
        
        let headers = ["Authorization" : appleMusicBearer]
        
        var request = URLRequest(url: requestURL,
                                 timeoutInterval: 10.0)
        request.allHTTPHeaderFields = headers
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
            if let error = error {
                print("❌ There was an error in \(#function) ; \(error.localizedDescription) ❌")
                completion(nil) ; return
            }
            
//                        guard let httpResponse = response as? HTTPURLResponse else { completion(nil) ; return }
//                        print(httpResponse as Any)
            
            guard let data = data else { completion(nil) ; return }
            
            do {
                let tld = try JSONDecoder().decode(Songs.self, from: data)
                let songs = tld.data
                let song = songs.first
                completion(song)
            } catch {
                print("❌ There was an error in \(#function) ; \(error.localizedDescription)❌")
                completion(nil) ; return
            }
        })
        dataTask.resume()
    }
    
    static func matchAppleMusicSong(byISRC isrc: String, completion: @escaping ([AppleMusicSong]?) -> Void) {
        guard let appleMusicToken = APITokenController.getAppleMusicAccessToken() else { return }
        let appleMusicBearer = "Bearer \(appleMusicToken)"
        
        guard let url = baseAppleMusicURL?.appendingPathComponent("v1").appendingPathComponent("catalog").appendingPathComponent("US").appendingPathComponent("songs") else { completion(nil) ; return }
        
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        let isrcQueryItem = URLQueryItem(name: "filter[isrc]", value: isrc)
        components?.queryItems = [isrcQueryItem]
        
        guard let requestURL = components?.url else { completion(nil) ; return }
        
        let headers = ["Authorization" : appleMusicBearer]
        
        var request = URLRequest(url: requestURL,
                                 timeoutInterval: 10.0)
        request.allHTTPHeaderFields = headers
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
            if let error = error {
                print("❌ There was an error in \(#function) ; \(error.localizedDescription) ❌")
                completion(nil) ; return
            }
            
            //            guard let httpResponse = response as? HTTPURLResponse else { completion(nil) ; return }
            //            print(httpResponse as Any)
            
            guard let data = data else { completion(nil) ; return }
            
            do {
                let tld = try JSONDecoder().decode(Songs.self, from: data)
                let songs = tld.data
                completion(songs)
            } catch {
                print("❌ There was an error in \(#function) ; \(error.localizedDescription)❌")
                completion(nil) ; return
            }
        })
        dataTask.resume()
    }
    
    static func fetchAppleSearchHints(with searchTerm: String, completion: @escaping ([String]?) -> Void) {
        guard let appleMusicToken = APITokenController.getAppleMusicAccessToken() else { return }
        let appleMusicBearer = "Bearer \(appleMusicToken)"
        
        guard let url = baseAppleMusicURL?.appendingPathComponent("v1").appendingPathComponent("catalog").appendingPathComponent("US").appendingPathComponent("search").appendingPathComponent("hints") else { completion(nil) ; return }
        
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        let searchTermQueryItem = URLQueryItem(name: "term", value: searchTerm)
        let typesQueryItem = URLQueryItem(name: "types", value: "songs")
        components?.queryItems = [searchTermQueryItem, typesQueryItem]
        
        guard let requestURL = components?.url else { completion(nil) ; return }
        
        let headers = ["Authorization" : appleMusicBearer]
        
        var request = URLRequest(url: requestURL,
                                 timeoutInterval: 10.0)
        request.allHTTPHeaderFields = headers
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
            if let error = error {
                print("❌ There was an error in \(#function) ; \(error.localizedDescription) ❌")
                completion(nil) ; return
            }
            
//            guard let httpResponse = response as? HTTPURLResponse else { completion(nil) ; return }
//            print(httpResponse as Any)
            
            guard let data = data else { completion(nil) ; return }
            
            do {
                let topLevelDictionary = try JSONDecoder().decode(AppleSearchHints.self, from: data)
                let hints = topLevelDictionary.results.terms
                completion(hints)
            } catch {
                print("❌ There was an error in \(#function) ; \(error.localizedDescription)❌")
                completion(nil) ; return
            }
        })
        dataTask.resume()
    }
    
    static func fetchAppleMusicArtwork(forSong song: SteveSong, withDimension dimension: Int, completion: @escaping (UIImage?) -> Void) {
        let dimensionComponent: String = "\(dimension)x\(dimension)bb.jpeg"
        guard let artworkPath = song.appleSongArtworkURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
            let artworkURL = URL(string: artworkPath)?.deletingLastPathComponent().appendingPathComponent(dimensionComponent) else { completion(nil) ; return }
        
        let request = URLRequest(url: artworkURL)
        
        URLSession.shared.dataTask(with: request) { (imageData, response, error) in
            if let error = error {
                print("❌ There was an error in \(#function) ; \(error.localizedDescription) ❌")
                completion(nil) ; return
            }
//            print(response ?? "no response for artwork url")
            
            guard let imageData = imageData else { completion(nil) ; return }
            
            let artworkImage = UIImage(data: imageData)
            
            completion(artworkImage)
        }.resume()
    }
    
}
