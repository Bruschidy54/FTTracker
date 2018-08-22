//
//  TruckDetailController.swift
//  FTTracker
//
//  Created by Dylan Bruschi on 8/21/18.
//  Copyright © 2018 Dylan Bruschi. All rights reserved.
//

import UIKit

class TruckDetailController: UIViewController {
    
    var foodTruck: FoodTruck? {
        didSet {
            self.tabBarController?.navigationItem.title = foodTruck?.name
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .red
    }
}
