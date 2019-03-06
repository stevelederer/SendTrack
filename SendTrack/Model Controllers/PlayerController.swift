//
//  PlayerController.swift
//  SendTrack
//
//  Created by Steve Lederer on 2/14/19.
//  Copyright © 2019 Steve Lederer. All rights reserved.
//

import Foundation
import AVFoundation
import NotificationCenter

class PlayerController {
    
    // MARK: - Shared Instance
    static let shared = PlayerController()
    private init(){}
    
    var previewURLString: String? {
        didSet {
            guard let string = previewURLString else { return }
            previewURL = URL(string: string)
            isPlaying = false
        }
    }
    var previewURL: URL? {
        didSet {
            prepareToPlay() 
        }
    }
    
    var isPlaying: Bool = false
    
    lazy var player: AVPlayer = {
        let player = AVPlayer()
        return player
    }()
    var playerItem: AVPlayerItem!
    var timeObserverToken: Any?
    
    func prepareToPlay() {
        guard let previewURL = self.previewURL else { return }
        
        let asset = AVAsset(url: previewURL)
        
        do {
//            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: .default, options: .duckOthers)
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        } catch {
            print("❌ There was an error in \(#function) ; \(error.localizedDescription)❌")
        }
        
        self.playerItem = AVPlayerItem(asset: asset)
        removePeriodicTimeObserver()
        
        self.player = AVPlayer(playerItem: playerItem)
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
        
    }
    
    func addPeriodicTimeObserver() {
        let timeScale = CMTimeScale(NSEC_PER_SEC)
        let time = CMTime(seconds: 0.1, preferredTimescale: timeScale)
        let duration = playerItem.asset.duration.seconds
        timeObserverToken = player.addPeriodicTimeObserver(forInterval: time,
                                                           queue: .main) {
                                                            [weak self] time in
                                                            // update player transport UI
                                                            let percentPlayed: CGFloat = CGFloat(time.seconds / duration)
                                                            let percentPlayedDict: [String : CGFloat] = ["percentPlayed" : percentPlayed]
                                                            NotificationCenter.default.post(name: .playerTimeChangeNotification, object: nil, userInfo: percentPlayedDict)
        }
    }
    
    func removePeriodicTimeObserver() {
        if let timeObserverToken = timeObserverToken {
            player.removeTimeObserver(timeObserverToken)
            self.timeObserverToken = nil
        }
    }
    
    func playPause() {
        isPlaying = !isPlaying
        if isPlaying {
            player.volume = 1.0
            player.play()
            addPeriodicTimeObserver()
            print("▶️ playing!")
        } else {
            player.pause()
            removePeriodicTimeObserver()
            prepareToPlay()
            print("⏸ Paused!")
        }
        print("👉👉👉👉 is playing?: \(isPlaying)")
    }
    
    @objc func playerDidFinishPlaying() {
        isPlaying = false
        removePeriodicTimeObserver()
        prepareToPlay()
    }
    
}
