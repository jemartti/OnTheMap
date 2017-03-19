//
//  InformationPostingViewController.swift
//  OnTheMap
//
//  Created by Jacob Marttinen on 3/18/17.
//  Copyright © 2017 Jacob Marttinen. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

// MARK: - InformationPostingViewController: UIViewController, MKMapViewDelegate

class InformationPostingViewController: UIViewController, MKMapViewDelegate {
    
    // MARK: Properties
    
    var keyboardOnScreen = false
    var location: CLLocationCoordinate2D!
    var mapString: String!
    
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
        
        initializeUI()
        subscribeToNotification(.UIKeyboardWillShow, selector: #selector(keyboardWillShow))
        subscribeToNotification(.UIKeyboardWillHide, selector: #selector(keyboardWillHide))
        subscribeToNotification(.UIKeyboardDidShow, selector: #selector(keyboardDidShow))
        subscribeToNotification(.UIKeyboardDidHide, selector: #selector(keyboardDidHide))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setUIForFind()
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        unsubscribeFromAllNotifications()
    }
    
    // MARK: UI Actions
    
    @IBAction func cancel(_ sender: Any) {
        returnToRoot()
    }
    
    @IBAction func find(_ sender: Any) {
        if answerTextField.text == "" {
            return	
        }
        
        let indicator: UIActivityIndicatorView = createIndicator()
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        indicator.startAnimating()
        
        CLGeocoder().geocodeAddressString(answerTextField.text!, completionHandler: {(placemarks, error) -> Void in
            if let error = error {
                //self.alertUserOfFailure(message: error.localizedDescription)
                print (error)
                return
            }
            if let placemark = placemarks?.first {
                performUIUpdatesOnMain {
                    print (placemark)
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    indicator.stopAnimating()
                    
                    self.mapString = self.answerTextField.text!
                    self.location = placemark.location!.coordinate
                    
                    let region = MKCoordinateRegionMakeWithDistance(placemark.location!.coordinate, 10000.0, 10000.0)
                    self.mapView.setRegion(region, animated: true)
                    self.mapView.addAnnotation(MKPlacemark(placemark: placemark))
                    
                    self.setUIForConfirm()
                }
            }
        })
    }
    
    @IBAction func submit(_ sender: Any) {
        ParseClient.sharedInstance().postStudentLocation(mapString!, mediaURL: answerTextField.text!, coordinates: location!) { (error) in
            if error != nil {
                self.alertUserOfFailure(message: "Post failed. Try again.")
            } else {
                performUIUpdatesOnMain {
                    self.returnToRoot()
                }
            }
        }
    }
    
    // MARK: Transitions
    
    func returnToRoot() {
        dismiss(animated: true, completion: nil)
    }
}


// MARK: - LoginViewController: UITextFieldDelegate

extension InformationPostingViewController: UITextFieldDelegate {
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: Show/Hide Keyboard
    
    func keyboardWillShow(_ notification: Notification) {
        if !keyboardOnScreen {
            view.frame.origin.y -= keyboardHeight(notification)
        }
    }
    
    func keyboardWillHide(_ notification: Notification) {
        if keyboardOnScreen {
            view.frame.origin.y += keyboardHeight(notification)
        }
    }
    
    func keyboardDidShow(_ notification: Notification) {
        keyboardOnScreen = true
    }
    
    func keyboardDidHide(_ notification: Notification) {
        keyboardOnScreen = false
    }
    
    private func keyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = (notification as NSNotification).userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    private func resignIfFirstResponder(_ textField: UITextField) {
        if textField.isFirstResponder {
            textField.resignFirstResponder()
        }
    }
    
    @IBAction func userTappedView(_ sender: AnyObject) {
        resignIfFirstResponder(answerTextField)
    }
}

// MARK: - InformationPostingViewController (Configure UI)

private extension InformationPostingViewController {
    
    func initializeUI() {
        configureTextField(answerTextField)
    }
    
    func createIndicator() -> UIActivityIndicatorView {
        let indicator = UIActivityIndicatorView(
            activityIndicatorStyle: UIActivityIndicatorViewStyle.gray
        )
        indicator.frame = CGRect(x: 0.0, y: 0.0, width: 40.0, height: 40.0);
        indicator.center = view.center
        view.addSubview(indicator)
        indicator.bringSubview(toFront: view)
        return indicator
    }
    
    func setUIForFind() {
        questionLabel.text = "Where are you studying today?"
        
        answerTextField.text = ""
        answerTextField.placeholder = "Toronto, ON"
        
        findButton.isEnabled = true
        findButton.alpha = 1.0
        
        submitButton.isEnabled = false
        submitButton.alpha = 0.5
    }
    
    func setUIForConfirm() {
        questionLabel.text = "Specify a related link."
        
        answerTextField.text = ""
        answerTextField.placeholder = "http://udacity.com"
        
        findButton.isEnabled = false
        findButton.alpha = 0.5
        
        submitButton.isEnabled = true
        submitButton.alpha = 1.0
    }
    
    func configureTextField(_ textField: UITextField) {
        let textFieldPaddingViewFrame = CGRect(x: 0.0, y: 0.0, width: 13.0, height: 0.0)
        let textFieldPaddingView = UIView(frame: textFieldPaddingViewFrame)
        textField.text = ""
        textField.leftView = textFieldPaddingView
        textField.leftViewMode = .always
        textField.textColor = Constants.UI.OrangeColor
        textField.attributedPlaceholder = NSAttributedString(string: textField.placeholder!, attributes: [NSForegroundColorAttributeName: Constants.UI.OrangeColor])
        textField.delegate = self
    }
    
    func alertUserOfFailure(message: String) {
        
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
            
            self.returnToRoot()
            
            // Present the failure alert on the root
            UIApplication.shared.keyWindow?.rootViewController?.presentedViewController?.present(
                alertController,
                animated: true,
                completion: nil
            )
        }
    }
}

// MARK: - InformationPostingViewController (Notifications)

private extension InformationPostingViewController {
    
    func subscribeToNotification(_ notification: NSNotification.Name, selector: Selector) {
        NotificationCenter.default.addObserver(self, selector: selector, name: notification, object: nil)
    }
    
    func unsubscribeFromAllNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
}
