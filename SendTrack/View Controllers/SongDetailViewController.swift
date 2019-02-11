//
//  SongDetailViewController.swift
//  SendTrack
//
//  Created by Steve Lederer on 2/7/19.
//  Copyright © 2019 Steve Lederer. All rights reserved.
//

import UIKit
import AVFoundation

class SongDetailViewController: UIViewController {
    
    @IBOutlet weak var songArtworkImageView: UIImageView!
    @IBOutlet weak var songNameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var albumNameLabel: UILabel!
    @IBOutlet weak var appleLinkButton: UIButton!
    @IBOutlet weak var spotifyLinkButton: UIButton!
    
    var song: SteveSong?
    var dimension: Int = 0
    
    lazy var player: AVPlayer = {
        return AVPlayer()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
        guard var song = song else { return }
        SpotifyController.matchSpotifySong(byISRC: song.songRecordingCode) { (songs) in
            if let fetchedSongs = songs {
                song.spotifySongLink = fetchedSongs.first?.externalUrls.spotifyLink
            } else {
                SpotifyController.matchSpotifySong(bySongName: song.songName, artistName: song.artistName, albumName: song.albumName, completion: { (songs) in
                    if let fetchedSongs = songs {
                        song.spotifySongLink = fetchedSongs.first?.externalUrls.spotifyLink
                    }
                })
            }
            if let spotifyLink = song.spotifySongLink {
                print("Spotify link: \(spotifyLink)")
            }
            self.song = song
        }
    }
    
    @IBAction func playPreviewButtonTapped(_ sender: UIButton) {
        guard let previewURLString = song?.appleSongPreviewURL,
            let previewURL = URL(string: previewURLString) else { return }
        
        print("playing \(previewURL)")
        
        let playerItem = AVPlayerItem(url: previewURL)
        self.player = AVPlayer(playerItem: playerItem)
        player.volume = 1.0
        player.play()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        dimension = Int(songArtworkImageView.frame.height)
        songArtworkImageView.layer.cornerRadius = 10
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
                }
            }
        }
    }
    
    func updateTextWith(labelColor: UIColor, buttonColor: UIColor) {
        self.songNameLabel.textColor = labelColor
        self.artistNameLabel.textColor = labelColor
        self.albumNameLabel.textColor = labelColor
        self.appleLinkButton.setTitleColor(buttonColor, for: .normal)
        self.spotifyLinkButton.setTitleColor(buttonColor, for: .normal)
    }
    
}
