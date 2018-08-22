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
    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var tableView: UITableView!

    @IBOutlet var tableHeight: NSLayoutConstraint!
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
    
    
    let searchController = UISearchController(searchResultsController: nil)
    
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
        
        self.tabBarController?.title = "Find Trucks"
        
        setupGestureRecognizers()
        setupLocationManager() 
        setupNavigationBar()
        setupSearchBar()
        
        
        // To DO: reload tableview data on searchController cancel button tapped
        
        
        
        tableViewBottomConstraint.constant = -1 * view.frame.height
        tableHeight.constant = view.frame.height + 134
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        filteredFoodTrucks.removeAll()
        self.tabBarController?.navigationItem.searchController?.searchBar.text = ""
        searchActive = false
       self.tabBarController?.navigationItem.searchController?.searchBar.resignFirstResponder()
    }
    
    //MARK:- Setup Methods
    
    private func setupSearchBar() {
        
        if #available(iOS 11.0, *) {
            
            self.tabBarController?.navigationItem.searchController = searchController
        } else {
            // Fallback on earlier versions
            self.tabBarController?.navigationItem.titleView = searchController.searchBar
            self.tabBarController?.navigationItem.titleView?.layoutSubviews()
        }
        
        self.definesPresentationContext = true
        self.tabBarController?.navigationItem.hidesSearchBarWhenScrolling = false
        searchController.searchBar.placeholder = "Search for trucks..."
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = [NSAttributedStringKey.foregroundColor.rawValue: UIColor.white]
        searchController.searchBar.tintColor = .themeRed
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
    
    }
    
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
        }
    }
    
    private func setupGestureRecognizers() {
        let tableTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTableTap))
        tableTapGestureRecognizer.cancelsTouchesInView = false
        tableView.addGestureRecognizer(tableTapGestureRecognizer)
        
        let tablePanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleTablePan))
        tableView.addGestureRecognizer(tablePanGestureRecognizer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.navigationItem.hidesBackButton = true

        
        tableView.reloadData()
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
        
        FirebaseService.shared.queryFoodTrucks { (foodTrucks) in
            for foodTruck in foodTrucks {
                
            if let latitude = foodTruck.latitude, let longitude = foodTruck.longitude {
                if self.currentLocation != nil {
                    foodTruck.distance = self.currentLocation!.distance(from: CLLocation(latitude: latitude , longitude: longitude)) * 0.000621371
                } else {
                    foodTruck.distance = 0
                }
                }
                
                self.foodTrucks.append(foodTruck)
                
                DispatchQueue.main.async() {
                    self.dropPinForFoodTruck(foodTruck: foodTruck)
                    print("Added annotation")
                }
        }
            
            self.tableView.reloadData()
            
        }
    }
    
    func zoomCenter() {
        let userLocation = mapView.userLocation
        guard let locationCoordinate = userLocation.location?.coordinate else { return }
        let region = MKCoordinateRegionMakeWithDistance(locationCoordinate, 10000, 10000)
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
        
        guard let latitude = foodTruck.latitude, let longitude = foodTruck.longitude else { return }
        
        let annotation = FoodTruckAnnotation()
        let radius = CLLocationDistance(200.0)
        annotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        annotation.title = foodTruck.name // TO DO: Move to Annotation Subclass
        if let departure = foodTruck.departureTime {
            let departureString = dateFormatter.string(from: departure)
            annotation.subtitle = "Departing \(departureString)"
        }
        // until here
        annotation.foodTruck = foodTruck
        let geoRegion = CLCircularRegion(center: annotation.coordinate, radius: radius, identifier: foodTruck.uid)
        
        // TO DO: only make geofences visible to FoodTruck users
        self.geofences.append(geoRegion)
        self.locationManager.startMonitoring(for: geoRegion)
        let overlay = MKCircle.init(center: annotation.coordinate, radius: radius)
        self.mapView.add(overlay)
        self.mapView.addAnnotation(annotation)
        
    }
    
    
    fileprivate func handlePanChanged(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: tableView.superview)
        tableView.transform = CGAffineTransform(translationX: 0, y: translation.y)
        
        
    }
    
    fileprivate func handlePanEnded(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: tableView.superview)
        let velocity = gesture.velocity(in: tableView.superview)
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.tableView.transform = .identity
            
            if translation.y < -200 || velocity.y < -500 {
                self.maximizeTableView()
            } else {
                self.minimizeTableView()
            }
        })
    }

    @objc func handleTablePan(gesture: UIPanGestureRecognizer) {
        if gesture.state == .changed {
            handlePanChanged(gesture)
        } else if gesture.state == .ended {
            handlePanEnded(gesture)
        }
    }
    
    @objc func handleTableTap() {
        maximizeTableView()
    }
    
    func maximizeTableView() {
        tableHeight.constant = 2 * view.frame.height
        tableViewBottomConstraint.constant = -1 * view.frame.height
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    func minimizeTableView() {
        tableHeight.constant = view.frame.height + 134
        tableViewBottomConstraint.constant = -1 * view.frame.height
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    private func addSampleFoodTrucks() {
        
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TruckDetailSegue" {
            guard let cell = sender as? FoodTruckTableViewCell else { return }
            let destination = segue.destination as! TruckDetailController
            destination.foodTruck = cell.foodTruck
        }
    }
    
}
