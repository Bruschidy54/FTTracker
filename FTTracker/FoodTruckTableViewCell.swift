//
//  FoodTruckTableViewCell.swift
//  FTTracker
//
//  Created by Dylan Bruschi on 10/25/17.
//  Copyright © 2017 Dylan Bruschi. All rights reserved.
//

import UIKit

class FoodTruckTableViewCell: UITableViewCell {
    @IBOutlet var logoImage: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var ratingView: CosmosView!
    @IBOutlet var numberOfReviewsLabel: UILabel!
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var categoryLabel: UILabel!
    @IBOutlet var distanceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
