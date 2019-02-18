//
//  TopSongMessagesCollectionViewController.swift
//  SendTrack-Message-Extension
//
//  Created by Steve Lederer on 2/17/19.
//  Copyright © 2019 Steve Lederer. All rights reserved.
//

import UIKit

class TopSongMessagesCollectionViewController: UICollectionViewController {

    
    // MARK: - Properties
    
    var songs: [SteveSong] = []
    
    let collectionViewBackgroundColor = UIColor(hex: "4f9da6")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.backgroundColor = collectionViewBackgroundColor
        definesPresentationContext = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

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
//        cell.delegate = self
        cell.song = song
        cell.updatePlayPauseButton()
        return cell
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
