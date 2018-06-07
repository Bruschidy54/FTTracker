//
//  FoodTruck.swift
//  FTTracker
//
//  Created by Dylan Bruschi on 10/20/17.
//  Copyright © 2017 Dylan Bruschi. All rights reserved.
//

import Foundation
import Firebase

class FoodTruck {
    var rating: Double
    var name: String
    var description: String?
    var category: String?
    var twitter: String?
    var email: String
    var password: String
    var latitude: Double?
    var longitude: Double?
    var uid: String
    var departureTime: Date?
    var joinedDate: Double
    var address: String?
    var distance: Double = 0
    
    
//    var coupon: Coupon?
//    var reviews: [Review]?
    
    // Create a printable description
    
    init(dict: [String:Any]) {
        self.name = dict["name"] as! String
        self.email = dict["email"] as! String
        self.password = dict["password"] as! String
        self.uid = dict["uid"] as! String
        self.rating = dict["rating"] as! Double
        self.description = dict["description"] as? String
        self.category = dict["category"] as? String
        self.twitter = dict["twitter"] as? String
        self.latitude = dict["latitude"] as? Double
        self.longitude = dict["longitude"] as? Double
        if let departTime = dict["departureTime"] as? Double {
        self.departureTime = Date(timeIntervalSince1970: departTime)
        }
        self.joinedDate = dict["joinedDate"] as! Double
        self.address = dict["address"] as? String
    }
}
