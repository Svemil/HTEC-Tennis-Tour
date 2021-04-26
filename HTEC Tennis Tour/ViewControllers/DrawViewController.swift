//
//  DrawViewController.swift
//  HTEC Tennis Tour
//
//  Created by Svemil Djusic on 22/04/2021.
//

import UIKit

class DrawViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    let numberOfPlayers = 32
    let numberOfSeedPlayers = 16
    
    var drawPlayerList: [PlayerDetails] = []
    var drawPlayerPosition: [PlayerDetails] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        drawPlayerPosition = drawPlayerList
        
        self.drawPlayerList = self.drawPlayerList.sorted(by: {$0.points ?? 0 > $1.points ?? 0})
        
        tableView.delegate = self
        tableView.dataSource = self
        
        drawingPlayers()
        registerCell()
    }
    
    private func registerCell() {
        tableView.register(UINib(nibName: DrawTableViewCell.name, bundle: nil), forCellReuseIdentifier: DrawTableViewCell.name)
    }
    
    func seedPlayer(rank: Int, partSize: Int) -> Int {
        
        if rank <= 1 {
            return 0
        }
        
        if rank % 2 == 0 {
            return partSize / 2 + seedPlayer(rank: rank / 2, partSize: partSize / 2)
        }
        
        return seedPlayer(rank: rank / 2 + 1, partSize: partSize / 2)
    }
    
    
    var seedPositions = [Int]()
    
    var allPlayerPosition = [Int]()
    
    func drawingPlayers() {
        
        for rank in 1...numberOfSeedPlayers {
            
            let position = seedPlayer(rank: rank, partSize: numberOfPlayers) + 1
            
            seedPositions.append(position)
            
            print("seed player rank \(rank) in postion \(position)")
            
            allPlayerPosition.append(position)
            
        }
        
        let allPostions = Set(1...numberOfPlayers)
        
        let closedPositions = Set(seedPositions)
        
        let openPositions = Array(allPostions.subtracting(closedPositions)).shuffled()
        
        
        let otherRanks: [Int] = Array(seedPositions.count + 1...numberOfPlayers)
        
        for (index, rank) in otherRanks.enumerated() {
            
            print("seed player rank \(rank) in postion \(openPositions[index])")
 
            allPlayerPosition.append(openPositions[index])
            
        }
        
        for (index, postion) in allPlayerPosition.enumerated() {

            drawPlayerPosition.remove(at: postion - 1)
            drawPlayerPosition.insert(drawPlayerList[index], at: postion - 1)
        }

        self.tableView.reloadData()
    }
    
}


extension DrawViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 32
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: DrawTableViewCell.name, for: indexPath) as? DrawTableViewCell else {
            fatalError()
        }
        
        cell.playerFirstNameLabel.text = "First name: \( self.drawPlayerPosition[indexPath.row].firstName ?? "")"
        cell.playerLastNameLabel.text = "Last name: \( self.drawPlayerPosition[indexPath.row].lastName ?? "")"
        cell.playerPointsLabel.text = "Points: \(self.drawPlayerPosition[indexPath.row].points ?? 0)"
        
        DispatchQueue.global().async {
            let url = URL(string: self.drawPlayerPosition[indexPath.row].profileImageUrl ?? "http://internships-mobile.htec.co.rs/uploads/player_images/1528126834.png")
            let dataImage = try? Data(contentsOf: url!)
            DispatchQueue.main.async {
                if dataImage != nil {
                    cell.playerImageView.image = UIImage(data: dataImage!)
                } else {
                    cell.playerImageView.image = UIImage()
                }
            }
        }
        
        return cell
    }
    
}
