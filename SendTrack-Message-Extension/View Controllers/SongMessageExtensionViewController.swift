//
//  SongMessageExtensionViewController.swift
//  SendTrack-Message-Extension
//
//  Created by Steve Lederer on 2/18/19.
//  Copyright © 2019 Steve Lederer. All rights reserved.
//

import UIKit

class SongMessageExtensionViewController: UIViewController {
    
    // MARK: - Properties
    
    @IBOutlet weak var songCollectionView: UICollectionView!
    @IBOutlet weak var songSearchBar: UISearchBar!
    
    var songs: [SteveSong] = []
        
    lazy var timer = AutosearchTimer { [weak self] in self?.searchForSong() }
    var searchTerm: String = ""
    
    var delegate: SongMessageExtensionViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        songCollectionView.dataSource = self
        definesPresentationContext = true
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            songCollectionView.contentInset.bottom = keyboardSize.height + 15
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        songCollectionView.contentInset.bottom = 0
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        topSongsFetch()
        songCollectionView.reloadItems(at: songCollectionView.indexPathsForVisibleItems)
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
                self.songCollectionView.reloadData()
            }
        }
    }
    
    func engageSearchBar() {
        songSearchBar.becomeFirstResponder()
    }
    
}

extension SongMessageExtensionViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return songs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "topSongCell", for: indexPath) as? TopSongCollectionViewCell else { return UICollectionViewCell() }
        let song = songs[indexPath.row]
        cell.delegate = self
        cell.song = song
        cell.updatePlayPauseButton()
        return cell
    }

}

extension SongMessageExtensionViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? TopSongCollectionViewCell else { return }
        guard var song = cell.song else { return }
        SpotifyController.matchSpotifySong(byISRC: song.songRecordingCode) { (songs) in
            guard let fetchedSongs = songs else { return }
            if fetchedSongs.count >= 1 {
                song.spotifySongLink = fetchedSongs.first?.externalUrls.spotifyLink
            } else {
                SpotifyController.matchSpotifySong(bySongName: song.songName, artistName: song.artistName, albumName: song.albumName, completion: { (songs) in
                    if let fetchedSongs = songs {
                        song.spotifySongLink = fetchedSongs.first?.externalUrls.spotifyLink
                    }
                })
            }
            DispatchQueue.main.async {
                let linkTypeActionSheet = UIAlertController(title: nil, message: "Which link do you want to share?", preferredStyle: .actionSheet)
                let appleLinkAction = UIAlertAction(title: "Apple Music", style: .default, handler: { (appleLink) in
                    guard let link = song.appleSongLink else { return }
                    self.delegate?.didSelectSongItem(link: link)
                })
                let spotifyLinkAction = UIAlertAction(title: "Spotify", style: .default, handler: { (spotifyLink) in
                    guard let link = song.spotifySongLink else { return }
                    self.delegate?.didSelectSongItem(link: link)
                })
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                linkTypeActionSheet.addAction(appleLinkAction)
                if song.spotifySongLink != nil {
                    linkTypeActionSheet.addAction(spotifyLinkAction)
                }
                linkTypeActionSheet.addAction(cancelAction)
                
                if let popoverController = linkTypeActionSheet.popoverPresentationController {
                    popoverController.sourceView = self.view
                    popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
                    popoverController.permittedArrowDirections = []
                }
                
                self.present(linkTypeActionSheet, animated: true, completion: nil)
            }
        }
        
    }
}

extension SongMessageExtensionViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.delegate?.viewShouldExpand()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text else { return }
        searchTerm = searchText
        
        searchForSong()
        
        searchBar.endEditing(true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let searchText = searchBar.text else { return }
        searchTerm = searchText
        timer.activate()
    }
    
    @objc func searchForSong() {
        timer.cancel()
        
        AppleMusicController.fetchAppleMusicSongs(with: searchTerm) { (songs) in
            guard let fetchedSongs = songs else { return }
            var steveSongs: [SteveSong] = []
            for song in fetchedSongs {
                if let newSong = SteveSong(appleSong: song) {
                    steveSongs.append(newSong)
                }
            }
            self.songs = steveSongs
            DispatchQueue.main.async {
                self.songCollectionView.reloadData()
            }
        }
    }
}

extension SongMessageExtensionViewController: TopSongCollectionViewCellDelegate {
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
        NotificationCenter.default.post(name: .playPauseNotification, object: nil, userInfo: nil)
    }
    
}

protocol SongMessageExtensionViewControllerDelegate: class {
    func didSelectSongItem(link: String)
    func viewShouldExpand()
}
