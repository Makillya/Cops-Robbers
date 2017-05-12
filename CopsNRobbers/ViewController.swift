//
//  ViewController.swift
//  CopsNRobbers
//
//  Created by Mikayla Jordan on 5/11/17.
//  Copyright © 2017 Mikayla Jordan. All rights reserved.
//  messing with development team!


import UIKit
import MapKit
import CoreLocation
import Alamofire

class ViewController: UIViewController {

    @IBOutlet weak var map: MKMapView!
    
    var locationManager: CLLocationManager?
    var userLocation: Array<Double> = [47.6098342,-122.1967169]
    var userAnnotation: MKPointAnnotation = MKPointAnnotation()
    var users: Array<Any> = []
    
	override func viewDidLoad() {
		super.viewDidLoad()
        
        updateMap()
//        let myAnnotation: MKPointAnnotation = MKPointAnnotation()
//        myAnnotation.coordinate = CLLocationCoordinate2DMake(47.6098342, -122.1967169)
//        myAnnotation.title = "Current location"
//        self.map.addAnnotation(myAnnotation)
//        
//        let myAnnotation2: MKPointAnnotation = MKPointAnnotation()
//        myAnnotation2.coordinate = CLLocationCoordinate2DMake(47.6111106, -122.1980925)
//        myAnnotation2.title = "Other location"
//        self.map.addAnnotation(myAnnotation2)
        
        
		// Do any additional setup after loading the view, typically from a nib.
        
        //Initialize Location Manager
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        
        locationManager?.requestWhenInUseAuthorization()
        

	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
    
    func updateUserLocation() {
        userAnnotation.coordinate = CLLocationCoordinate2DMake(userLocation[0], userLocation[1])
        userAnnotation.title = "User Location"
        self.map.addAnnotation(userAnnotation)
    }
    
    func updateMap() {
        let centerLocation = CLLocationCoordinate2DMake(userLocation[0], userLocation[1])
        let mapSpan = MKCoordinateSpanMake(0.001, 0.001)
        let mapRegion = MKCoordinateRegionMake(centerLocation, mapSpan)
        self.map.setRegion(mapRegion, animated: true)
    }
}


extension ViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let currentLocation = locations.first?.coordinate {
            userLocation[0] = currentLocation.latitude
            userLocation[1] = currentLocation.longitude
            updateUserLocation()
            updateMap()
            let uuid = UIDevice.current.identifierForVendor?.uuidString
            let coordinates : Parameters = ["key" : [uuid!, userLocation[0], userLocation[1]]]
            
            Alamofire.request("http://52.36.124.53/sendData", method: .post, parameters: coordinates, encoding: URLEncoding.default).responseJSON {response in print()}
            
            
            Alamofire.request("http://52.36.124.53/getData").responseJSON { response in
                if let JSON = response.result.value {
                    print(JSON)
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager?.startUpdatingLocation()
            locationManager?.allowsBackgroundLocationUpdates = true
        }
    }
    
}
