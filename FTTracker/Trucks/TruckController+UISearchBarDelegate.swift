//
//  TruckController+UISearchBarDelegate.swift
//  FTTracker
//
//  Created by Dylan Bruschi on 5/24/18.
//  Copyright © 2018 Dylan Bruschi. All rights reserved.
//

import UIKit

extension TruckController: UISearchBarDelegate {
    
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchActive = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredFoodTrucks = foodTrucks.filter({ (foodTruck) -> Bool in
            let tmp: FoodTruck = foodTruck
            let range = (tmp.name as NSString).range(of: searchText, options: NSString.CompareOptions.caseInsensitive)
            return range.location != NSNotFound
        })
        if filteredFoodTrucks.count == 0 && searchBar.text != "" {
            searchActive = true
        } else if filteredFoodTrucks.count == 0 && searchBar.text == "" {
            searchActive = false
        } else {
            searchActive = true
        }
        tableView.reloadData()
    }
}
