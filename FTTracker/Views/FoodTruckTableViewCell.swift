//
//  FoodTruckTableViewCell.swift
//  FTTracker
//
//  Created by Dylan Bruschi on 10/25/17.
//  Copyright © 2017 Dylan Bruschi. All rights reserved.
//

import UIKit
import Cosmos
import SDWebImage
import CoreLocation

class FoodTruckTableViewCell: UITableViewCell {
    @IBOutlet var logoImage: UIImageView! {
        didSet {
            logoImage.layer.cornerRadius = 5
            logoImage.clipsToBounds = true
        }
    }
    @IBOutlet var titleLabel: UILabel! {
        didSet {
            titleLabel.preferredMaxLayoutWidth = titleLabel.frame.size.width
    }
    }
    @IBOutlet var ratingView: CosmosView!
    @IBOutlet var numberOfReviewsLabel: UILabel!
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var categoryLabel: UILabel!
    @IBOutlet var distanceLabel: UILabel!
    
    var foodTruck: FoodTruck? {
        didSet {
            guard let foodTruck = foodTruck else { return }
            
                if let latitude = foodTruck.latitude, let longitude = foodTruck.longitude {
                    setAddressLabelFromGeocodeCoordinate(location: CLLocation(latitude: latitude, longitude: longitude))
                    self.distanceLabel.text = String(format: "%0.2f mi.", foodTruck.distance)
                } else {
                    self.distanceLabel.text = "Location not listed"
                }
            
            let imageURL = URL(string: foodTruck.imageUrl ?? "")
            
             logoImage.sd_setImage(with: imageURL, placeholderImage: #imageLiteral(resourceName: "QuestionMarkImage"), options: .highPriority, completed: nil)
            
            self.numberOfReviewsLabel.text = "55"
            
            self.titleLabel.text = foodTruck.name

                self.ratingView.rating = foodTruck.rating
                self.categoryLabel.text = foodTruck.category
                self.addressLabel.text = foodTruck.address
        }
    }
    
    
    private func setAddressLabelFromGeocodeCoordinate(location: CLLocation) {
        let geocoder = CLGeocoder()
        
        geocoder.reverseGeocodeLocation(location, completionHandler:
            {(placemarks, error) in
                if (error != nil)
                {
                    print("reverse geodcode fail: \(error!.localizedDescription)")
                }
                let pm = placemarks! as [CLPlacemark]
                
                if pm.count > 0 {
                    let pm = placemarks![0]
                    
                    var addressString : String = ""
                    if pm.subLocality != nil {
                        addressString = addressString + pm.subLocality! + ", "
                    }
                    if pm.thoroughfare != nil {
                        addressString = addressString + pm.thoroughfare! + ", "
                    }
                    if pm.locality != nil {
                        addressString = addressString + pm.locality! + ", "
                    }
                    if pm.country != nil {
                        addressString = addressString + pm.country! + ", "
                    }
                    if pm.postalCode != nil {
                        addressString = addressString + pm.postalCode! + " "
                    }
                    
                    self.addressLabel.text = addressString
                }
        })
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
