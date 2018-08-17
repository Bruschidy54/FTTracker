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

class TruckController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var tableView: UITableView!

    @IBOutlet var tableHeight: NSLayoutConstraint!
    
    var foodTrucks = [FoodTruck]()
    var filteredFoodTrucks = [FoodTruck]()
     var searchActive = false
    var geofences = [CLCircularRegion]()
    private var locationManager = CLLocationManager()
    private var currentLocation: CLLocation?
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
    
    
    //MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.showsUserLocation = true
        
        mapView.delegate = self
        
        
        setupTapGestureRecognizers()
        setupLocationManager() 
        setupNavigationBar()
        
        
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120
        
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
        }
    }
    
    private func setupTapGestureRecognizers() {
        let tableTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTableTap))
        tableView.addGestureRecognizer(tableTapGestureRecognizer)
        
        let mapTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleMapTap))
        mapView.addGestureRecognizer(mapTapGestureRecognizer)
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
    
    private func setupNavigationBar() {
        navigationItem.hidesBackButton = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "gear").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleLogOut))
    }
    
    @objc func handleLogOut() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { (_) in
            do {
                
                try Auth.auth().signOut()
                let loginController = LoginViewController()
                let navController = UINavigationController(rootViewController: loginController)
                self.present(navController, animated: true, completion: nil)
            } catch let signOutErr {
                print("Failed to sign out:", signOutErr)
            }
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
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
        print("current location: \(currentLocation ?? CLLocation())")
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
//        let truckRef = FIRDatabase.database().reference().child("foodTrucks").child(region.identifier)
//        truckRef.observe(.value, with: { snapshot in
//            let foodTruckDict = snapshot.value as! [String:Any]
//            let foodTruck = FoodTruck.init(dict: foodTruckDict)
//            let couponRef = FIRDatabase.database().reference().child("coupons").child("\(foodTruck.uid)").child((UserDefaults.standard.value(forKey: "uid")! as! String))
            // TO DO: Change implementation to use new coupon data structure
            //            let couponDict = ["couponCode": "\(foodTruck.couponCode).\(UserDefaults.standard().valueForKey("uid")!).\(couponRef.key)", "couponDesc": (foodTruck.couponDesc) as String, "couponDiscount": (foodTruck.couponDiscount) as String, "active?": true, "couponExp": (foodTruck.couponExp) as String, "foodTruck": (foodTruck.name) as String, "userID": UserDefaults.standardUserDefaults().valueForKey("uid") as! String]
            //            couponRef.setValue(couponDict)
//            self.presentLocalNotifications(foodTruck: foodTruck.name)
//        })
        
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("Exited region\(region.identifier)")
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
            let viewTruckButton = UIButton(frame:CGRect(x: 0, y: 0, width: 45, height: 30))
            viewTruckButton.backgroundColor = UIColor(red: 74/255, green: 144/255, blue: 226/255, alpha: 1)
            viewTruckButton.layer.cornerRadius = 4
            viewTruckButton.setTitle("View", for: .normal)
            pin.rightCalloutAccessoryView = viewTruckButton
            return pin
        }
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        print("callout accessory tapped")
//        let truckAnnotation = view.annotation as! FoodTruckAnnotation
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
 
    // Look up how to do
    
    
    // MARK: - Methods
    
    func queryFoodTrucks() {
        
        
        let ref = Database.database().reference()
        let foodTruckRef = ref.child("FoodTrucks")
        
        foodTruckRef.observe(.value, with: { snapshot in
            print(snapshot.childrenCount)
            let enumerator = snapshot.children
            while let rest = enumerator.nextObject() as? DataSnapshot {
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
            let departureString = dateFormatter.string(from: departure)
            annotation.subtitle = "Departing \(departureString)"
        }
        annotation.foodTruck = foodTruck
        let geoRegion = CLCircularRegion(center: annotation.coordinate, radius: radius, identifier: foodTruck.uid)
        self.geofences.append(geoRegion)
        self.locationManager.startMonitoring(for: geoRegion)
        let overlay = MKCircle.init(center: annotation.coordinate, radius: radius)
        self.mapView.add(overlay)
        self.mapView.addAnnotation(annotation)
        
    }
    

    @objc func handleMapTap() {
        tableHeight.constant = 100
        
        UIView.animate(withDuration: 0.5, delay: 0.1, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    @objc func handleTableTap() {
        tableHeight.constant = 400
        
        UIView.animate(withDuration: 0.5, delay: 0.1, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
        
        
    }
    
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
        
        foodTrucks.forEach { (foodTruck) in
            dropPinForFoodTruck(foodTruck: foodTruck)
        }
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
