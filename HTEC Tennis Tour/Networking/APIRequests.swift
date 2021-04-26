//
//  APIRequests.swift
//  HTEC Tennis Tour
//
//  Created by Svemil Djusic on 18/04/2021.
//

import Foundation

class APIRequests {
    
    let BASE_URL: String = "http://internships-mobile.htec.co.rs/api/"
    
    static let shared = APIRequests()
    
    func getAllTennisPlayers(tournamentId: Int, completion: @escaping([Player]?, Bool?) -> Void) {
        
        guard let serviceUrl = URL(string: BASE_URL + "players") else { return }
        
        var request = URLRequest(url: serviceUrl)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("\(tournamentId)", forHTTPHeaderField: "x-tournament-id")
        
        let session = URLSession.shared
        
        session.dataTask(with: request) { (data, response, error) in
            
            if let httpResponse = response as? HTTPURLResponse {
                print("statusCode: \(httpResponse.statusCode)")
                
                if httpResponse.statusCode == 200 {
 
                    if let data = data {
                        
                        do {
                            
                            let json = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary
                            
                            guard let dictionary = json?["data"] as? NSArray else { return }
                            var playerArray: [Player] = []
                            
                            for player in dictionary {
                                
                                if let info = player as? NSDictionary {
                                    
                                    playerArray.append(Player(id: info["id"] as? Int, firstName: info["firstName"] as? String, lastName: info["lastName"] as? String, points: info["points"] as? Int, isProfessional: info["isProfessional"] as? Bool, tournament_id: info["tournament_id"] as? Int))
                                }
                            }
                            completion(playerArray, true)
                            
                        } catch let error {
                            print(error.localizedDescription)
                            completion(nil, false)
                        }
                    }
                    
                } else {
                    completion(nil, false)
                }
            }
            
        }.resume()
    }
    
    func displaySpecifiedPlayer(tournamentId: Int, playerId: Int, completion: @escaping((PlayerDetails) -> Void)) {
        
        guard let serviceUrl = URL(string: BASE_URL + "players/\(playerId)") else { return }
        
        var request = URLRequest(url: serviceUrl)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("\(tournamentId)", forHTTPHeaderField: "x-tournament-id")
        
        let session = URLSession.shared
        
        session.dataTask(with: request) { (data, response, error) in
            
            if let httpResponse = response as? HTTPURLResponse {
                print("statusCode: \(httpResponse.statusCode)")
                
                if httpResponse.statusCode == 200 {
                    
                    if let data = data {
                        
                        do {
                            
                            let json = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary
                            
                            guard let dictionary = json?["data"] as? NSDictionary else { return }
                            
                            completion(PlayerDetails(id: dictionary["id"] as? Int, firstName: dictionary["firstName"] as? String, lastName: dictionary["lastName"] as? String, description: dictionary["description"] as? String, points: dictionary["points"] as? Int, dateOfBirth: dictionary["dateOfBirth"] as? String, profileImageUrl: dictionary["profileImageUrl"] as? String, isProfessional: dictionary["isProfessional"] as? Bool, tournamentId: dictionary["tournament_id"] as? Int))
                            
                            print("JSON:", json ?? "nil")
                            
                        } catch let error {
                            print(error.localizedDescription)
                        }
                    }
                }
                
            }
            
        }.resume()
        
    }
    
    func storeNewlyCreatedPlayer(tournamentId: Int, playerId: Int, firstName: String, lastName: String, description: String, points: Int, dateOfBirth: String, isProfessional: Bool, profileImageUrl: String, completion: @escaping(Player?, Bool?) -> Void) {
        
        guard let serviceUrl = URL(string: BASE_URL + "players") else { return }
        
        let parameterDictionary = ["id": playerId,
                                   "firstName": firstName,
                                   "lastName": lastName,
                                   "description": description,
                                   "points": points,
                                   "dateOfBirth": dateOfBirth,
                                   "isProfessional": isProfessional,
                                   "profileImageUrl": profileImageUrl] as [String : Any]
        
        var request = URLRequest(url: serviceUrl)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("\(tournamentId)", forHTTPHeaderField: "x-tournament-id")
        
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameterDictionary, options: []) else { return }
        
        request.httpBody = httpBody
        
        let session = URLSession.shared
        
        session.dataTask(with: request) { (data, response, error) in
            
            if let httpResponse = response as? HTTPURLResponse {
                print("statusCode: \(httpResponse.statusCode)")
                
                if httpResponse.statusCode == 200 {
                    
                    if let data = data {
                        
                        do {
                            let json = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary
                            
                            guard let dictionary = json?["data"] as? NSDictionary else { return }
                            
                            print("dictionary:", dictionary)
                            
                            let newPlayer = Player(id: dictionary["id"] as? Int, firstName: dictionary["firstName"] as? String, lastName: dictionary["lastName"] as? String, points: dictionary["points"] as? Int, isProfessional: dictionary["isProfessional"] as? Bool, tournament_id: dictionary["tournament_id"] as? Int)
                            
                            completion(newPlayer, true)
                            
                        } catch let error {
                            print(error.localizedDescription)
                            completion(nil, false)
                        }
                        
                    }
                    
                } else {
                    completion(nil, false)
                }
            }
            
        }.resume()
        
    }
    
    func updateSpecifiedPlayerInStore(tournamentId: Int, playerId: Int, firstName: String, lastName: String, description: String, points: Int, dateOfBirth: String, isProfessional: Bool, profileImageUrl: String, completion: @escaping(Player?, Bool?) -> Void) {
        
        guard let serviceUrl = URL(string: BASE_URL + "players/\(playerId)") else { return }
        
        let parameterDictionary = ["id": playerId,
                                   "firstName": firstName,
                                   "lastName": lastName,
                                   "description": description,
                                   "points": points,
                                   "dateOfBirth": dateOfBirth,
                                   "isProfessional": isProfessional,
                                   "profileImageUrl": profileImageUrl] as [String : Any]
        
        var request = URLRequest(url: serviceUrl)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("\(tournamentId)", forHTTPHeaderField: "x-tournament-id")
        
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameterDictionary, options: []) else { return }
        
        request.httpBody = httpBody
        
        let session = URLSession.shared
        
        session.dataTask(with: request) { (data, response, error) in
            
            if let httpResponse = response as? HTTPURLResponse {
                print("statusCode: \(httpResponse.statusCode)")
                
                if httpResponse.statusCode == 200 {
                    
                    if let data = data {
                        
                        do {
                            let json = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary
                            
                            guard let dictionary = json?["data"] as? NSDictionary else { return }
                            
                            print("dictionary:", dictionary)
                            
                            let newPlayer = Player(id: dictionary["id"] as? Int, firstName: dictionary["firstName"] as? String, lastName: dictionary["lastName"] as? String, points: dictionary["points"] as? Int, isProfessional: dictionary["isProfessional"] as? Bool, tournament_id: dictionary["tournament_id"] as? Int)
                            
                            completion(newPlayer, true)
                            
                        } catch let error {
                            print(error.localizedDescription)
                            completion(nil, false)
                        }
                        
                    }
                    
                } else {
                    completion(nil, false)
                }
            }
            
        }.resume()
        
    }
    
    func deletePlayerFromStorage(playerId: Int, completion: @escaping(Bool?) -> Void) {
        
        guard let serviceUrl = URL(string: BASE_URL + "players/\(playerId)") else { return }
        
        var request = URLRequest(url: serviceUrl)
        request.httpMethod = "DELETE"
        
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("1", forHTTPHeaderField: "x-tournament-id")
        
        let session = URLSession.shared
        
        session.dataTask(with: request) { (data, response, error) in
            
            if let httpResponse = response as? HTTPURLResponse {
                print("statusCode: \(httpResponse.statusCode)")
                
                if httpResponse.statusCode == 200 {
                    
                    if let data = data {
                        
                        do {
                            let json = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary
                            
                            print("JSON:", json ?? "nil")
                            
                            completion(true)
                            
                        } catch let error {
                            print(error.localizedDescription)
                        }
                        
                    }
                } else {
                    completion(false)
                }
            }
        }.resume()
        
    }
    
}
