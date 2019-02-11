//
//  SongTableViewCell.swift
//  SendTrack
//
//  Created by Steve Lederer on 2/7/19.
//  Copyright © 2019 Steve Lederer. All rights reserved.
//

import UIKit

class SongTableViewCell: UITableViewCell {
    
    @IBOutlet weak var albumArtworkImageView: UIImageView!
    @IBOutlet weak var songNameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var albumNameLabel: UILabel!
    
    var dimension = 0
    var song: SteveSong? {
        didSet {
            dimension = Int(albumArtworkImageView.frame.height)
            updateViews()
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.albumArtworkImageView.image = nil
    }

    func updateViews() {
        guard let song = song else { return }
        self.songNameLabel.text = song.songName
        self.artistNameLabel.text = song.artistName
        self.albumNameLabel.text = song.albumName
        if let thumbnailImage = AppleMusicController.thumbnailImageCache.object(forKey: NSString(string: song.uuid)) {
            self.albumArtworkImageView.image = thumbnailImage
        } else {
            AppleMusicController.fetchAppleMusicArtwork(forSong: song, withDimension: dimension) { (image) in
                if let image = image {
                    AppleMusicController.thumbnailImageCache.setObject(image, forKey: NSString(string: song.uuid))
                    DispatchQueue.main.async {
                        self.albumArtworkImageView.image = image
                    }
                }
            }
        }
    }

}
