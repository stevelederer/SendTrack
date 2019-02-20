//
//  MessageComposer.swift
//  SendTrack
//
//  Created by Steve Lederer on 2/11/19.
//  Copyright © 2019 Steve Lederer. All rights reserved.
//

import Foundation
import MessageUI

class MessageComposer: NSObject, MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate {
    
    
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
    
    // MARK: - email functions
    
    func canSendEmail() -> Bool {
        return MFMailComposeViewController.canSendMail()
    }
    
    func getEmailAddress() -> String? {
        guard let filePath = Bundle.main.path(forResource: "APIKeys", ofType: "plist") else { return nil }
        let plist = NSDictionary(contentsOfFile: filePath)
        guard let emailAddresss: String = plist?.object(forKey: "supportEmailAddress") as? String else { return nil }
        
        return emailAddresss
    }
    
    func composeEmail() -> MFMailComposeViewController {
        let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
        let buildNumber = Bundle.main.infoDictionary!["CFBundleVersion"] as! String
        let emailComposeVC = MFMailComposeViewController()
        if let emailAddress = getEmailAddress() {
            emailComposeVC.mailComposeDelegate = self as MFMailComposeViewControllerDelegate
            emailComposeVC.setToRecipients([emailAddress])
            emailComposeVC.setSubject("SendTrack Feedback")
            emailComposeVC.setMessageBody("SendTrack Version Number: \(appVersion)\n SendTrack Build Number: \(buildNumber)\n\n*** Please write your message below this line ***\n\n\n", isHTML: false)
        }
        return emailComposeVC
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
}
