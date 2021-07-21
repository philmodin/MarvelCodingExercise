//
//  CharactersTable.swift
//  MarvelCodingExercise
//
//  Created by endOfLine on 7/18/21.
//

import UIKit

class CharactersTable: UITableViewController {

    @IBOutlet var attributionBtn: UIBarButtonItem!
    @IBOutlet var searchBar: UISearchBar!
    
    let manager = MarvelManager(testIsApiAvailable: false)
    let cellID = "Character Cell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.prefetchDataSource = self
        searchBar.delegate = self
        startLoading()
    }
    
    private func startLoading(searching: String? = nil) {
        manager.getCharacterCount(searching: searching) { [weak self] in
            self?.reloadTable()
            self?.getVisibleRows { [weak self] rows in
                for row in rows ?? [] {
                    self?.manager.getCharacter(for: row) { [weak self] in
                        self?.reloadRowIfVisible(at: row)
                    }
                }
            }            
        }
    }
}

// MARK: - Search
extension CharactersTable: UISearchBarDelegate {
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.endEditing(true)
        startLoading()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let validSearch = searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines), !validSearch.isEmpty {
            startLoading(searching: validSearch)
        }
    }
}

// MARK: - Table view display
extension CharactersTable {
    
    private func reloadTable() {
        DispatchQueue.main.async {
            self.attributionBtn.title = self.manager.attribution
            self.tableView.isScrollEnabled = false
            self.tableView.reloadData()
            self.tableView.isScrollEnabled = true
        }
    }
    
    private func reloadRowIfVisible(at row: Int) {
        let indexPath = IndexPath(row: row, section: 0)
        DispatchQueue.main.async {
            if self.tableView.indexPathsForVisibleRows?.contains(indexPath) ?? false {
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        }
    }
    
    private func getVisibleRows(completion: @escaping([Int]?) -> Void) {
        DispatchQueue.main.async { [weak self] in
            if let indexPaths = self?.tableView.indexPathsForVisibleRows {
                let rows = indexPaths.map{ $0.row }
                completion(rows)
                return
            }
            completion(nil)
        }
    }
}

// MARK: - Table view data source
extension CharactersTable {

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return manager.total ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        var name = "loading"
        var image = UIImage(systemName: "photo") ?? UIImage.placeholder
        if let c = manager.characters[indexPath.row], let cName = c?.name {
            name = cName
            if let cImageData = c?.image, let cImage = UIImage(data: cImageData) {
                image = cImage
            }
        }
        cell.textLabel?.text = name
        cell.imageView?.image = image
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var status = ""
        if !manager.isOnline || !manager.isApiAvailable { status = " (offline)" }
        if let total = manager.total {
            var characters = "characters"
            if total == 1 { characters = "character" }
            return "\(total.toDecimalString()) \(characters)\(status)"
        } else {
            return "loading"
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView {
            if !UIAccessibility.isReduceTransparencyEnabled {
                header.tintColor = .clear
                
                let blurEffectViewTag = 8105
                if !header.subviews.contains(where: { $0.tag == blurEffectViewTag }) {
                    let blurEffect = UIBlurEffect(style: .regular)
                    let blurEffectView = UIVisualEffectView(effect: blurEffect)
                    blurEffectView.tag = blurEffectViewTag
                    blurEffectView.frame = header.bounds
                    blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                    header.insertSubview(blurEffectView, at: 0)
                }
            } else {
                header.tintColor = .none
            }
            header.contentView.backgroundColor = .clear
            header.textLabel?.textAlignment = NSTextAlignment.center
        }
    }
}

// MARK: - Prefetch (for Infinite Scrolling)
extension CharactersTable: UITableViewDataSourcePrefetching {
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            if !isRowLoaded(for: indexPath) {
                manager.getCharacter(for: indexPath.row) { [weak self] in
                    self?.reloadRowIfVisible(at: indexPath.row)
                }
            }
        }
    }
    
    private func isRowLoaded(for indexPath: IndexPath) -> Bool {
        return manager.characters.keys.contains(indexPath.row)
    }
}

// MARK: - Navigation
extension CharactersTable {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? CharacterDetails,
           let indexPath = tableView.indexPathForSelectedRow,
           let character = manager.characters[indexPath.row]
        {
            destination.character = character
        }
    }
}

// MARK: - IBActions
extension CharactersTable {
    
    @IBAction func attributionBtnTapped(_ sender: UIBarButtonItem) {
        if let url = URL(string: "http://marvel.com") {
            UIApplication.shared.open(url)
        }
    }
}
