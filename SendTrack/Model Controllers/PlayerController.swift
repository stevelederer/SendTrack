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
        return AVPlayer()
    }()
    
    func prepareToPlay() {
        guard let previewURL = self.previewURL else { return }
        let asset = AVAsset(url: previewURL)
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: .default, options: .duckOthers)
        } catch {
            print("❌ There was an error in \(#function) ; \(error.localizedDescription)❌")
        }
        
        let playerItem = AVPlayerItem(asset: asset)
        
        self.player = AVPlayer(playerItem: playerItem)
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
        print("duration \(asset.duration.seconds)")
    }
    
    func playPause() {
        if !isPlaying {
            player.volume = 1.0
            player.play()
            print("▶️ playing!")
        } else {
            player.pause()
            prepareToPlay()
            print("⏸ Paused!")
        }
        isPlaying = !isPlaying
        print("👉👉👉👉 is playing?: \(isPlaying)")
    }
    
    @objc func playerDidFinishPlaying() {
        isPlaying = false
        prepareToPlay()
    }
    
}
