//
//  MessageComposer.swift
//  SendTrack
//
//  Created by Steve Lederer on 2/11/19.
//  Copyright © 2019 Steve Lederer. All rights reserved.
//

import Foundation
import MessageUI

class MessageComposer: NSObject, MFMessageComposeViewControllerDelegate {
    
    // MARK: - Text Message Functions
    
    enum SongLinkType: String {
        case Apple
        case Spotify
    }
    
    func canSendText() -> Bool {
        return MFMessageComposeViewController.canSendText()
    }
    
    func composeLinkMessage(withSong song: SteveSong, linkType: SongLinkType) -> MFMessageComposeViewController {
        let messageComposeVC = MFMessageComposeViewController()
        messageComposeVC.messageComposeDelegate = self
        if linkType == SongLinkType.Spotify {
            if let spotifyLink = song.spotifySongLink {
                messageComposeVC.body = "Check out the song \(song.songName) by \(song.artistName). \(spotifyLink)"
            }
        } else if linkType == SongLinkType.Apple {
            if let appleLink = song.appleSongLink {
                messageComposeVC.body = "Check out the song \(song.songName) by \(song.artistName). \(appleLink)"
            }
        }
        return messageComposeVC
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }
}
