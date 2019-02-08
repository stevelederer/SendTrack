//
//  SteveSong.swift
//  SendTrack
//
//  Created by Steve Lederer on 2/6/19.
//  Copyright © 2019 Steve Lederer. All rights reserved.
//

import Foundation

struct SteveSong {
    let songName: String
    let artistName: String
    let albumName: String
    let songRecordingCode: String
    let spotifySongLink: String?
    let appleSongLink: String?
    
    init?(spotifySong: SpotifyTrack?, appleSong: AppleTrack?) {
        
        if let spotifySong = spotifySong {
            self.songName = spotifySong.tracks.spotifySongs.first?.songName ?? ""
            self.artistName = spotifySong.tracks.spotifySongs.first?.artists.first?.artistName ?? ""
            self.albumName = spotifySong.tracks.spotifySongs.first?.album.albumName ?? ""
            self.songRecordingCode = spotifySong.tracks.spotifySongs.first?.externalIds.songRecordingCode ?? ""
        } else if let appleSong = appleSong {
            self.songName = appleSong.results.appleSongResults.data.first?.attributes.songName ?? ""
            self.artistName = appleSong.results.appleSongResults.data.first?.attributes.artistName ?? ""
            self.albumName = appleSong.results.appleSongResults.data.first?.attributes.albumName ?? ""
            self.songRecordingCode = appleSong.results.appleSongResults.data.first?.attributes.songRecordingCode ?? ""
        } else { return nil }
        
        self.spotifySongLink = spotifySong?.tracks.spotifySongs.first?.externalUrls.spotifyLink ?? ""
        self.appleSongLink = appleSong?.results.appleSongResults.data.first?.attributes.appleLink ?? ""
    }
}
