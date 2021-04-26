//
//  Player.swift
//  HTEC Tennis Tour
//
//  Created by Svemil Djusic on 18/04/2021.
//

import Foundation

struct Player: Decodable {
    let id: Int?
    let firstName: String?
    let lastName: String?
    let points: Int?
    let isProfessional: Bool?
    let tournament_id: Int?
}

struct PlayerDetails: Decodable {
    let id: Int?
    let firstName: String?
    let lastName: String?
    let description: String?
    let points: Int?
    let dateOfBirth: String?
    let profileImageUrl: String?
    let isProfessional: Bool?
    let tournamentId: Int?
}
