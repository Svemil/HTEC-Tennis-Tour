//
//  TourPlayersViewController.swift
//  HTEC Tennis Tour
//
//  Created by Svemil Djusic on 17/04/2021.
//

import UIKit

class TourPlayersViewController: UIViewController, NewPlayerOnTour {
    
    @IBOutlet weak var tableView: UITableView!
    
    var currentPlayerRating = [Player]()
    var indexOfSelectedRow: Int!
    var addNewPlayer = false
    var tournamentId: Int!
    
    var arrayOfPlayersId: [Int] = []
    var arrayOfPlayerInfo: [PlayerDetails] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Players"

        tableView.delegate = self
        tableView.dataSource = self
        
        registerCell()
        
        listPlayersForCurrentTour()
        
        let addPlayerButton = UIBarButtonItem(title: "Add Player", style: .plain, target: self, action: #selector(addPlayer))
        let drawButton = UIBarButtonItem(title: "Draw", style: .plain, target: self, action: #selector(showDrawView))
        
        navigationItem.rightBarButtonItems = [drawButton, addPlayerButton]
    }
    
    private func registerCell() {
        tableView.register(UINib(nibName: PlayerTableViewCell.name, bundle: nil), forCellReuseIdentifier: PlayerTableViewCell.name)
    }
    
    private func listPlayersForCurrentTour() {
        
        currentPlayerRating.removeAll()
        
        APIRequests.shared.getAllTennisPlayers(tournamentId: tournamentId) { (playerArray, successfully) in
            
            guard let successfully = successfully else {
                AlertHelper.showAlertMessage(message: "Server or internet error, can not display players", viewController: self)
                return
            }
            
            guard let playerArray = playerArray else {
                return
            }
            
            if successfully {
                
                DispatchQueue.main.async {
                    
                    self.currentPlayerRating = playerArray.sorted(by: {$0.points ?? 0 > $1.points ?? 0})
                    self.tableView.reloadData()
                    
                    self.packingPlayersForDraw()
                }
                
            } else {
                AlertHelper.showAlertMessage(message: "Server or internet error, can not display players", viewController: self)
            }
            
        }
    }
    
    func packingPlayersForDraw() {
        
        //moram ovo da radim jer u listi igraca na turniru ne postoji parametar URL slike, tako da moram da prodjem kroz petlju da pokupim detaljnje inforacije o igracima. Okidam servis 32 puta znam da ne treba tako al ne vidm drugi nacin za kupljenje slike
        
        var arrayOfId: [Int] = []
        
        for player in self.currentPlayerRating {
            if player.tournament_id == nil {
                arrayOfId.append(player.id!)
            }
        }
        self.arrayOfPlayersId = Array(arrayOfId.prefix(32))
        
        for playerId in self.arrayOfPlayersId {
            
            APIRequests.shared.displaySpecifiedPlayer(tournamentId: self.tournamentId, playerId: playerId) { (playerInfo) in
                
                self.arrayOfPlayerInfo.append(playerInfo)
            }
        }
    }
    
    @objc func addPlayer() {
        addNewPlayer = true
        self.performSegue(withIdentifier: "showPlayerDetails", sender: self)
    }
    
    @objc func showDrawView() {
        if arrayOfPlayerInfo.count == 32 {
            self.performSegue(withIdentifier: "showDraw", sender: self)
        } else {
            AlertHelper.showAlertMessage(message: "Server or internet error, do not have 32 players, try again", viewController: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPlayerDetails" {
            let destinacionVC = segue.destination as! PlayerInfoViewController
            destinacionVC.addNewPlayer = addNewPlayer
            destinacionVC.tournamentId = tournamentId
            destinacionVC.newDelegate = self
            
            if !addNewPlayer {
                destinacionVC.playerId = currentPlayerRating[self.indexOfSelectedRow].id
                destinacionVC.canEditCurrentPlayer = currentPlayerRating[self.indexOfSelectedRow].tournament_id == tournamentId ? true : false
            }
        }
        if segue.identifier == "showDraw" {
            let destinacionVC = segue.destination as! DrawViewController
            destinacionVC.drawPlayerList = arrayOfPlayerInfo
        }
    }
    
    func updateOrAddPlayerOnTour(player: Player?, updatePlayer: Bool) {
        if player != nil {
            
            if updatePlayer {
                // u responsu u okviru data ne dobija parametar tournament_id, tako da moram ovako da ga setujem
                let updatedPlayer = Player(id: player?.id, firstName: player?.firstName, lastName: player?.lastName, points: player?.points, isProfessional: player?.isProfessional, tournament_id: tournamentId)
                
                if let row = self.currentPlayerRating.firstIndex(where: {$0.id == updatedPlayer.id}) {
                    self.currentPlayerRating[row] = updatedPlayer
                }
                
            } else {
                // u responsu u okviru data vraca se parametar tournament_id ali je tip String, da ne bi pravio novi objekat samo zbog toga ovde setujem tournament_id
                self.currentPlayerRating.append(Player(id: player?.id, firstName: player?.firstName, lastName: player?.lastName, points: player?.points, isProfessional: player?.isProfessional, tournament_id: tournamentId))
            }
            
            self.currentPlayerRating = self.currentPlayerRating.sorted(by: {$0.points ?? 0 > $1.points ?? 0})
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

}

extension TourPlayersViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentPlayerRating.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PlayerTableViewCell.name, for: indexPath) as? PlayerTableViewCell else {
            fatalError()
        }
        
        cell.playerNameLabel.text = "\(currentPlayerRating[indexPath.row].firstName ?? "") \(currentPlayerRating[indexPath.row].lastName ?? "")"
        cell.playerRankingLabel.text = "Ranking: \(indexPath.row + 1)"
        cell.playerPointsLabel.text = "Points: \(currentPlayerRating[indexPath.row].points ?? 0)"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.indexOfSelectedRow = indexPath.row
        addNewPlayer = false
        self.performSegue(withIdentifier: "showPlayerDetails", sender: self)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        if currentPlayerRating[indexPath.row].tournament_id == tournamentId {
            
            let delete = UIContextualAction(style: .normal, title: "Delete") { (action, view, completion) in
                
                APIRequests.shared.deletePlayerFromStorage(playerId: self.currentPlayerRating[indexPath.row].id!) { (successfully) in
                    
                    guard let successfully = successfully else {
                        AlertHelper.showAlertMessage(message: "Server or internet error, can not delete player", viewController: self)
                        return
                    }
                    
                    if successfully {
                        DispatchQueue.main.async {
                            self.currentPlayerRating.remove(at: indexPath.row)
                            tableView.deleteRows(at: [indexPath], with: .automatic)
                        }
                    } else {
                        AlertHelper.showAlertMessage(message: "Server or internet error, can not delete player", viewController: self)
                    }
                }
                
                completion(false)
            }
            delete.backgroundColor = UIColor.red
            let confige = UISwipeActionsConfiguration(actions: [delete])
            return confige
        } else {
            return UISwipeActionsConfiguration()
        }
    }
    
}
