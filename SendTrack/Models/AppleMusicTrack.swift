//
//  AppleMusicTrack.swift
//  SendTrack
//
//  Created by Steve Lederer on 2/6/19.
//  Copyright © 2019 Steve Lederer. All rights reserved.
//

import Foundation

struct AppleTrack: Codable { // TOP LEVEL DICTIONARY
    let results: Results
    
    enum CodingKeys: String, CodingKey {
        case results = "results"
    }
}

struct AppleTopTrack: Codable {
    let chartResults: ChartResults
    
    enum CodingKeys: String, CodingKey {
        case chartResults = "results"
    }
}

struct Results: Codable {
    let appleSongResults: Songs
    
    enum CodingKeys: String, CodingKey {
        case appleSongResults = "songs"
    }
}

struct ChartResults: Codable {
    let appleTopSongResults: [TopSongs]
    
    enum CodingKeys: String, CodingKey {
        case appleTopSongResults = "songs"
    }
}

struct Songs: Codable {
    let href: String?
    let next: String?
    let data: [AppleMusicSong]
    
    enum CodingKeys: String, CodingKey {
        case href
        case next
        case data
    }
}

struct TopSongs: Codable {
    let href: String?
    let next: String?
    let data: [AppleMusicSong]
    
    enum CodingKeys: String, CodingKey {
        case href
        case next
        case data
    }
}

struct AppleMusicSong: Codable {
    let id: String
    let href: String
    let attributes: Attributes
    
    enum CodingKeys: String, CodingKey {
        case id
        case href
        case attributes
    }
}

struct Attributes: Codable {
    let previewURLs: [Preview]
    let artwork: Artwork
    let artistName: String
    let appleLink: String
    let songName: String
    let songRecordingCode: String // VERY IMPORTANT FOR COMPARISON
    let albumName: String
    
    enum CodingKeys: String, CodingKey {
        case previewURLs = "previews"
        case artwork
        case artistName
        case appleLink = "url"
        case songName = "name"
        case songRecordingCode = "isrc" // VERY IMPORTANT FOR COMPARISON
        case albumName
    }
}

struct Artwork: Codable {
    let width: Int
    let height: Int
    let appleArtworkURL: String
    let bgColor: String
    let textColor1: String
    let textColor2: String
    let textColor3: String
    let textColor4: String
    
    enum CodingKeys: String, CodingKey {
        case width
        case height
        case appleArtworkURL = "url"
        case bgColor
        case textColor1
        case textColor2
        case textColor3
        case textColor4
    }
}

struct Preview: Codable {
    let songApplePreviewURL: String
    
    enum CodingKeys: String, CodingKey {
        case songApplePreviewURL = "url"
    }
}

struct AppleSearchHints: Codable {
    let results: SearchHintResults
    
    enum CodingKeys: String, CodingKey {
        case results = "results"
    }
}

struct SearchHintResults: Codable {
    let terms: [String]
    
    enum CodingKeys: String, CodingKey {
        case terms = "terms"
    }
}

