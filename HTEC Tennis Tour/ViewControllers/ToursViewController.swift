//
//  ToursViewController.swift
//  HTEC Tennis Tour
//
//  Created by Svemil Djusic on 17/04/2021.
//

import UIKit

class ToursViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var toursArray:[Int] = Array()
    var limit = 20
    var indexOfSelectedRow: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Tournaments"

        tableView.delegate = self
        tableView.dataSource = self
        
        registerCell()
        showTours()
    }
    
    private func registerCell() {
        tableView.register(UINib(nibName: TourTableViewCell.name, bundle: nil), forCellReuseIdentifier: TourTableViewCell.name)
    }
    
    func showTours() {
        var index = 0
        while index < limit {
            toursArray.append(index)
            index += 1
        }
    }
    
    func uploadNewTours(totalTours: Int) {
        
        if toursArray.count < totalTours {
            var index = toursArray.count
            limit = index + 20
            while index < limit {
                toursArray.append(index)
                index += 1
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showTourPlayers" {
            let destinacionVC = segue.destination as! TourPlayersViewController
            destinacionVC.tournamentId = indexOfSelectedRow
            
        }
    }

}

extension ToursViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return toursArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TourTableViewCell.name, for: indexPath) as? TourTableViewCell else {
            fatalError()
        }
        
        cell.tourNameLabel.text = "Serbian Open \(indexPath.row + 1)"

        cell.selectionStyle = .none
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        indexOfSelectedRow = indexPath.row + 1
        self.performSegue(withIdentifier: "showTourPlayers", sender: self)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.row == toursArray.count - 1 {
            uploadNewTours(totalTours: 100)
        }
    }
}
