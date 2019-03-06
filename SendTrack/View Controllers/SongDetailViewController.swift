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
        updatePlayPauseButtonCornerRadius()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        updatePlayPauseButtonCornerRadius()
    }
    
    func updatePlayPauseButtonCornerRadius() {
        UIView.transition(with: self.playButtonContainerView,
                          duration: 0.01,
                          options: [.transitionCrossDissolve],
                          animations: {
                            self.playButtonContainerView.layoutIfNeeded()
                            self.playButtonContainerView.layer.cornerRadius = self.playButtonContainerView.frame.height / 2
        },
                          completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard var song = song else { return }
        self.navigationController?.navigationBar.tintColor = UIColor(hex: "4f9da6")
        self.navigationItem.title = "Share"
        appleLinkButton.imageView?.contentMode = .scaleAspectFit
        spotifyLinkButton.imageView?.contentMode = .scaleAspectFit
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateProgressIndicator(_:)), name: .playerTimeChangeNotification, object: nil)
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
        self.activitySpinner.color = UIColor(hex: song.appleSongTextColor1)
//        let textColor = UIColor(hex: song.appleSongTextColor1)
//        let linkColor = UIColor(hex: song.appleSongTextColor2)
//        updateTextWith(labelColor: textColor, buttonColor: linkColor)
        self.songNameLabel.text = song.songName
        self.artistNameLabel.text = song.artistName
        self.albumNameLabel.text = song.albumName
        NotificationCenter.default.addObserver(self, selector: #selector(updatePlayPauseButton), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        updatePlayPauseButton()
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
    
    let progressIndicatorLayer = CAShapeLayer()
    
    @objc func updateProgressIndicator(_ notification: Notification) {
        let circleCenter = playPauseButton.center
        progressIndicatorLayer.opacity = 1.0
        progressIndicatorLayer.strokeEnd = 1.0
        progressIndicatorLayer.strokeColor = UIColor(hex: "ff5959").cgColor
        progressIndicatorLayer.lineWidth = playButtonContainerView.frame.height * 0.089
        let radius = (playButtonContainerView.frame.height / 2)
        progressIndicatorLayer.fillColor = UIColor.clear.cgColor
        progressIndicatorLayer.lineCap = CAShapeLayerLineCap.round
        playButtonContainerView.layer.addSublayer(progressIndicatorLayer)
        
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
    
    func clearProgressIndicator() {
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
        guard let songURLString = song?.appleSongPreviewURL else { return }
        if PlayerController.shared.isPlaying && songURLString == PlayerController.shared.previewURLString {
            playPauseButtonUIChange(buttonImageName: "pauseSquare", rightimageInset: 0)
        } else {
            playPauseButtonUIChange(buttonImageName: "playSquare", rightimageInset: -1)
        }
//        PlayerController.shared.isPlaying ? playPauseButtonUIChange(buttonImageName: "pauseSquare", rightimageInset: 0) : playPauseButtonUIChange(buttonImageName: "playSquare", rightimageInset: -1)
    }
    
    func playPauseButtonUIChange(buttonImageName: String, rightimageInset: CGFloat) {
        if buttonImageName == "playSquare" {
            clearProgressIndicator()
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
        guard let songURLString = song?.appleSongPreviewURL else { return }
        if songURLString != PlayerController.shared.previewURLString {
            PlayerController.shared.previewURLString = songURLString
        }
        PlayerController.shared.playPause()
        updatePlayPauseButton()
    }
    
    @IBAction func appleMusicLinkButtonTapped(_ sender: UIButton) {
        guard let song = self.song else { return }
        if let appleSongURLString = song.appleSongLink {
            presentShareSheet(withURL: appleSongURLString, fromButton: appleLinkButton)
        }
    }
    
    @IBAction func spotifyLinkButtonTapped(_ sender: UIButton) {
        guard let song = self.song else { return }
        if let spotifySongURLString = song.spotifySongLink {
            presentShareSheet(withURL: spotifySongURLString, fromButton: spotifyLinkButton)
        }
    }
    
    func presentShareSheet(withURL urlToShare: String, fromButton buttonTapped: UIView) {
        let items: [Any] = [urlToShare]
        let shareSheet = UIActivityViewController(activityItems: items, applicationActivities: nil)
        shareSheet.popoverPresentationController?.sourceView = buttonTapped
        let xPosition: CGFloat
        if buttonTapped == appleLinkButton {
            xPosition = buttonTapped.bounds.minX
        } else {
            xPosition = buttonTapped.bounds.maxX
        }
        shareSheet.popoverPresentationController?.sourceRect = CGRect(x: xPosition, y: buttonTapped.bounds.minY, width: 0, height: 0)
        present(shareSheet, animated: true)
    }
    
}
