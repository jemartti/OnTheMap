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
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Logout",
            style: UIBarButtonItemStyle.plain,
            target: self,
            action: #selector(MapViewController.logout)
        )
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(
                barButtonSystemItem: UIBarButtonSystemItem.refresh,
                target: self,
                action: #selector(MapViewController.updateStudentInformation)
            ),
            UIBarButtonItem(
                image: UIImage(named: "icon_pin"),
                style: UIBarButtonItemStyle.plain,
                target: self,
                action: #selector(MapViewController.create)
            )
        ]
        navigationItem.title = "On the Map"
        
        updateStudentInformation()
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
            let alertController = UIAlertController(
                title: "Action Failed",
                message: message,
                preferredStyle: UIAlertControllerStyle.alert
            )
            alertController.addAction(UIAlertAction(
                title: "Dismiss",
                style: UIAlertActionStyle.default,
                handler: nil
            ))
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    // MARK: - MKMapViewDelegate
    
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

    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            if let mediaURL = view.annotation?.subtitle!,
                let toOpen = URL(string: mediaURL) {
                UIApplication.shared.open(
                    toOpen,
                    options: [:],
                    completionHandler: nil
                )
            }
        }
    }
    
    // MARK: Supplementary Functions
    
    func updateStudentInformation() {
        // Load the studentInformations
        ParseClient.sharedInstance().getStudentLocations(100, skip: 0, order: "-updatedAt") { (error) in
            if let error = error {
                self.alertUserOfFailure(message: error.localizedDescription)
            } else {
                performUIUpdatesOnMain {
                    self.updateAnnotations()
                }
            }
        }
    }
    
    // Update the pins on the map
    private func updateAnnotations() {
        var annotations = [MKPointAnnotation]()
        
        for studentInformation in ParseClient.sharedInstance().studentInformations {
            let annotation = MKPointAnnotation()
            
            if let firstName = studentInformation.firstName {
                annotation.title = firstName + " "
            }
            if let lastName = studentInformation.lastName {
                annotation.title = (annotation.title)! + lastName
            }
            
            let lat = CLLocationDegrees(studentInformation.latitude!)
            let long = CLLocationDegrees(studentInformation.longitude!)
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            annotation.coordinate = coordinate
            
            if let mediaURL = studentInformation.mediaURL {
                annotation.subtitle = mediaURL
            }
            
            annotations.append(annotation)
        }
        
        self.mapView.removeAnnotations(self.mapView.annotations)
        self.mapView.addAnnotations(annotations)
    }
    
    // Displays the Create View
    func create() {
        let informationPostingVC = storyboard!.instantiateViewController(
            withIdentifier: "InformationPostingViewController"
        )
        present(informationPostingVC, animated: true, completion: nil)
    }
    
    func logout() {
        UdacityClient.sharedInstance().deleteSession() { (error) in
            if let error = error {
                self.alertUserOfFailure(message: error.localizedDescription)
            } else {
                if let error = error {
                    self.alertUserOfFailure(message: error.localizedDescription)
                } else {
                    self.returnToRoot()
                }
            }
        }
    }
    
    func returnToRoot() {
        dismiss(animated: true, completion: nil)
    }
}
