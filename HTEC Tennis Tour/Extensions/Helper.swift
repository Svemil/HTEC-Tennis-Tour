//
//  Helper.swift
//  HTEC Tennis Tour
//
//  Created by Svemil Djusic on 22/04/2021.
//

import UIKit

protocol NewPlayerOnTour {
    func updateOrAddPlayerOnTour(player: Player?, updatePlayer: Bool)
}

public func convertDateFormater(_ date: String, current_formate : String, expected_formate: String) -> String{
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = current_formate
    let date = dateFormatter.date(from: date)
    dateFormatter.dateFormat = expected_formate
    return  dateFormatter.string(from: date!)
}
