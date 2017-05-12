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
import Foundation

class ViewController: UIViewController {
    var foxId: String = String()
	@IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var hiderButtonText: UIButton!
	
	var seconds = 60
	var timer = Timer()
	var isTimerRunning = false
	
    var locationManager: CLLocationManager?
    var userLocation: Array<Double> = [47.6098342,-122.1967169]
    var userAnnotation: MKPointAnnotation = MKPointAnnotation()
    var userUUID: String = ""
    var users = [String: Any]()
    
	@IBAction func whereAreTheyButtonPressed(_ sender: UIButton) {
		if isTimerRunning == false {
			resetTimer()
			runTimer()
		} else {
			resetTimer()
			runTimer()
		}
	}
	
	@IBAction func hiderButtonPressed(_ sender: UIButton) {
        let hider: [String: String] = ["key": userUUID]
        Alamofire.request("http://52.36.124.53/hiderFlag", method: .post, parameters: hider, encoding: URLEncoding.default).responseJSON {response in
            let JSON = response.result.value!
            if let data = JSON as? [String: Bool] {
                if (data["key"] ?? nil) == false {
                    self.hiderButtonText.setTitle("You're not foxy!", for: .normal)
                }
                else {
                    self.hiderButtonText.setTitle("You are the fox!", for: .normal)
                }
                self.hiderButtonText.isEnabled = false
            }
        }
	}

	@IBAction func resetButtonPressed(_ sender: UIButton) {
        Alamofire.request("http://52.36.124.53/reset").responseJSON { response in
            print(response.result.value!)
            self.hiderButtonText.setTitle("Fox", for: .normal)
            self.hiderButtonText.isEnabled = true
        }
	}
	
	@IBAction func iWasFoundButtonPressed(_ sender: UIButton) {
		
	}
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
        updateMap()
        
        //Get UUID of device
        if let uuid = UIDevice.current.identifierForVendor?.uuidString {
            userUUID = uuid
        }
        
        //Initialize location manager
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        locationManager?.requestWhenInUseAuthorization()
        
        //Retrieve all other user Locations
        retrieveUsersLocationFromServer()
	}
	func runTimer() {
		isTimerRunning = true
		timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(ViewController.updateTimer)), userInfo: nil, repeats: true)
	}
	
	func updateTimer() {
		if seconds < 1 {
			timer.invalidate()
			timerLabel.text = "60"
		} else {
			seconds -= 1     //This will decrement(count down)the seconds.
			timerLabel.text = timeString(time: TimeInterval(seconds)) //This will update the label.
		}
	}
	
	func resetTimer() {
		timer.invalidate()
		seconds = 60
		timerLabel.text = timeString(time: TimeInterval(seconds))
		isTimerRunning = false
	}
	
	func timeString(time:TimeInterval) -> String {
		let seconds = Int(time)
		return String(format:"%02i", seconds)
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
	
    //Function which updates user's pin on the map
    func updateUserLocation() {
        userAnnotation.coordinate = CLLocationCoordinate2DMake(userLocation[0], userLocation[1])
        userAnnotation.title = "My Location"
        self.map.addAnnotation(userAnnotation)
    }
	
    //Function which updates the center location of the map based on the user's current location
    func updateMap() {
        //let centerLocation = CLLocationCoordinate2DMake(userLocation[0], userLocation[1])
        //let mapSpan = MKCoordinateSpanMake(1, 1)
        //let mapRegion = MKCoordinateRegionMake(centerLocation, mapSpan)
        //self.map.setRegion(mapRegion, animated: true)
    }
	
    //Function which sends the user's current location to the server
    func sendUserLocationDataToServer() {
            let coordinates : Parameters = ["key" : [userUUID, userLocation[0], userLocation[1]]]
		
            Alamofire.request("http://52.36.124.53/sendData", method: .post, parameters: coordinates, encoding: URLEncoding.default).responseJSON {response in let _ = response.result.isSuccess}
		
    }
	
    //Function which retrieves all user locations from the server
    func retrieveUsersLocationFromServer() {
        Alamofire.request("http://52.36.124.53/getData").responseJSON { response in
            if let JSON = response.result.value {
                if let data = JSON as? [String: Any] {
                    for (key, value) in data {
                        let arr1 = value as! Array<Any>
                        self.users[key] = arr1
                    }
                }
                self.displayOtherUsersOnMap()
            }
        }
    }
	
    //Function which displays all users locations on the map (other than the device location of the current user)
    func displayOtherUsersOnMap() {
        for (key, value) in users {
            if key != userUUID {
                var locationCoordinates: Array<Double> = []
                for coordinate in value as! Array<String> {
                    locationCoordinates.append(Double(coordinate)!)
                }
				
                let otherUserAnnotation: MKPointAnnotation = MKPointAnnotation()
                otherUserAnnotation.coordinate = CLLocationCoordinate2DMake(CLLocationDegrees(locationCoordinates[0]), CLLocationDegrees(locationCoordinates[1]))
                otherUserAnnotation.title = key
                self.map.addAnnotation(otherUserAnnotation)
            }
        }
    }
	
}


extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let currentLocation = locations.first?.coordinate {
            userLocation[0] = currentLocation.latitude
            userLocation[1] = currentLocation.longitude
            updateUserLocation()
            updateMap()
            sendUserLocationDataToServer()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager?.startUpdatingLocation()
            locationManager?.allowsBackgroundLocationUpdates = true
        }
    }
}
