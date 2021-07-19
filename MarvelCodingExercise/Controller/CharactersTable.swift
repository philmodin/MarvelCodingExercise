//
//  CharactersTable.swift
//  MarvelCodingExercise
//
//  Created by endOfLine on 7/18/21.
//

import UIKit

class CharactersTable: UITableViewController {

    var manager = MarvelManager()
    let cellID = "Character Cell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //manager.deleteAll()
        startLoading()
    }
    
    private func startLoading(searching: String? = nil) {
        manager.getCharacterCount { [weak self] in
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
    
    private func reloadTable() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
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
        var image = UIImage(systemName: "photo") ?? UIImage() // TODO placeholder image
        if let c = manager.characters[indexPath.row], let cName = c.name {
            name = cName
            if let cImageData = c.image, let cImage = UIImage(data: cImageData) {
                image = cImage
            }
        }
        cell.textLabel?.text = name
        cell.imageView?.image = image
        
        return cell
    }
}
// MARK: - Navigation
extension CharactersTable {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
}
