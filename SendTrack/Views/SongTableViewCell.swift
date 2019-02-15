//
//  SongTableViewCell.swift
//  SendTrack
//
//  Created by Steve Lederer on 2/7/19.
//  Copyright © 2019 Steve Lederer. All rights reserved.
//

import UIKit

protocol SongTableViewCellDelegate: class {
    func playPauseButtonTapped(songURLString: String)
}

class SongTableViewCell: UITableViewCell {
    
    @IBOutlet weak var albumArtworkImageView: UIImageView!
    @IBOutlet weak var songNameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var albumNameLabel: UILabel!
    @IBOutlet weak var playButtonBlurView: UIVisualEffectView!
    @IBOutlet weak var playButtonImageView: UIImageView!
    
    var dimension = 0
    var song: SteveSong? {
        didSet {
            dimension = Int(albumArtworkImageView.frame.height)
            updateViews()

        }
    }
    
    weak var delegate: SongTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        playButtonBlurView.layer.masksToBounds = true
        playButtonBlurView.layer.cornerRadius = playButtonBlurView.frame.height / 2
        playButtonImageView.tintColor = UIColor.white
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.albumArtworkImageView.image = nil
    }

    func updateViews() {
        guard let song = song else { return }
        checkBackgroundColor(song: song)
        self.songNameLabel.text = song.songName
        self.artistNameLabel.text = song.artistName
        self.albumNameLabel.text = song.albumName
        NotificationCenter.default.addObserver(self, selector: #selector(updatePlayPauseButton), name: .playPauseNotification, object: nil)
        if let thumbnailImage = AppleMusicController.thumbnailImageCache.object(forKey: NSString(string: song.uuid)) {
            self.albumArtworkImageView.image = thumbnailImage
        } else {
            AppleMusicController.fetchAppleMusicArtwork(forSong: song, withDimension: dimension) { (image) in
                if let image = image {
                    DispatchQueue.main.async {
                        AppleMusicController.thumbnailImageCache.setObject(image, forKey: NSString(string: song.uuid))
                        self.albumArtworkImageView.image = AppleMusicController.thumbnailImageCache.object(forKey: NSString(string: self.song!.uuid))
                    }
                }
            }
        }
    }
    
    func checkBackgroundColor(song: SteveSong) {
        let backgroundColor = UIColor(hex: song.appleSongArtworkBGColor)
        if backgroundColor.isLight { // background is light
            self.playButtonBlurView.effect = UIBlurEffect(style: .dark)
        } else { // background is dark
            self.playButtonBlurView.effect = UIBlurEffect(style: .light)
        }
    }
    
    @IBAction func playPauseButtonTapped(_ sender: UIButton) {
        guard let songPreviewURLString = self.song?.appleSongPreviewURL else { return }
        delegate?.playPauseButtonTapped(songURLString: songPreviewURLString)
    }
    
    @objc func updatePlayPauseButton() {
        if PlayerController.shared.isPlaying && PlayerController.shared.previewURLString == self.song?.appleSongPreviewURL {
            playButtonImageView.image = UIImage(named: "pauseSquare")
        } else {
            playButtonImageView.image = UIImage(named: "playSquare")
        }
    }
    
}
