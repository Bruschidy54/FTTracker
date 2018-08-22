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
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.text = "No Available Food Trucks"
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.textAlignment = .center
        label.textColor = .themeRed
        return label
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return filteredFoodTrucks.isEmpty && searchActive || foodTrucks.isEmpty ? 134 : 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath)
        self.performSegue(withIdentifier: "TruckDetailSegue", sender: cell)
    }
    
}
