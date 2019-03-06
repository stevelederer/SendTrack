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
    
    @IBOutlet weak var songCellView: UIView!
    @IBOutlet weak var albumArtworkImageView: UIImageView!
    @IBOutlet weak var songNameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var playButtonImageView: UIImageView!
    @IBOutlet weak var playButtonContainerView: UIView!
    @IBOutlet weak var cellActivitySpinner: UIActivityIndicatorView!
    
    var dimension = 0
    var song: SteveSong? {
        didSet {
            cellActivitySpinner.startAnimating()
            dimension = Int(albumArtworkImageView.frame.height)
            updateViews()

        }
    }
    
    weak var delegate: SongTableViewCellDelegate?
    
    override func awakeFromNib() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateProgressIndicator(_:)), name: .playerTimeChangeNotification, object: nil)
        super.awakeFromNib()
        setupCell()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.albumArtworkImageView.image = nil
    }
    
    func setupCell() {
        self.backgroundColor = .clear
        songCellView.layer.cornerRadius = 7
//        playButtonContainerView.layer.masksToBounds = true
        playButtonContainerView.layer.cornerRadius = playButtonContainerView.frame.height / 2
        playButtonImageView.tintColor = UIColor(hex: "ff5959")
        albumArtworkImageView.layer.cornerRadius = 5
//        let bgColorView = UIView()
//        bgColorView.backgroundColor = UIColor(hex: "AACFD3")
//        self.selectedBackgroundView = bgColorView
    }

    func updateViews() {
        guard let song = song else { return }
//        checkBackgroundColor(song: song)
        self.songNameLabel.text = song.songName
        self.artistNameLabel.text = song.artistName
        NotificationCenter.default.addObserver(self, selector: #selector(updatePlayPauseButton), name: .playPauseButtonTappedNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(clearProgressIndicator), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        self.cellActivitySpinner.color = UIColor(hex: song.appleSongTextColor1)
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
    
    let progressIndicatorLayer = CAShapeLayer()
    
    @objc func updateProgressIndicator(_ notification: Notification) {
        if PlayerController.shared.previewURLString == self.song?.appleSongPreviewURL {
            let circleCenter = playButtonImageView.center
            progressIndicatorLayer.opacity = 1.0
            progressIndicatorLayer.strokeEnd = 1.0
            progressIndicatorLayer.strokeColor = UIColor(hex: "ff5959").cgColor
            progressIndicatorLayer.lineWidth = playButtonContainerView.frame.height * 0.1
            let radius = (self.playButtonContainerView.frame.height / 2)
            progressIndicatorLayer.fillColor = UIColor.clear.cgColor
            progressIndicatorLayer.lineCap = CAShapeLayerLineCap.round
            self.playButtonContainerView.layer.addSublayer(progressIndicatorLayer)
            
            if let percentPlayed = notification.userInfo?["percentPlayed"] as? CGFloat {
                let startAngle = -CGFloat.pi / 2
                let endAngle = percentPlayed * (2 * CGFloat.pi) + startAngle
                let circularPath = UIBezierPath(arcCenter: circleCenter,
                                                radius: radius,
                                                startAngle: startAngle,
                                                endAngle: endAngle,
                                                clockwise: true)
                progressIndicatorLayer.path = circularPath.cgPath
                progressIndicatorLayer.opacity = 1.0
            }
        }
        
    }
    
    @objc func clearProgressIndicator() {
        if playButtonImageView.image == UIImage(named: "pauseSquare") {
            UIView.transition(with: self.playButtonImageView,
                              duration: 0.3,
                              options: [.transitionFlipFromRight],
                              animations: {
                                self.playButtonImageView.image = UIImage(named: "playSquare")
            }, completion: nil)
        }
        CATransaction.begin()
        let clearProgressAnimation = CABasicAnimation(keyPath: "strokeEnd")
        clearProgressAnimation.toValue = 0
        clearProgressAnimation.duration = 0.5
        clearProgressAnimation.fillMode = CAMediaTimingFillMode.forwards
        CATransaction.setCompletionBlock {
            UIView.animate(withDuration: 0.2, delay: 0, options: .transitionCrossDissolve, animations: {
                self.progressIndicatorLayer.opacity = 0
            }, completion: { (remove) in
                self.progressIndicatorLayer.removeFromSuperlayer()
            })
        }
        self.progressIndicatorLayer.strokeEnd = 0
        progressIndicatorLayer.add(clearProgressAnimation, forKey: "removeProgressCircle")
        CATransaction.commit()
    }
    
    @IBAction func playPauseButtonTapped(_ sender: UIButton) {
        guard let songPreviewURLString = self.song?.appleSongPreviewURL else { return }
        delegate?.playPauseButtonTapped(songURLString: songPreviewURLString)
    }
    
    @objc func updatePlayPauseButton() {
        if PlayerController.shared.isPlaying && PlayerController.shared.previewURLString == self.song?.appleSongPreviewURL {
            UIView.transition(with: self.playButtonImageView,
                              duration: 0.3,
                              options: [.transitionFlipFromRight],
                              animations: {
                                self.playButtonImageView.image = UIImage(named: "pauseSquare")
            }, completion: nil)
        } else {
            if playButtonImageView.image == UIImage(named: "pauseSquare") {
                clearProgressIndicator()
                UIView.transition(with: self.playButtonImageView,
                                  duration: 0.3,
                                  options: [.transitionFlipFromRight],
                                  animations: {
                                    self.playButtonImageView.image = UIImage(named: "playSquare")
                }, completion: nil)
            } else {
                playButtonImageView.image = UIImage(named: "playSquare")
                clearProgressIndicator()
            }

        }
    }
    
}
