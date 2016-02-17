//
//  FirstViewController.swift
//  My Locations
//
//  Created by Abel Osorio on 2/17/16.
//  Copyright © 2016 Abel Osorio. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData

class CurrentLocationViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var tagButton: UIButton!
    @IBOutlet weak var getButton: UIButton!
    
    let locationManager = CLLocationManager()
    
    var location : CLLocation?
    var updatingLocation = false
    var lastLocationError: NSError?
    
    let geocoder = CLGeocoder()
    var placemark: CLPlacemark?
    var performingReverseGeocoding = false
    var lastGeocodingError: NSError?
    
    var timer: NSTimer?
    
    var managedObjectContext: NSManagedObjectContext!
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateLabels()
        configureGetButton()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Actions
    
    @IBAction func getLocation (){
        
        let authStatus = CLLocationManager.authorizationStatus()
        
        if authStatus == .NotDetermined{
            
            locationManager.requestWhenInUseAuthorization()
            return
        }
        
        if authStatus == .Denied || authStatus == .Restricted {
            showLocationServicesDeniedAlert()
            return
        }
        
        if updatingLocation{
                stopLocationManager()
            }else{
                location = nil
                lastLocationError = nil
                placemark = nil
                lastGeocodingError = nil
                startLocationManager()
                updateLabels()
                
        }
        configureGetButton()
    }
    
    // MARK: - UI METHODS
    
    
    func updateLabels(){
        
        if let location = location{
        
        latitudeLabel.text = String(format: "%.8f", location.coordinate.latitude)
        longitudeLabel.text = String(format: "%.8f", location.coordinate.longitude)
        messageLabel.text = ""
        tagButton.hidden = false
        
        if let placemark = placemark{
            addressLabel.text = stringFromPlacemark(placemark)
            addressLabel.lineBreakMode = .ByWordWrapping // or NSLineBreakMode.ByWordWrapping
            addressLabel.numberOfLines = 0
        } else if performingReverseGeocoding {
            addressLabel.text = "Searching for Address..."
        } else if lastGeocodingError != nil {
            addressLabel.text = "Error Finding Address"
        } else {
            addressLabel.text = "No Address Found"
        }
    }else{
        
        latitudeLabel.text = ""
        longitudeLabel.text = ""
        addressLabel.text = ""
        tagButton.hidden = true
        messageLabel.text = "Tap 'Get My Location' to Start"
        
        // The new code starts here:
        let statusMessage: String
        if let error = lastLocationError {
            if error.domain == kCLErrorDomain && error.code == CLError.Denied.rawValue {
            statusMessage = "Location Services Disabled"
        } else {
            statusMessage = "Error Getting Location" }
        } else if !CLLocationManager.locationServicesEnabled() {
            statusMessage = "Location Services Disabled"
        } else if updatingLocation {
            statusMessage = "Searching..."
        } else {
            statusMessage = "Tap 'Get My Location' to Start"
        }
        messageLabel.text = statusMessage
        }
        
    }
    
    func stringFromPlacemark(placemark: CLPlacemark) -> String{
            
            var line1 = ""
            if let s = placemark.subThoroughfare {
            line1 += s + " "
            }
            if let s = placemark.thoroughfare {
            line1 += s
            }
            var line2 = ""
            if let s = placemark.locality {
            line2 += s + " "
            }
            if let s = placemark.administrativeArea {
            line2 += s + " "
            }
            if let s = placemark.postalCode {
            line2 += s
            }
            return line1 + "\n" + line2
    }
    
    func showLocationServicesDeniedAlert(){
                
                let alert = UIAlertController(title: "Location Service Disabled", message: "Please enable location services for this app in Settings", preferredStyle: .Alert)
                let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                alert.addAction(okAction)
                presentViewController(alert, animated: true, completion: nil)
    }
    
    func configureGetButton(){
            let title = !updatingLocation ? "Get My Location" : "Stop"
            getButton.setTitle(title, forState: .Normal)
    }
    
    // MARK: - CLLocationManagerDelegate
    
    
    func startLocationManager(){
        if CLLocationManager.locationServicesEnabled(){
                locationManager.delegate = self
                locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                locationManager.startUpdatingLocation()
                updatingLocation = true
                
                timer = NSTimer.scheduledTimerWithTimeInterval(60, target: self, selector: Selector("didTimeOut"), userInfo: nil, repeats: false)
                
        }
    }
    
    func didTimeOut() {
        print("*** Time out")
        if location == nil {
            stopLocationManager()
            lastLocationError = NSError(domain: "MyLocationsErrorDomain", code: 1, userInfo: nil)
            updateLabels()
            configureGetButton() }
    }
    
    func stopLocationManager(){
                if updatingLocation{
                if let timer = timer{
                    timer.invalidate()
                }
                locationManager.stopUpdatingLocation()
                locationManager.delegate = nil
                updatingLocation = false
                }
                
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
                print("didFailWithError \(error) ")
                
                if error.code == CLError.LocationUnknown.rawValue{
        return
        
                }
                
                lastLocationError = error
                stopLocationManager()
                updateLabels()
                configureGetButton()
    }
    
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let newLocation = locations.last!
        
        if newLocation.timestamp.timeIntervalSinceNow < -5 {
        return
        }
        if newLocation.horizontalAccuracy < 0 {
                    return
        }
        
        var distance = CLLocationDistance(DBL_MAX)
        if let location = location{
        distance = newLocation.distanceFromLocation(location)
        }
        
        if distance > 0 {
                    performingReverseGeocoding = false
        }
        
        if location == nil || location?.horizontalAccuracy > newLocation.horizontalAccuracy{
                    location = newLocation
                    lastLocationError = nil
                    updateLabels()
        }
        if newLocation.horizontalAccuracy <= locationManager.desiredAccuracy{
                    stopLocationManager()
                    configureGetButton()
        }
        
        if !performingReverseGeocoding{
            performingReverseGeocoding = true
            
            geocoder.reverseGeocodeLocation(newLocation, completionHandler: {placemarks, error in
                    
                    
                    self.lastGeocodingError = error
                    if error == nil, let p = placemarks where !p.isEmpty {
                    self.placemark = p.last!
                } else {
                    self.placemark = nil
                    }
                    self.performingReverseGeocoding = false
                    self.updateLabels()
                    
                    })
        }else if distance < 1.0 {
            
            let timeInterval = newLocation.timestamp.timeIntervalSinceDate(location!.timestamp)
            if timeInterval > 10 {
                print("Force Done")
                stopLocationManager()
                updateLabels()
                configureGetButton()
            }
        
        }
    }
    
    // MARK: - Segues 
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
            
            if segue.identifier == "TagLocation"{
            
                let navigationController = segue.destinationViewController as! UINavigationController
                let controller = navigationController.topViewController as! LocationDetailsViewController
                controller.coordinate = location!.coordinate
                controller.placemark = placemark
                controller.managedObjectContext = managedObjectContext
                
            }
    }
}

