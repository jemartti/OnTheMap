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
    
    // MARK: Properties
    
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up the Navigation bar
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: UIBarButtonSystemItem.add,
            target: self,
            action: #selector(ListViewController.create)
        )
        navigationItem.title = "On the Map"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = false
        
        // Load the studentInformations
        ParseClient.sharedInstance().getStudentLocations2(100, skip: 0, order: "-updatedAt") { (error) in
            if let error = error {
                self.alertUserOfFailure(message: error.localizedDescription)
            } else {
                performUIUpdatesOnMain {
                    self.tableView.reloadData()
                }
            }
        }
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
        
        // Set the name and image
        if let firstName = studentInformation.firstName, let lastName = studentInformation.lastName {
            cell.textLabel?.text = firstName + " " + lastName
        } else {
            cell.textLabel?.text = "FFDSUFSDF"
        }
        
        cell.imageView?.image = UIImage(named: "icon_pin")
        
        return cell
    }
    
    override func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
        ) {
//        let detailController = storyboard!.instantiateViewController(
//            withIdentifier: "MemeDetailViewController"
//            ) as! MemeDetailViewController
//        detailController.meme = memes[(indexPath as NSIndexPath).row]
//        navigationController!.pushViewController(detailController, animated: true)
    }
    
    
    // MARK: Supplementary Functions
    
    // Displays the Create View
    func create() {
//        let memeCreateVC = storyboard!.instantiateViewController(
//            withIdentifier: "MemeCreateViewController"
//        )
//        present(memeCreateVC, animated: true, completion: nil)
    }
}
