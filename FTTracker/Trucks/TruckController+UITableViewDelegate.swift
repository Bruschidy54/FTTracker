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
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! FoodTruckTableViewCell
            var foodTruck: FoodTruck?
            if searchActive && filteredFoodTrucks.count > 0 {
                foodTruck = filteredFoodTrucks[indexPath.row]
                print(foodTruck?.name)
            } else if searchActive && filteredFoodTrucks.count == 0 {
                foodTruck = nil
                // TO DO: remove cells and write (similar to GTD style: "Your search did not match any entries. Try again."
            } else if !searchActive && foodTrucks.count == 0 {
                foodTruck = nil
                // TO DO: remove cells and write (similar to GTD style: "No food trucks at this time."
            } else {
                foodTruck = foodTrucks[indexPath.row]
            }
        
        
        cell.foodTruck = foodTruck
        
            return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 134
    }
}
