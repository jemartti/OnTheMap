//
//  ListViewController.swift
//  OnTheMap
//
//  Created by Jacob Marttinen on 3/5/17.
//  Copyright © 2017 Jacob Marttinen. All rights reserved.
//

import UIKit

// MARK: - ListViewController: UITableViewController

class ListViewController: UITableViewController {
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Set up the Navigation bar
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Logout",
            style: UIBarButtonItemStyle.plain,
            target: self,
            action: #selector(ListViewController.logout)
        )
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(
                barButtonSystemItem: UIBarButtonSystemItem.refresh,
                target: self,
                action: #selector(ListViewController.updateStudentInformation)
            ),
            UIBarButtonItem(
                image: UIImage(named: "icon_pin"),
                style: UIBarButtonItemStyle.plain,
                target: self,
                action: #selector(ListViewController.create)
            )
        ]
        navigationItem.title = "On the Map"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = false
        
        self.updateStudentInformation()
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
    
    // MARK: Table View Data Source
    
    override func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return ParseClient.sharedInstance().studentInformations.count
    }
    
    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "StudentInformationTableViewCell"
        )!
        let studentInformation = ParseClient.sharedInstance().studentInformations[(indexPath as NSIndexPath).row]
        
        // Set the name
        cell.textLabel?.text = ""
        if let firstName = studentInformation.firstName {
            cell.textLabel?.text = firstName + " "
        }
        if let lastName = studentInformation.lastName {
            cell.textLabel?.text = (cell.textLabel?.text)! + lastName
        }
        
        // Set the image
        cell.imageView?.image = UIImage(named: "icon_pin")
        
        return cell
    }
    
    override func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        // Set the link action
        let studentInformation = ParseClient.sharedInstance().studentInformations[(indexPath as NSIndexPath).row]
        if let mediaURL = studentInformation.mediaURL,
            let toOpen = URL(string: mediaURL) {
            UIApplication.shared.open(
                toOpen,
                options: [:],
                completionHandler: nil
            )
        }
    }
    
    // MARK: Supplementary Functions
    
    func updateStudentInformation() {
        // Load the studentInformations and reload the table
        ParseClient.sharedInstance().getStudentLocations(100, skip: 0, order: "-updatedAt") { (error) in
            if error != nil {
                self.alertUserOfFailure(message: "Data download failed.")
            } else {
                performUIUpdatesOnMain {
                    self.tableView.reloadData()
                }
            }
        }
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
