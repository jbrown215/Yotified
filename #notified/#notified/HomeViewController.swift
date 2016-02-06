//
//  ViewController.swift
//  #notified
//
//  Created by Jordan Brown on 2/5/16.
//  Copyright © 2016 woosufjordaline. All rights reserved.
//

import UIKit
import CoreLocation

class HomeViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var button : UIButton?
    let locationManager : CLLocationManager = CLLocationManager()
    var currentLoc : CLLocationCoordinate2D = CLLocationCoordinate2DMake(-100000, -100000);
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if CLLocationManager.authorizationStatus() == .NotDetermined {
            locationManager.requestWhenInUseAuthorization()
            
        }
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
    @IBAction func checkIn() {
        print("Checking In");
        if (CLLocationCoordinate2DIsValid(currentLoc)) {
            Server.checkIn(currentLoc.latitude as Double, long: currentLoc.longitude as Double, userId: 6102466685)
            print("valid loc")
        }
        locationManager.stopUpdatingLocation()
    }

    @IBAction func makeReport() {
        print("Making Report!")
    }
    
    @IBAction func unwindToHome(segue:UIStoryboardSegue) {
        Server.checkOut(6102466685)
        locationManager.startUpdatingLocation()
        print ("Unwindeded")
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        currentLoc = locValue
    }
    
}

