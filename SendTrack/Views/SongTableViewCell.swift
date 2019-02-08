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
    
    var song: SteveSong? {
        didSet {
            updateViews()
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func updateViews() {
        guard let song = song else { return }
        DispatchQueue.main.async {
            self.songNameLabel.text = song.songName
            self.artistNameLabel.text = song.artistName
            self.albumNameLabel.text = song.albumName
        }
    }

}
