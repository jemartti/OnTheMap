//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Jacob Marttinen on 3/5/17.
//  Copyright © 2017 Jacob Marttinen. All rights reserved.
//

import UIKit
import MapKit

// MARK: - MapViewController: UIViewController, MKMapViewDelegate

class MapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up the Navigation bar
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: UIBarButtonSystemItem.add,
            target: self,
            action: #selector(ListViewController.create)
        )
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: UIBarButtonSystemItem.refresh,
            target: self,
            action: #selector(ListViewController.create)
        )
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: UIBarButtonSystemItem.refresh,
            target: self,
            action: #selector(ListViewController.create)
        )
        navigationItem.title = "On the Map"
        
        // Load the studentInformations
        ParseClient.sharedInstance().getStudentLocations2(100, skip: 0, order: "-updatedAt") { (error) in
            if let error = error {
                self.alertUserOfFailure(message: error.localizedDescription)
            } else {
                performUIUpdatesOnMain {
                    self.updateAnnotations()
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = false
        self.updateAnnotations()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backItem = UIBarButtonItem()
        backItem.title = "Back"
        navigationItem.backBarButtonItem = backItem
    }
    
    private func alertUserOfFailure( message: String) {
        performUIUpdatesOnMain {
            let alertController = UIAlertController(title: "Login Failed", message:
                message, preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    private func updateAnnotations() {
        var annotations = [MKPointAnnotation]()
        
        for studentInformation in ParseClient.sharedInstance().studentInformations {
            
            let lat = CLLocationDegrees(studentInformation.latitude!)
            let long = CLLocationDegrees(studentInformation.longitude!)
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            let first = studentInformation.firstName
            let last = studentInformation.lastName
            let mediaURL = studentInformation.mediaURL
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "\(first) \(last)"
            annotation.subtitle = mediaURL
            
            annotations.append(annotation)
        }
        
        self.mapView.addAnnotations(annotations)
    }
    
    // MARK: - MKMapViewDelegate
    
    // Here we create a view with a "right callout accessory view". You might choose to look into other
    // decoration alternatives. Notice the similarity between this method and the cellForRowAtIndexPath
    // method in TableViewDataSource.
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    
    // This delegate method is implemented to respond to taps. It opens the system browser
    // to the URL specified in the annotationViews subtitle property.
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.shared
            if let toOpen = view.annotation?.subtitle! {
                app.openURL(URL(string: toOpen)!)
            }
        }
    }
    //    func mapView(mapView: MKMapView, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
    //
    //        if control == annotationView.rightCalloutAccessoryView {
    //            let app = UIApplication.sharedApplication()
    //            app.openURL(NSURL(string: annotationView.annotation.subtitle))
    //        }
    //    }
    
    // MARK: - Sample Data
    
    // Some sample data. This is a dictionary that is more or less similar to the
    // JSON data that you will download from Parse.
    
//    func hardCodedLocationData() -> [[String : AnyObject]] {
//        return  [
//            [
//                "createdAt" : "2015-02-24T22:27:14.456Z" as AnyObject,
//                "firstName" : "Jessica" as AnyObject,
//                "lastName" : "Uelmen" as AnyObject,
//                "latitude" : 28.1461248 as AnyObject,
//                "longitude" : -82.75676799999999 as AnyObject,
//                "mapString" : "Tarpon Springs, FL" as AnyObject,
//                "mediaURL" : "www.linkedin.com/in/jessicauelmen/en" as AnyObject,
//                "objectId" : "kj18GEaWD8" as AnyObject,
//                "uniqueKey" : 872458750 as AnyObject,
//                "updatedAt" : "2015-03-09T22:07:09.593Z" as AnyObject
//            ]
//        ]
//    }
}
