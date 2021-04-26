//
//  TourTableViewCell.swift
//  HTEC Tennis Tour
//
//  Created by Svemil Djusic on 17/04/2021.
//

import UIKit

class TourTableViewCell: UITableViewCell {
    
    @IBOutlet weak var tourNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
