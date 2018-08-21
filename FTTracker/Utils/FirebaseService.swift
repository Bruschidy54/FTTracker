//
//  FirebaseService.swift
//  FTTracker
//
//  Created by Dylan Bruschi on 8/19/18.
//  Copyright © 2018 Dylan Bruschi. All rights reserved.
//

import Foundation
import Firebase

class FirebaseService {
    
    static let shared = FirebaseService()
    
    
    func queryFoodTrucks(callback: @escaping (_ foodTrucks: [FoodTruck]) -> Void) {
        
        var foodTrucks = [FoodTruck]()
        
        let ref = Database.database().reference()
        let foodTruckRef = ref.child("FoodTrucks")
        
        
        foodTruckRef.observe(.value, with: { snapshot in
            print(snapshot.childrenCount)
            let enumerator = snapshot.children
            while let rest = enumerator.nextObject() as? DataSnapshot {
                guard let foodTruckDict = rest.value as? [String:Any] else { return }
                let foodTruck = FoodTruck.init(dict: foodTruckDict)
                print("created food truck: \(foodTruck.uid)")
                
                foodTrucks.append(foodTruck)
            }
            foodTrucks.sort(by: { $0.distance < $1.distance})
            callback(foodTrucks)
        })
    }
    
}
