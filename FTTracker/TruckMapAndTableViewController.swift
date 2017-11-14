//
//  TruckMapAndTableViewController.swift
//  FTTracker
//
//  Created by Dylan Bruschi on 10/18/17.
//  Copyright © 2017 Dylan Bruschi. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Firebase

class TruckMapAndTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate, MKMapViewDelegate, UISearchBarDelegate {
    
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var tableView: UITableView!
    
    var foodTrucks = [FoodTruck]()
    var filteredFoodTrucks = [FoodTruck]()
    var searchActive = false
    var geofences = [CLCircularRegion]()
    private var locationManager = CLLocationManager()
    private var currentLocation: CLLocation?
    
    
    //MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.showsUserLocation = true
        
        mapView.delegate = self
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
        }
        
        
//        queryFoodTrucks()
//
//        addSampleFoodTrucks()
        
        self.navigationController?.navigationBar.backItem?.backBarButtonItem?.isEnabled = false
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120
        
 
        
        // Share FoodTrucks with other tab bars using similar method. Move into separate func
        //        let barViewControllers = self.tabBarController?.viewControllers
        //        let svc = barViewControllers![1] as! ListViewController
        //        svc.foodTrucks = self.foodTrucks
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        filteredFoodTrucks.removeAll()
        searchBar.text = ""
        searchActive = false
        searchBar.resignFirstResponder()
    }
    
    // MARK: - UISearchBarDelegate Methods
    
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
    
    // MARK: - UITableViewDelegate Methods
    
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
    
    // MARK: - CLLocationManagerDelegate Methods
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let firstLocation = locations.first {
            currentLocation = firstLocation
        }
        
        if currentLocation == nil {
            
            if let userLocation = locations.first {
                let viewRegion = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 10000, 10000)
                mapView.setRegion(viewRegion, animated: true)
            }
        } else {
        print("current location: \(currentLocation)")
        locationManager.stopUpdatingLocation()
        queryFoodTrucks()
        addSampleFoodTrucks()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        print("did start monitoring for region")
        self.locationManager.requestState(for: region)
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("Entered region \(region.identifier)")
        let truckRef = FIRDatabase.database().reference().child("foodTrucks").child(region.identifier)
        truckRef.observe(.value, with: { snapshot in
            let foodTruckDict = snapshot.value as! [String:Any]
            let foodTruck = FoodTruck.init(dict: foodTruckDict)
            let couponRef = FIRDatabase.database().reference().child("coupons").child("\(foodTruck.uid)").child((UserDefaults.standard.value(forKey: "uid")! as! String))
            // TO DO: Change implementation to use new coupon data structure
            //            let couponDict = ["couponCode": "\(foodTruck.couponCode).\(UserDefaults.standard().valueForKey("uid")!).\(couponRef.key)", "couponDesc": (foodTruck.couponDesc) as String, "couponDiscount": (foodTruck.couponDiscount) as String, "active?": true, "couponExp": (foodTruck.couponExp) as String, "foodTruck": (foodTruck.name) as String, "userID": UserDefaults.standardUserDefaults().valueForKey("uid") as! String]
            //            couponRef.setValue(couponDict)
            self.presentLocalNotifications(foodTruck: foodTruck.name)
        })
        
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("Exited region\(region.identifier)")
    }
    
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        print("did determine state")
        //        let truckRef = DataService.dataService.REF_BASE.childByAppendingPath("foodTrucks").childByAppendingPath(region.identifier)
        //        truckRef.observeEventType(.Value, withBlock: { snapshot in
        //            let foodTruck = FoodTruck.init(snapshot: snapshot)
        //            let couponRef = DataService.dataService.REF_BASE.childByAppendingPath("coupons").childByAppendingPath("\(foodTruck.name)\(NSUserDefaults.standardUserDefaults().valueForKey("uid")!)")
        //            let couponDict = ["couponCode": "\(foodTruck.couponCode).\(NSUserDefaults.standardUserDefaults().valueForKey("uid")!).\(couponRef.key)", "couponDesc": (foodTruck.couponDesc) as String, "couponDiscount": (foodTruck.couponDiscount) as String, "active?": true, "couponExp": (foodTruck.couponExp) as String, "foodTruck": (foodTruck.name) as String, "userID": NSUserDefaults.standardUserDefaults().valueForKey("uid") as! String]
        //            couponRef.setValue(couponDict)
        //            if state.rawValue.description == "1" {
        //
        //                print("inside \(region.identifier) geofence")
        //                self.presentLocalNotifications(foodTruck.name)
        //            }
        //        })
        
    }
    
    // MARK: - MKMapViewDelegate Methods
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        zoomCenter()
        self.locationManager.stopUpdatingLocation()
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation.isEqual(mapView.userLocation) {
            return nil
        }
        else {
            let pin = MKAnnotationView(annotation: annotation, reuseIdentifier: nil)
            pin.image = UIImage(named: "foodTruckImage")
            pin.canShowCallout = true
            pin.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            return pin
        }
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        print("callout accessory tapped")
        let truckAnnotation = view.annotation as! FoodTruckAnnotation
        // TO DO: Implement segue to selected food truck
        //        foodTruckOfAnnotation = truckAnnotation.foodTruck!
        //        self.performSegueWithIdentifier("MapToProfileSegue", sender: nil)
        
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKCircle {
            let circleRenderer = MKCircleRenderer(overlay: overlay)
            circleRenderer.lineWidth = 1.0
            circleRenderer.strokeColor = UIColor.purple
            circleRenderer.fillColor = UIColor.purple.withAlphaComponent(0.4)
            return circleRenderer
        } else {
            return MKPolylineRenderer()
        }
    }
    
    // MARK: - Notifications
    func registerLocalNotifications() {
        // TO DO: Look up new terminology in UserNotifications
        let notificationSettings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
        UIApplication.shared.registerUserNotificationSettings(notificationSettings)
    }
    
    func presentLocalNotifications(foodTruck: String) {
        guard let settings = UIApplication.shared.currentUserNotificationSettings else { return }
        
        if settings.types == [] {
            let ac = UIAlertController(title: "Notification Error",
                                       message: "Either we don't have permission to schedule notifications or we haven't asked yet",
                                       preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(ac, animated: true, completion: nil)
            return
        }
        
        let notification = UILocalNotification()
        notification.fireDate = NSDate(timeIntervalSinceNow: 10) as Date
        notification.alertBody = "\(foodTruck) has a coupon available!"
        notification.alertAction = "claim"
        notification.soundName = UILocalNotificationDefaultSoundName
        notification.userInfo = ["CustomField1": foodTruck]
        UIApplication.shared.scheduleLocalNotification(notification)
        
    }
    
    
    // MARK: - Methods
    
    func queryFoodTrucks() {
        let ref = FIRDatabase.database().reference()
        let foodTruckRef = ref.child("FoodTrucks")
        
        foodTruckRef.observe(.value, with: { snapshot in
            print(snapshot.childrenCount)
            let enumerator = snapshot.children
            while let rest = enumerator.nextObject() as? FIRDataSnapshot {
                let foodTruckDict = rest.value as! [String:Any]
                let foodTruck = FoodTruck.init(dict: foodTruckDict)
                print("created food truck: \(foodTruck.uid)")
                if let latitude = foodTruck.latitude, let longitude = foodTruck.longitude {
                    if self.currentLocation != nil {
                    foodTruck.distance = self.currentLocation!.distance(from: CLLocation(latitude: latitude , longitude: longitude)) * 0.000621371
                    } else {
                        foodTruck.distance = 0
                    }
                    DispatchQueue.main.async() {
                        self.dropPinForFoodTruck(foodTruck: foodTruck)
                        print("Added annotation")
                    }
                    
                }
                self.foodTrucks.append(foodTruck)
                self.tableView.reloadData()
            }
            // sort here instead?
        })
        self.foodTrucks.sort(by: { $0.distance < $1.distance })
        tableView.reloadData()
    }
    
    func zoomCenter() {
        let userLocation = mapView.userLocation
        let region = MKCoordinateRegionMakeWithDistance(userLocation.location!.coordinate, 10000, 10000)
        mapView.setRegion(region, animated: true)
    }
    
    func startMonitoringForRegions() {
        for geofence in self.geofences {
            self.locationManager.startMonitoring(for: geofence)
        }
    }
    
    func dropPinForFoodTruck(foodTruck: FoodTruck) {
        //        let geoCoder = CLGeocoder()
        //        geoCoder.geocodeAddressString(foodTruck.address) { (placemarks : [CLPlacemark]?, error : NSError?) in
        //            for placemark in placemarks! {
        let annotation = FoodTruckAnnotation()
        let radius = CLLocationDistance(200.0)
        annotation.coordinate = CLLocationCoordinate2D(latitude: foodTruck.latitude!, longitude: foodTruck.longitude!)
        annotation.title = foodTruck.name
        if let departure = foodTruck.departureTime {
            annotation.subtitle = "Departing \(departure)"
        }
        annotation.foodTruck = foodTruck
        let geoRegion = CLCircularRegion(center: annotation.coordinate, radius: radius, identifier: foodTruck.uid)
        self.geofences.append(geoRegion)
        self.locationManager.startMonitoring(for: geoRegion)
        let overlay = MKCircle.init(center: annotation.coordinate, radius: radius)
        self.mapView.add(overlay)
        self.mapView.addAnnotation(annotation)
        
    }
    
//        func reverseGeocode(location: CLLocation){
//            let geocoder = CLGeocoder()
//            geocoder.reverseGeocodeLocation(location) { (placemarks: [CLPlacemark]?, error: NSError?) in
//                if error != nil {
//                    print(error?.localizedDescription)
//                }
//                self.locationManager.stopUpdatingLocation()
//                } as! CLGeocodeCompletionHandler
//        }
    
    func addSampleFoodTrucks() {
        let foodTruckOneDict = ["name" : "Dan's" , "email" : "dan", "password" : "danley", "uid" : "123", "rating" : 0.0 , "description" : "We suck", "category" : "donuts", "twitter" : "dan", "latitude" : 41.9, "longitude" : -87.64, "departureTime" : 0.0, "joinedDate" : 0.0, "address" : "123 High Street"] as [String : Any]
        let foodTruckOne = FoodTruck.init(dict: foodTruckOneDict)
        if let latitude = foodTruckOne.latitude, let longitude = foodTruckOne.longitude {
            if currentLocation != nil {
            foodTruckOne.distance = self.currentLocation!.distance(from: CLLocation(latitude: latitude , longitude: longitude)) * 0.000621371
            } else {
                foodTruckOne.distance = 0
            }
        }
        
        let foodTruckTwoDict = ["name" : "Mike's" , "email" : "Mike", "password" : "mikeley", "uid" : "124", "rating" : 5.0 , "description" : "We rock", "category" : "scones", "twitter" : "mike", "latitude" : 41.88, "longitude" : -87.62, "departureTime" : 0.0, "joinedDate" : 0.0, "address" : "124 High Street"] as [String : Any]
        let foodTruckTwo = FoodTruck.init(dict: foodTruckTwoDict)
        if let latitude = foodTruckTwo.latitude, let longitude = foodTruckTwo.longitude {
            if currentLocation != nil {
            foodTruckTwo.distance = self.currentLocation!.distance(from: CLLocation(latitude: latitude , longitude: longitude)) * 0.000621371
            } else {
                foodTruckTwo.distance = 0
            }
        }
        
        foodTrucks.append(foodTruckOne)
        foodTrucks.append(foodTruckTwo)
        
        dropPinForFoodTruck(foodTruck: foodTruckOne)
        dropPinForFoodTruck(foodTruck: foodTruckTwo)
        tableView.reloadData()
    }
    
    func getAddressFromGeocodeCoordinate(location: CLLocation, cell: FoodTruckTableViewCell) {
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
                    print(pm.country)
                    print(pm.locality)
                    print(pm.subLocality)
                    print(pm.thoroughfare)
                    print(pm.postalCode)
                    print(pm.subThoroughfare)
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
                    
                    
                     cell.addressLabel.text = addressString
                }
        })
    }
    
    func conversion(post: String) -> UIImage {
        if post == "" {
            return UIImage(named: "QuestionMarkImage")!
        } else {
            if let imageData = NSData(base64Encoded: post, options: [] ) {
            let image = UIImage(data: imageData as Data)
            return image!
            }
            return UIImage()
        }
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
