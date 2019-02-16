//
//  SongSearchTableViewController.swift
//  SendTrack
//
//  Created by Steve Lederer on 2/7/19.
//  Copyright © 2019 Steve Lederer. All rights reserved.
//

import UIKit

class SongSearchTableViewController: UITableViewController {
    
    // MARK: - Properties
    
    var songs: [SteveSong] = []
    var sharedIdentifier = "group.stevelederer.SendTrack"
    
    let tableViewBackgroundColor = UIColor(hex: "4f9da6")
    
    lazy var timer = AutosearchTimer { [weak self] in self?.searchForSong()}
    var searchTerm: String = ""
 
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = tableViewBackgroundColor
        getPasteboardValue()
        definesPresentationContext = true
        setupNavBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if songs.count == 0 {
            self.navigationItem.title = "Top Songs"
            topSongsFetch()
        }
        tableView.reloadData()
    }
    
    enum ServiceName: String {
        case AppleMusic = "Apple Music"
        case Spotify
    }
    
    func getPasteboardValue() {
        let pasteboardString: String? = UIPasteboard.general.string
        guard let theString = pasteboardString else { return }
        if theString.contains("https://itunes.apple.com") {
            print("apple music link in pasteboard: \(theString)")
            presentClipboardAlert(withServiceName: .AppleMusic, withClipboardLink: theString)
        } else if theString.contains("https://open.spotify.com/") {
            print("spotify link in pasteboard: \(theString)")
            presentClipboardAlert(withServiceName: .Spotify, withClipboardLink: theString)
        }
    }
    
    func presentClipboardAlert(withServiceName serviceName: ServiceName, withClipboardLink clipboardLink: String) {
        let clipboardAlert = UIAlertController(title: "Would you like to search for the \(serviceName.rawValue) song in your clipboard?", message: nil, preferredStyle: .alert)
        clipboardAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (search) in
            if serviceName == .AppleMusic {
                self.appleMusicLinkFetch(appleMusicLink: clipboardLink)
            } else if serviceName == .Spotify {
                self.spotifyLinkFetch(spotifyLink: clipboardLink)
            }
        }))
        clipboardAlert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        self.present(clipboardAlert, animated: true, completion: nil)
    }
    
    func setupNavBar() {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.autocapitalizationType = .sentences
        searchController.searchBar.autocorrectionType = .no
        searchController.searchBar.placeholder = "Search for a song..."
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
                self.tableView.reloadData()
                self.navigationItem.hidesSearchBarWhenScrolling = false
            }
        }
    }
    
    func appleMusicLinkFetch(appleMusicLink: String) {
        AppleMusicController.fetchAppleMusicSong(fromAppleMusicLink: appleMusicLink) { (song) in
            guard let fetchedSong = song else { return }
            var steveSongs: [SteveSong] = []
            if let newSong = SteveSong(appleSong: fetchedSong) {
                steveSongs.append(newSong)
            }
            self.songs = steveSongs
            let songDetailVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "songDetailVC") as! SongDetailViewController
            songDetailVC.song = self.songs.first
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.navigationController?.pushViewController(songDetailVC, animated: true)
                self.navigationItem.hidesSearchBarWhenScrolling = true
            }
        }
    }
    
    func spotifyLinkFetch(spotifyLink: String) {
        SpotifyController.fetchSpotifySong(fromSpotifyLink: spotifyLink) { (song) in
            guard let fetchedSong = song else { return }
            let spotifyISRC = fetchedSong.externalIds.songRecordingCode
            AppleMusicController.matchAppleMusicSong(byISRC: spotifyISRC, completion: { (songs) in
                guard let fetchedSongs = songs else { return }
                var steveSongs: [SteveSong] = []
                for song in fetchedSongs {
                    if let newSong = SteveSong(appleSong: song) {
                        steveSongs.append(newSong)
                    }
                }
                self.songs = steveSongs
                if self.songs.count == 1 {
                    let songDetailVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "songDetailVC") as! SongDetailViewController
                    songDetailVC.song = self.songs.first
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        self.navigationController?.pushViewController(songDetailVC, animated: true)
                    }
                } else if self.songs.count > 1 {
                    self.tableView.reloadData()
                    self.navigationItem.hidesSearchBarWhenScrolling = true
                }
            })
        }
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songs.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "songCell", for: indexPath) as! SongTableViewCell
        let song = songs[indexPath.row]
        cell.delegate = self
        cell.song = song
        cell.updatePlayPauseButton()
        return cell
    }
    
    func animateTable() {
        tableView.reloadData()
        let cells = tableView.visibleCells
        let tableViewHeight = tableView.frame.height
        
        for cell in cells {
            cell.transform = CGAffineTransform(translationX: 0, y: tableViewHeight)
        }
        
        var delayCounter: Double = 0
        
        for cell in cells {
            UIView.animate(withDuration: 1.0, delay: delayCounter * 0.05, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                cell.transform = .identity
            }, completion: nil)
            
            delayCounter += 1
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSongDetailView" {
            guard let indexPath = tableView.indexPathForSelectedRow,
                let destinationVC = segue.destination as? SongDetailViewController else { return }
            let song = songs[indexPath.row]
            destinationVC.song = song
        }
    }
    
}

extension SongSearchTableViewController: SongTableViewCellDelegate {
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

// MARK: - UISearchBarDelegate Functions

extension SongSearchTableViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        let fadeTextAnimation = CATransition()
        fadeTextAnimation.duration = 0.2
        fadeTextAnimation.type = .fade
        navigationController?.navigationBar.layer.add(fadeTextAnimation, forKey: "fadeText")
        navigationItem.title = "Search"
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.dismiss(animated: true, completion: nil)
        guard let searchText = searchBar.text else { return }
        searchTerm = searchText
        
        searchForSong()

        searchBar.text = nil
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
//                self.tableView.reloadData()
                self.animateTable()
                self.navigationItem.hidesSearchBarWhenScrolling = true
            }
        }
    }
}
