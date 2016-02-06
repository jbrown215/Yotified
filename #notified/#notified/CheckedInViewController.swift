//
//  CheckedInViewController.swift
//  #notified
//
//  Created by Benjamin Lichtman on 2/5/16.
//  Copyright © 2016 woosufjordaline. All rights reserved.
//

import UIKit
import CoreLocation


class CheckedInViewController: UIViewController, CLLocationManagerDelegate {

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


        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func checkOut() {
        print("I'm Home!")
    }
    
    @IBAction func makeReport() {
        Server.report(currentLoc.latitude as Double, long: currentLoc.longitude as Double, userId: 6102466685, callback: {
            report in
            if let resultController = self.storyboard!.instantiateViewControllerWithIdentifier("REPORT_VIEW") as? ReportViewController {
                resultController.reportID = report
                self.showViewController(resultController, sender: self)
            }

            })
        print("Making Report!")
    }
    
    @IBAction func unwindToCheckin(segue:UIStoryboardSegue) {
        print ("Unwindeded")
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        currentLoc = locValue
    }


    
    // MARK: - Navigation

}
