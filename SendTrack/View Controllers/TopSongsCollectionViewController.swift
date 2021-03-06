//
//  TopSongsCollectionViewController.swift
//  SendTrack
//
//  Created by Steve Lederer on 2/15/19.
//  Copyright © 2019 Steve Lederer. All rights reserved.
//

import UIKit

class TopSongsCollectionViewController: UICollectionViewController {
    
    // MARK: - Properties
    
    var songs: [SteveSong] = []

//    let collectionViewBackgroundColor = UIColor(hex: "f9f9f9")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
//        collectionView.backgroundColor = collectionViewBackgroundColor
        topSongsFetch()
        definesPresentationContext = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        topSongsFetch()
        collectionView.reloadItems(at: collectionView.indexPathsForVisibleItems)
    }
    
    func topSongsFetch() {
        AppleMusicController.fetchAppleMusicTopCharts { (songs) in
            guard let fetchedSongs = songs else { return }
            var steveSongs: [SteveSong] = []
            for song in fetchedSongs {
                if let newSong = SteveSong(appleSong: song) {
                    steveSongs.append(newSong)
                }
            }
            self.songs = steveSongs
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toTopSongDetailView" {
            guard let indexPaths = collectionView.indexPathsForSelectedItems,
                let indexPath = indexPaths.first,
                let destinationVC = segue.destination as? SongDetailViewController else { return }
            let song = songs[indexPath.row]
            destinationVC.song = song
        }
    }
 
    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return songs.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "topSongCell", for: indexPath) as? TopSongCollectionViewCell else { return UICollectionViewCell() }
        let song = songs[indexPath.row]
        cell.delegate = self
        cell.song = song
        cell.playButtonContainerView.layer.cornerRadius = cell.playButtonContainerView.frame.height / 2
        cell.updatePlayPauseButton()
        return cell
    }

}

extension TopSongsCollectionViewController: TopSongCollectionViewCellDelegate {
    func playPauseButtonTapped(songURLString: String) {
        if PlayerController.shared.isPlaying && songURLString != PlayerController.shared.previewURLString {
            PlayerController.shared.previewURLString = songURLString
            PlayerController.shared.playPause()
        } else if PlayerController.shared.isPlaying && songURLString == PlayerController.shared.previewURLString {
            PlayerController.shared.playPause()
        } else {
            PlayerController.shared.previewURLString = songURLString
            PlayerController.shared.playPause()
        }
        NotificationCenter.default.post(name: .playPauseButtonTappedNotification, object: nil, userInfo: nil)
    }
    
}

extension TopSongsCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if self.view.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClass.regular {
            return CGSize(width: 250, height: 320)
        } else {
            return CGSize(width: 125, height: 160)
        }
    }

}
