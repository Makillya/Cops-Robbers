//
//  ViewController.swift
//  CopsNRobbers
//
//  Created by Mikayla Jordan on 5/11/17.
//  Copyright © 2017 Mikayla Jordan. All rights reserved.
//

// Jordan test push!

import UIKit
import MapKit

class ViewController: UIViewController {

    @IBOutlet weak var map: MKMapView!
    
	override func viewDidLoad() {
		super.viewDidLoad()
        
        let centerLocation = CLLocationCoordinate2DMake(47.6098342, -122.1967169)
        let mapSpan = MKCoordinateSpanMake(0.01, 0.01)
        let mapRegion = MKCoordinateRegionMake(centerLocation, mapSpan)
        self.map.setRegion(mapRegion, animated: true)
        
        let myAnnotation: MKPointAnnotation = MKPointAnnotation()
        myAnnotation.coordinate = CLLocationCoordinate2DMake(47.6098342, -122.1967169)
        myAnnotation.title = "Current location"
        self.map.addAnnotation(myAnnotation)
        
        let myAnnotation2: MKPointAnnotation = MKPointAnnotation()
        myAnnotation2.coordinate = CLLocationCoordinate2DMake(47.6111106, -122.1980925)
        myAnnotation2.title = "Other location"
        self.map.addAnnotation(myAnnotation2)
		// Do any additional setup after loading the view, typically from a nib.
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}


}

