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
    let appleSongArtworkURL: String
    let appleSongArtworkBGColor: String
    let appleSongTextColor1: String
    let appleSongTextColor2: String
    let appleSongPreviewURL: String?

//    let spotifySongLink: String?
//    let appleSongLink: String?
    
//    init?(spotifySong: SpotifyTrack?, appleSong: AppleMusicSong?) {
//
//        if let spotifySong = spotifySong {
//            self.songName = spotifySong.tracks.spotifySongs.first?.songName ?? ""
//            self.artistName = spotifySong.tracks.spotifySongs.first?.artists.first?.artistName ?? ""
//            self.albumName = spotifySong.tracks.spotifySongs.first?.album.albumName ?? ""
//            self.songRecordingCode = spotifySong.tracks.spotifySongs.first?.externalIds.songRecordingCode ?? ""
//        } else if let appleSong = appleSong {
//            self.songName = appleSong.attributes.songName
//            self.artistName = appleSong.attributes.artistName
//            self.albumName = appleSong.attributes.albumName
//            self.songRecordingCode = appleSong.attributes.songRecordingCode
//            self.appleSongPreviewURL = appleSong.attributes.previewURLs.first?.songApplePreviewURL
//        } else { return nil }
//
//        self.spotifySongLink = spotifySong?.tracks.spotifySongs.first?.externalUrls.spotifyLink ?? ""
//        self.appleSongLink = appleSong?.attributes.appleLink ?? ""
//    }
    
    init?(appleSong: AppleMusicSong?) {
        if let appleSong = appleSong {
            self.songName = appleSong.attributes.songName
            self.artistName = appleSong.attributes.artistName
            self.albumName = appleSong.attributes.albumName
            self.songRecordingCode = appleSong.attributes.songRecordingCode
            self.appleSongArtworkURL = appleSong.attributes.artwork.appleArtworkURL
            self.appleSongArtworkBGColor = appleSong.attributes.artwork.bgColor
            self.appleSongTextColor1 = appleSong.attributes.artwork.textColor1
            self.appleSongTextColor2 = appleSong.attributes.artwork.textColor2
            self.appleSongPreviewURL = appleSong.attributes.previewURLs.first?.songApplePreviewURL
//            self.appleSongLink = appleSong.attributes.appleLink
        } else { return nil }
//        self.spotifySongLink = nil
    }
}
