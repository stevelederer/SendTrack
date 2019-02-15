//
//  SongDetailViewController.swift
//  SendTrack
//
//  Created by Steve Lederer on 2/7/19.
//  Copyright © 2019 Steve Lederer. All rights reserved.
//

import UIKit

class SongDetailViewController: UIViewController {
    
    @IBOutlet weak var songArtworkImageView: UIImageView!
    @IBOutlet weak var songNameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var albumNameLabel: UILabel!
    @IBOutlet weak var appleLinkButton: UIButton!
    @IBOutlet weak var spotifyLinkButton: UIButton!
    @IBOutlet weak var activitySpinner: UIActivityIndicatorView!
    @IBOutlet weak var playButtonBlurView: UIVisualEffectView!
    @IBOutlet weak var playPauseButton: UIButton!
    
    var song: SteveSong?
    var dimension: Int = 0
    
    let messageComposer = MessageComposer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard var song = song else { return }
        playButtonBlurView.layer.masksToBounds = true
        playButtonBlurView.layer.cornerRadius = playButtonBlurView.frame.height / 2
        appleLinkButton.imageView?.contentMode = .scaleAspectFit
        spotifyLinkButton.imageView?.contentMode = .scaleAspectFit
        activitySpinner.startAnimating()
        activitySpinner.color = UIColor(hex: song.appleSongTextColor1)
        spotifyLinkButton.isHidden = true
        songArtworkImageView.layer.shadowOpacity = 1.0
        songArtworkImageView.layer.shadowRadius = 10
        songArtworkImageView.layer.shadowOffset = CGSize(width: 0, height: 5)
        updateViews()
        SpotifyController.matchSpotifySong(byISRC: song.songRecordingCode) { (songs) in
            guard let fetchedSongs = songs else { return }
            if fetchedSongs.count >= 1 {
                song.spotifySongLink = fetchedSongs.first?.externalUrls.spotifyLink
            } else {
                SpotifyController.matchSpotifySong(bySongName: song.songName, artistName: song.artistName, albumName: song.albumName, completion: { (songs) in
                    if let fetchedSongs = songs {
                        song.spotifySongLink = fetchedSongs.first?.externalUrls.spotifyLink
                    }
                })
            }
            DispatchQueue.main.async {
                if song.spotifySongLink != nil {
                    self.spotifyLinkButton.isHidden = false
                    self.song = song
                } else {
                    self.spotifyLinkButton.isHidden = true
                }
            }
        }
    }
    
    func updateViews() {
        guard isViewLoaded else { return }
        dimension = Int(songArtworkImageView.frame.height)
        guard let song = song else { return }
        self.songArtworkImageView.image = AppleMusicController.thumbnailImageCache.object(forKey: NSString(string: song.uuid))
        let textColor = UIColor(hex: song.appleSongTextColor1)
        let linkColor = UIColor(hex: song.appleSongTextColor2)
        updateTextWith(labelColor: textColor, buttonColor: linkColor)
        self.songNameLabel.text = song.songName
        self.artistNameLabel.text = song.artistName
        self.albumNameLabel.text = song.albumName
        PlayerController.shared.previewURLString = song.appleSongPreviewURL
        self.view.backgroundColor = UIColor(hex: song.appleSongArtworkBGColor)
        checkBackgroundColor(song: song)
        AppleMusicController.fetchAppleMusicArtwork(forSong: song, withDimension: self.dimension) { (image) in
            if let image = image {
                DispatchQueue.main.async {
                    self.songArtworkImageView.image = image
                    self.activitySpinner.stopAnimating()
                }
            }
        }
    }
    
    func checkBackgroundColor(song: SteveSong) {
        guard let backgroundColor = self.view.backgroundColor else { return }
        print("🤖🤖🤖 Background Color is: \(song.appleSongArtworkBGColor)")

        if song.appleSongArtworkBGColor == "ffffff" { //background is white
            self.playButtonBlurView.effect = UIBlurEffect(style: .dark)
            self.spotifyLinkButton.setImage(UIImage(named: "Spotify_Icon_RGB_Green_30"), for: .normal)
        } else if song.appleSongArtworkBGColor == "000000" { //background is black
            self.playButtonBlurView.effect = UIBlurEffect(style: .light)
            self.spotifyLinkButton.setImage(UIImage(named: "Spotify_Icon_RGB_Green_30"), for: .normal)
        } else if backgroundColor.isLight { // background is light
            self.playButtonBlurView.effect = UIBlurEffect(style: .dark)
            self.spotifyLinkButton.setImage(UIImage(named: "Spotify_Icon_RGB_Black_30"), for: .normal)
        } else if !backgroundColor.isLight { //background is dark
            self.playButtonBlurView.effect = UIBlurEffect(style: .light)
            self.spotifyLinkButton.setImage(UIImage(named: "Spotify_Icon_RGB_White_30"), for: .normal)
        }
    }
    
    func updateTextWith(labelColor: UIColor, buttonColor: UIColor) {
        self.songNameLabel.textColor = labelColor
        self.artistNameLabel.textColor = labelColor
        self.albumNameLabel.textColor = labelColor
        self.appleLinkButton.setTitleColor(buttonColor, for: .normal)
        self.spotifyLinkButton.setTitleColor(buttonColor, for: .normal)
    }
    
    @objc func updatePlayPauseButton() {
        var buttonImageName: String
        PlayerController.shared.isPlaying ? (buttonImageName = "pauseSquare") : (buttonImageName = "playSquare")
        playPauseButton.setImage(UIImage(named: buttonImageName), for: .normal)
    }
    
    @IBAction func playPauseButtonTapped(_ sender: UIButton) {
        PlayerController.shared.playPause()
        NotificationCenter.default.addObserver(self, selector: #selector(updatePlayPauseButton), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        updatePlayPauseButton()
    }
    
    @IBAction func appleMusicLinkButtonTapped(_ sender: UIButton) {
        guard let song = self.song else { return }
        if (messageComposer.canSendText()) {
            let textMessageComposerVC = messageComposer.composeLinkMessage(withSong: song, linkType: MessageComposer.SongLinkType.Apple)
            present(textMessageComposerVC, animated: true, completion: nil)
        } else {
            guard let linkText = song.appleSongLink else { return }
            print("Apple Link: \(linkText)")
        }
    }
    
    @IBAction func spotifyLinkButtonTapped(_ sender: UIButton) {
        guard let song = self.song else { return }
        if (messageComposer.canSendText()) {
            let textMessageComposerVC = messageComposer.composeLinkMessage(withSong: song, linkType: MessageComposer.SongLinkType.Spotify)
            present(textMessageComposerVC, animated: true, completion: nil)
        } else {
            guard let linkText = song.spotifySongLink else { return }
            print("Spotify Link: \(linkText)")
        }
    }
    
}
