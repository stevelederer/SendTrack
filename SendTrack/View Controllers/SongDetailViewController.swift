//
//  SongDetailViewController.swift
//  SendTrack
//
//  Created by Steve Lederer on 2/7/19.
//  Copyright © 2019 Steve Lederer. All rights reserved.
//

import UIKit

class SongDetailViewController: UIViewController {
    
    @IBOutlet weak var artworkContainerView: UIView!
    @IBOutlet weak var songArtworkImageView: UIImageView!
    @IBOutlet weak var songNameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var albumNameLabel: UILabel!
    @IBOutlet weak var appleLinkButton: UIButton!
    @IBOutlet weak var spotifyLinkButton: UIButton!
    @IBOutlet weak var activitySpinner: UIActivityIndicatorView!
    @IBOutlet weak var playButtonContainerView: UIView!
    @IBOutlet weak var playPauseButton: UIButton!
    
    var song: SteveSong?
    var dimension: Int = 0
        
    override func viewDidLayoutSubviews() {
        playButtonContainerView.layer.cornerRadius = playButtonContainerView.frame.height / 2
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard var song = song else { return }
        self.navigationController?.navigationBar.tintColor = UIColor(hex: "4f9da6")
        self.navigationItem.title = "Share"
        appleLinkButton.imageView?.contentMode = .scaleAspectFit
        spotifyLinkButton.imageView?.contentMode = .scaleAspectFit
        NotificationCenter.default.addObserver(self, selector: #selector(self.updatePlayerProgress(_:)), name: .playerTimeChangeNotification, object: nil)
        activitySpinner.color = UIColor(hex: song.appleSongTextColor1)
        activitySpinner.startAnimating()
        songArtworkImageView.layer.cornerRadius = 7
        artworkContainerView.layer.shadowOpacity = 0.55
        artworkContainerView.layer.shadowRadius = 7.5
        artworkContainerView.layer.shadowOffset = CGSize(width: 0, height: 5)
        updateViews()
        SpotifyController.matchSpotifySong(byISRC: song.songRecordingCode) { (songs) in
            guard let fetchedSongs = songs else { return }
            if fetchedSongs.count >= 1 {
                song.spotifySongLink = fetchedSongs.first?.externalUrls.spotifyLink
                self.setSpotifyLink(for: song)
            } else {
                SpotifyController.matchSpotifySong(bySongName: song.songName, artistName: song.artistName, albumName: song.albumName, completion: { (songs) in
                    if let fetchedSongs = songs {
                        song.spotifySongLink = fetchedSongs.first?.externalUrls.spotifyLink
                        self.setSpotifyLink(for: song)
                    }
                })
            }
        }
    }
    
    fileprivate func setSpotifyLink(for song: SteveSong) {
        DispatchQueue.main.async {
            self.song = song
            if song.spotifySongLink != nil {
                self.spotifyLinkButton.isHidden = false
            } else {
                UIView.transition(with: self.spotifyLinkButton, duration: 0.1, options: .transitionCrossDissolve, animations: {
                    self.spotifyLinkButton.setTitle("", for: .normal)
                    self.spotifyLinkButton.setImage(nil, for: .normal)
                    self.spotifyLinkButton.isHidden = true
                }, completion: nil)
            }
        }
    }
    
    func updateViews() {
        guard isViewLoaded else { return }
        dimension = Int(songArtworkImageView.frame.height)
        guard let song = song else { return }
//        playPauseButtonUIChange(buttonImageName: "playSquare", rightimageInset: -1)
        self.playPauseButton.setImage(UIImage(named: "playSquare"), for: .normal)
        self.playPauseButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -1)
        self.songArtworkImageView.image = AppleMusicController.thumbnailImageCache.object(forKey: NSString(string: song.uuid))
//        let textColor = UIColor(hex: song.appleSongTextColor1)
//        let linkColor = UIColor(hex: song.appleSongTextColor2)
//        updateTextWith(labelColor: textColor, buttonColor: linkColor)
        self.songNameLabel.text = song.songName
        self.artistNameLabel.text = song.artistName
        self.albumNameLabel.text = song.albumName
        PlayerController.shared.previewURLString = song.appleSongPreviewURL
//        self.view.backgroundColor = UIColor(hex: song.appleSongArtworkBGColor)
//        checkBackgroundColor(song: song)
        AppleMusicController.fetchAppleMusicArtwork(forSong: song, withDimension: self.dimension) { (image) in
            if let image = image {
                DispatchQueue.main.async {
                    self.songArtworkImageView.image = image
                    self.activitySpinner.stopAnimating()
                }
            }
        }
    }
    
    let progressCircleLayer = CAShapeLayer()
    
    @objc func updatePlayerProgress(_ notification: Notification) {
        let circleCenter = playPauseButton.center
        progressCircleLayer.opacity = 1.0
        progressCircleLayer.strokeEnd = 1.0
        progressCircleLayer.strokeColor = UIColor(hex: "ff5959").cgColor
        progressCircleLayer.lineWidth = 4
        let radius = (playButtonContainerView.frame.height / 2)
        progressCircleLayer.fillColor = UIColor.clear.cgColor
        progressCircleLayer.lineCap = CAShapeLayerLineCap.round
        playButtonContainerView.layer.addSublayer(progressCircleLayer)
        
        if let percentPlayed = notification.userInfo?["percentPlayed"] as? CGFloat {
            let startAngle = -CGFloat.pi / 2
            let endAngle = percentPlayed * (2 * CGFloat.pi) + startAngle
            let circularPath = UIBezierPath(arcCenter: circleCenter,
                                            radius: radius,
                                            startAngle: startAngle,
                                            endAngle: endAngle,
                                            clockwise: true)
            progressCircleLayer.path = circularPath.cgPath
            progressCircleLayer.opacity = 1.0
        }
    }
    
    func removePlayerProgress() {
        CATransaction.begin()
        let removeProgressAnimation = CABasicAnimation(keyPath: "strokeEnd")
        removeProgressAnimation.toValue = 0
        removeProgressAnimation.duration = 0.5
        removeProgressAnimation.fillMode = CAMediaTimingFillMode.forwards
        CATransaction.setCompletionBlock {
            UIView.animate(withDuration: 0.2, delay: 0, options: .transitionCrossDissolve, animations: {
                self.progressCircleLayer.opacity = 0
            }, completion: { (remove) in
                self.progressCircleLayer.removeFromSuperlayer()
            })
        }
        self.progressCircleLayer.strokeEnd = 0
        progressCircleLayer.add(removeProgressAnimation, forKey: "removeProgressCircle")
        CATransaction.commit()
    }
    
//    func checkBackgroundColor(song: SteveSong) {
//        guard let backgroundColor = self.view.backgroundColor else { return }
//        print("🤖🤖🤖 Background Color is: \(song.appleSongArtworkBGColor)")
//
//        if backgroundColor.isLight { // background is light
//            self.spotifyLinkButton.setImage(UIImage(named: "Spotify_Icon_RGB_Black_30"), for: .normal)
//            self.appleLinkButton.setImage(UIImage(named: "Apple_Music_Icon_Black_30"), for: .normal)
//        } else if !backgroundColor.isLight { //background is dark
//            self.spotifyLinkButton.setImage(UIImage(named: "Spotify_Icon_RGB_White_30"), for: .normal)
//            self.appleLinkButton.setImage(UIImage(named: "Apple_Music_Icon_White_30"), for: .normal)
//        }
//    }
    
//    func updateTextWith(labelColor: UIColor, buttonColor: UIColor) {
//        self.songNameLabel.textColor = labelColor
//        self.artistNameLabel.textColor = labelColor
//        self.albumNameLabel.textColor = labelColor
//        self.appleLinkButton.setTitleColor(buttonColor, for: .normal)
//        self.spotifyLinkButton.setTitleColor(buttonColor, for: .normal)
//    }
    
    @objc func updatePlayPauseButton() {
        PlayerController.shared.isPlaying ? playPauseButtonUIChange(buttonImageName: "pauseSquare", rightimageInset: 0) : playPauseButtonUIChange(buttonImageName: "playSquare", rightimageInset: -1)
    }
    
    func playPauseButtonUIChange(buttonImageName: String, rightimageInset: CGFloat) {
        if buttonImageName == "playSquare" {
            removePlayerProgress()
        }
        UIView.transition(with: self.playPauseButton,
                          duration: 0.5,
                          options: [.transitionFlipFromRight],
                          animations: {
                            self.playPauseButton.setImage(UIImage(named: buttonImageName), for: .normal)
                            self.playPauseButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: rightimageInset)
        },
                          completion: nil)
    }
    
    @IBAction func playPauseButtonTapped(_ sender: UIButton) {
        PlayerController.shared.playPause()
        NotificationCenter.default.addObserver(self, selector: #selector(updatePlayPauseButton), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        updatePlayPauseButton()
    }
    
    @IBAction func appleMusicLinkButtonTapped(_ sender: UIButton) {
        guard let song = self.song else { return }
        if let songURLString = song.appleSongLink {
            presentShareSheet(withURL: songURLString)
        }
    }
    
    @IBAction func spotifyLinkButtonTapped(_ sender: UIButton) {
        guard let song = self.song else { return }
        if let songURLString = song.spotifySongLink {
            presentShareSheet(withURL: songURLString)
        }
    }
    
    func presentShareSheet(withURL urlToShare: String) {
        let items: [Any] = [urlToShare]
        let shareSheet = UIActivityViewController(activityItems: items, applicationActivities: nil)
        present(shareSheet, animated: true)
    }
    
}
