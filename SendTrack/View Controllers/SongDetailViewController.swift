//
//  SongDetailViewController.swift
//  SendTrack
//
//  Created by Steve Lederer on 2/7/19.
//  Copyright © 2019 Steve Lederer. All rights reserved.
//

import UIKit
import AVFoundation
import NotificationCenter

class SongDetailViewController: UIViewController {
    
    @IBOutlet weak var songArtworkImageView: UIImageView!
    @IBOutlet weak var songNameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var albumNameLabel: UILabel!
    @IBOutlet weak var appleLinkButton: UIButton!
    @IBOutlet weak var spotifyLinkButton: UIButton!
    @IBOutlet weak var playPausePreviewButton: UIButton!
    @IBOutlet weak var activitySpinner: UIActivityIndicatorView!
    
    var song: SteveSong?
    var dimension: Int = 0
    
    lazy var player: AVPlayer = {
        return AVPlayer()
    }()
    var isPlaying: Bool = false
    
    let messageComposer = MessageComposer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard var song = song else { return }
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
        self.view.backgroundColor = UIColor(hex: song.appleSongArtworkBGColor)
        AppleMusicController.fetchAppleMusicArtwork(forSong: song, withDimension: self.dimension) { (image) in
            if let image = image {
                DispatchQueue.main.async {
                    self.songArtworkImageView.image = image
                    self.activitySpinner.stopAnimating()
                }
            }
        }
        prepareToPlay()
    }
    
    func updateTextWith(labelColor: UIColor, buttonColor: UIColor) {
        self.songNameLabel.textColor = labelColor
        self.artistNameLabel.textColor = labelColor
        self.albumNameLabel.textColor = labelColor
        self.appleLinkButton.setTitleColor(buttonColor, for: .normal)
        self.spotifyLinkButton.setTitleColor(buttonColor, for: .normal)
    }
    
    func prepareToPlay() {
        guard let previewURLString = song?.appleSongPreviewURL, let previewURL = URL(string: previewURLString) else { return }
        let asset = AVAsset(url: previewURL)
        
        let playerItem = AVPlayerItem(asset: asset)
        
        player = AVPlayer(playerItem: playerItem)
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
        print("duration: \(asset.duration.seconds)")
    }
    
    @IBAction func playPreviewButtonTapped(_ sender: UIButton) {
        if !isPlaying {
            player.volume = 1.0
            player.play()
            playPausePreviewButton.setTitle("Pause", for: .normal)
        } else {
            player.pause()
            prepareToPlay()
            playPausePreviewButton.setTitle("Play Preview", for: .normal)
        }
        self.isPlaying = !self.isPlaying
    }
    
    @objc func playerDidFinishPlaying(note: Notification) {
        playPausePreviewButton.setTitle("Play Preview", for: .normal)
        self.isPlaying = false
        prepareToPlay()
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
