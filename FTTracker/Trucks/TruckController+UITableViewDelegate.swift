//
//  TruckController+UITableViewDelegate.swift
//  FTTracker
//
//  Created by Dylan Bruschi on 5/24/18.
//  Copyright © 2018 Dylan Bruschi. All rights reserved.
//

import UIKit
import CoreLocation

extension TruckController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(searchActive) {
            return filteredFoodTrucks.count
        } else {
            return foodTrucks.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "TruckCell"
        if let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? FoodTruckTableViewCell {
            var foodTruck: FoodTruck?
            if searchActive && filteredFoodTrucks.count > 0 {
                foodTruck = filteredFoodTrucks[indexPath.row]
                print(foodTruck)
            } else if searchActive && filteredFoodTrucks.count == 0 {
                foodTruck = nil
                // TO DO: remove cells and write (similar to GTD style: "Your search did not match any entries. Try again."
            } else if !searchActive && foodTrucks.count == 0 {
                foodTruck = nil
                // TO DO: remove cells and write (similar to GTD style: "No food trucks at this time."
            } else {
                foodTruck = foodTrucks[indexPath.row]
            }
            if let truck = foodTruck {
                if let latitude = truck.latitude, let longitude = truck.longitude {
                    
                    getAddressFromGeocodeCoordinate(location: CLLocation(latitude: latitude, longitude: longitude), cell: cell)
                    cell.distanceLabel.text = String(format: "%0.2f mi.", truck.distance)
                } else {
                    cell.distanceLabel.text = "Location not listed"
                }
                cell.titleLabel.text = truck.name
                cell.titleLabel.preferredMaxLayoutWidth = cell.titleLabel.frame.size.width
                // TO DO: Update to include new image system
                cell.logoImage.image = conversion(post: "")
                cell.logoImage.layer.cornerRadius = 5
                cell.logoImage.clipsToBounds = true
                cell.ratingView.rating = truck.rating
                // cell.numberOfReviewsLabel.text = String(truck.ratings.count)
                cell.categoryLabel.text = truck.category
                cell.addressLabel.text = truck.address
            }
            return cell
        }
        return FoodTruckTableViewCell()
    }
}
