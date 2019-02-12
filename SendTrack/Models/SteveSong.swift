//
//  SteveSong.swift
//  SendTrack
//
//  Created by Steve Lederer on 2/6/19.
//  Copyright © 2019 Steve Lederer. All rights reserved.
//

import Foundation

struct SteveSong {
    let uuid: String
    let songName: String
    let artistName: String
    let albumName: String
    let songRecordingCode: String
    let appleSongArtworkURL: String
    let appleSongArtworkBGColor: String
    let appleSongTextColor1: String
    let appleSongTextColor2: String
    let appleSongPreviewURL: String?

    var spotifySongLink: String?
    let appleSongLink: String?
    
    init?(appleSong: AppleMusicSong?) {
        if let appleSong = appleSong {
            self.uuid = UUID().uuidString
            self.songName = appleSong.attributes.songName
            self.artistName = appleSong.attributes.artistName
            self.albumName = appleSong.attributes.albumName
            self.songRecordingCode = appleSong.attributes.songRecordingCode
            self.appleSongArtworkURL = appleSong.attributes.artwork.appleArtworkURL
            self.appleSongArtworkBGColor = appleSong.attributes.artwork.bgColor
            self.appleSongTextColor1 = appleSong.attributes.artwork.textColor1
            self.appleSongTextColor2 = appleSong.attributes.artwork.textColor2
            self.appleSongPreviewURL = appleSong.attributes.previewURLs.first?.songApplePreviewURL
            self.appleSongLink = appleSong.attributes.appleLink
        } else { return nil }
    }
}
