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
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        definesPresentationContext = true
        setupNavBar()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
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
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
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
        let searchTerm = searchBar.text ?? ""
        
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
            }
        }
    }
    
}
