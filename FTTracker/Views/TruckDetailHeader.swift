//
//  TruckDetailHeader.swift
//  FTTracker
//
//  Created by Dylan Bruschi on 8/22/18.
//  Copyright © 2018 Dylan Bruschi. All rights reserved.
//

import UIKit
import Cosmos
import MapKit

class TruckDetailHeader: UICollectionViewCell {
    
    @IBOutlet weak var truckImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ratingView: CosmosView!
    @IBOutlet weak var numberOfRatingsLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var descriptionView: UITextView!
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
    
    var foodTruck: FoodTruck? {
        didSet {
            
            guard let foodTruck = foodTruck else { return }
            
              if let latitude = foodTruck.latitude, let longitude = foodTruck.longitude {
                setAddressLabelFromGeocodeCoordinate(location: CLLocation(latitude: latitude, longitude: longitude))
                
                let centerCoordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                
                let region = MKCoordinateRegionMakeWithDistance(centerCoordinate, 500, 500)
                mapView.setRegion(region, animated: false)
                
                let distanceString = String(format: "%0.2f mi.", foodTruck.distance)
                self.descriptionView.text = "\(distanceString) away \n\n\(foodTruck.description ?? "")"
            }
            
            dropPinForFoodTruck(foodTruck: foodTruck)
            
            let imageURL = URL(string: foodTruck.imageUrl ?? "")
            
            truckImageView.sd_setImage(with: imageURL, placeholderImage: #imageLiteral(resourceName: "QuestionMarkImage"), options: .highPriority, completed: nil)
            
            self.numberOfRatingsLabel.text = "55"
            
            self.nameLabel.text = foodTruck.name
            
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
    
    func dropPinForFoodTruck(foodTruck: FoodTruck) {
        //        let geoCoder = CLGeocoder()
        //        geoCoder.geocodeAddressString(foodTruck.address) { (placemarks : [CLPlacemark]?, error : NSError?) in
        //            for placemark in placemarks! {
        
        guard let latitude = foodTruck.latitude, let longitude = foodTruck.longitude else { return }
        
        let annotation = FoodTruckAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        annotation.title = foodTruck.name // TO DO: Move to Annotation Subclass
        if let departure = foodTruck.departureTime {
            let departureString = dateFormatter.string(from: departure)
            annotation.subtitle = "Departing \(departureString)"
        }
        // until here
        annotation.foodTruck = foodTruck
   
        
        // TO DO: only make geofences visible to FoodTruck users
        self.mapView.addAnnotation(annotation)
        
    }
    
}
