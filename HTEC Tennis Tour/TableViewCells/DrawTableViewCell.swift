//
//  DrawTableViewCell.swift
//  HTEC Tennis Tour
//
//  Created by Svemil Djusic on 22/04/2021.
//

import UIKit

class DrawTableViewCell: UITableViewCell {

    @IBOutlet weak var playerImageView: UIImageView!
    @IBOutlet weak var playerFirstNameLabel: UILabel!
    @IBOutlet weak var playerLastNameLabel: UILabel!
    @IBOutlet weak var playerPointsLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
