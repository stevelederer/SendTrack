//
//  SpotifyTrack.swift
//  SendTrack
//
//  Created by Steve Lederer on 2/6/19.
//  Copyright © 2019 Steve Lederer. All rights reserved.
//

import Foundation

struct SpotifyTrack: Codable { // TOP LEVEL DICTIONARY
    let tracks: Tracks
    
    enum CodingKeys: String, CodingKey {
        case tracks = "tracks"
    }
}

struct Tracks: Codable {
    let href: String
    let spotifySongs: [SpotifySong]
    let limit: Int
    let next: String?
    let offset: Int
    let previous: String?
    let total: Int
    
    enum CodingKeys: String, CodingKey {
        case href
        case spotifySongs = "items"
        case limit
        case next
        case offset
        case previous
        case total
    }
}

struct SpotifySong: Codable {
    let album: Album
    let artists: [Artist]
    let externalIds: ExternalIds // THIS IS LOCATION OF ISRC ID
    let externalUrls: ExternalUrls
    let songSpotifyHREF: String
    let songSpotifyID: String
    let songName: String
    let songSpotifyPreviewUrl: String?
    let type: ItemType
    let songSpotifyURI: String
    
    enum CodingKeys: String, CodingKey {
        case album
        case artists
        case externalIds = "external_ids" // THIS IS LOCATION OF ISRC ID
        case externalUrls = "external_urls"
        case songSpotifyHREF = "href"
        case songSpotifyID = "id"
        case songName = "name"
        case songSpotifyPreviewUrl = "preview_url"
        case type
        case songSpotifyURI = "uri"
    }
}

struct Album: Codable {
    let albumType: AlbumType
    let artists: [Artist]
    let externalUrls: ExternalUrls
    let albumSpotifyHREF: String
    let albumSpotifyID: String
    let images: [Image]
    let albumName: String
    let type: AlbumType
    let albumSpotifyURI: String
    
    enum CodingKeys: String, CodingKey {
        case albumType = "album_type"
        case artists
        case externalUrls = "external_urls"
        case albumSpotifyHREF = "href"
        case albumSpotifyID = "id"
        case images
        case albumName = "name"
        case type
        case albumSpotifyURI = "uri"
    }
}

enum AlbumType: String, Codable {
    case album = "album"
    case compilation = "compilation"
    case single = "single"
}

struct Artist: Codable {
    let externalUrls: ExternalUrls
    let artistSpotifyHREF: String
    let artistSpotifyID: String
    let artistName: String
    let artistSpotifyURI: String
    
    enum CodingKeys: String, CodingKey {
        case externalUrls = "external_urls"
        case artistSpotifyHREF = "href"
        case artistSpotifyID = "id"
        case artistName = "name"
        case artistSpotifyURI = "uri"
    }
}

struct ExternalUrls: Codable {
    let spotifyLink: String
    
    enum CodingKeys: String, CodingKey {
        case spotifyLink = "spotify"
    }
}

struct Image: Codable {
    let height: Int
    let url: String
    let width: Int
    
    enum CodingKeys: String, CodingKey {
        case height
        case url
        case width
    }
}

struct ExternalIds: Codable { // VERY IMPORTANT FOR COMPARISON
    let songRecordingCode: String
    
    enum CodingKeys: String, CodingKey {
        case songRecordingCode = "isrc"
    }
}

enum ItemType: String, Codable {
    case track = "track"
}
