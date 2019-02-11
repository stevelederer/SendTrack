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
//    var shouldSearch = true
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        definesPresentationContext = true
        setupNavBar()
    }
    
    func setupNavBar() {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.autocapitalizationType = .words
        searchController.searchBar.autocorrectionType = .yes
        searchController.searchBar.placeholder = "Search for a song..."
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songs.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "songCell", for: indexPath) as! SongTableViewCell
        let song = songs[indexPath.row]
        cell.song = song
        return cell
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

extension SongSearchTableViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let searchTerm = searchBar.text ?? ""
        self.dismiss(animated: true, completion: nil)
        
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
                self.tableView.reloadData()
                self.navigationItem.hidesSearchBarWhenScrolling = true
                searchBar.text = nil
            }
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        guard shouldSearch else { return }
//        shouldSearch = false
//        searchForSong(with: searchText)
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.searchForSong(_:)), object: nil)
        perform(#selector(self.searchForSong(_:)), with: searchBar, afterDelay: 0.5)
        
    }
    
    @objc func searchForSong(_ searchBar: UISearchBar) {
        guard let searchTerm = searchBar.text, !searchTerm.isEmpty else { return }
        
        AppleMusicController.fetchAppleMusicSongs(with: searchTerm) { (songs) in
//            guard let fetchedSongs = songs else { self.shouldSearch = true ; return }
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
                self.navigationItem.hidesSearchBarWhenScrolling = true
//                self.shouldSearch = true
            }
        }
    }
}
