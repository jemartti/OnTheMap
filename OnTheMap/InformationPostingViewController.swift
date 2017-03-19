//
//  InformationPostingViewController.swift
//  OnTheMap
//
//  Created by Jacob Marttinen on 3/18/17.
//  Copyright © 2017 Jacob Marttinen. All rights reserved.
//

import UIKit
import MapKit

// MARK: - InformationPostingViewController: UIViewController, MKMapViewDelegate

class InformationPostingViewController: UIViewController, MKMapViewDelegate {
    
    // MARK: Properties
    
    var keyboardOnScreen = false
    
    // MARK: Outlets
    
    @IBOutlet weak var cancelButton: UINavigationItem!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var answerTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var findButton: BorderedButton!
    @IBOutlet weak var submitButton: BorderedButton!
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    // MARK: Actions
    
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
