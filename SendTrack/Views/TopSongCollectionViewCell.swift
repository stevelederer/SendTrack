//
//  TopSongCollectionViewCell.swift
//  SendTrack
//
//  Created by Steve Lederer on 2/15/19.
//  Copyright © 2019 Steve Lederer. All rights reserved.
//

import UIKit

protocol TopSongCollectionViewCellDelegate: class {
    func playPauseButtonTapped(songURLString: String)
}

class TopSongCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var cellActivitySpinner: UIActivityIndicatorView!
    @IBOutlet weak var albumArtworkImageView: UIImageView!
    @IBOutlet weak var songCellView: UIView!
    @IBOutlet weak var playButtonContainerView: UIView!
    @IBOutlet weak var playButtonImageView: UIImageView!
    @IBOutlet weak var songNameLabel: UILabel!
    
    var dimension = 0
    var song: SteveSong? {
        didSet {
            cellActivitySpinner.startAnimating()
            dimension = Int(albumArtworkImageView.frame.height)
            updateViews()
        }
    }
    
    weak var delegate: TopSongCollectionViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCell()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.albumArtworkImageView.image = nil
    }
    
    func setupCell() {
//        self.backgroundColor = .clear
        songCellView.layer.cornerRadius = 7
        playButtonContainerView.layer.masksToBounds = true
        playButtonContainerView.layer.cornerRadius = playButtonContainerView.frame.height / 2
        playButtonImageView.tintColor = UIColor(hex: "ff5959")
        albumArtworkImageView.layer.cornerRadius = 7
    }
    
    func updateViews() {
        guard let song = song else { return }
        self.songNameLabel.text = song.songName
        NotificationCenter.default.addObserver(self, selector: #selector(updatePlayPauseButton), name: .playPauseNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updatePlayPauseButton), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        if let thumbnailImage = AppleMusicController.thumbnailImageCache.object(forKey: NSString(string: song.uuid)) {
            self.albumArtworkImageView.image = thumbnailImage
            self.cellActivitySpinner.stopAnimating()
        } else {
            AppleMusicController.fetchAppleMusicArtwork(forSong: song, withDimension: dimension) { (image) in
                if let image = image {
                    DispatchQueue.main.async {
                        AppleMusicController.thumbnailImageCache.setObject(image, forKey: NSString(string: song.uuid))
                        self.cellActivitySpinner.stopAnimating()
                        self.albumArtworkImageView.image = AppleMusicController.thumbnailImageCache.object(forKey: NSString(string: self.song!.uuid))
                    }
                }
            }
        }
    }
    
    @IBAction func playPauseButtonTapped(_ sender: UIButton) {
        guard let songPreviewURLString = self.song?.appleSongPreviewURL else { return }
        delegate?.playPauseButtonTapped(songURLString: songPreviewURLString)
    }
    
    @objc func updatePlayPauseButton() {
        if PlayerController.shared.isPlaying && PlayerController.shared.previewURLString == self.song?.appleSongPreviewURL {
            UIView.transition(with: self.playButtonImageView,
                              duration: 0.3,
                              options: .transitionFlipFromRight,
                              animations: {
                                self.playButtonImageView.image = UIImage(named: "pauseSquare")
            },
                              completion: nil)
        } else {
            if playButtonImageView.image == UIImage(named: "pauseSquare") {
                UIView.transition(with: self.playButtonImageView,
                                  duration: 0.3,
                                  options: .transitionFlipFromRight,
                                  animations: {
                                    self.playButtonImageView.image = UIImage(named: "playSquare")
                },
                                  completion: nil)
            } else {
                playButtonImageView.image = UIImage(named: "playSquare")
            }
        }
    }
}
