//
//  ParseConvenience.swift
//  OnTheMap
//
//  Created by Jacob Marttinen on 3/5/17.
//  Copyright © 2017 Jacob Marttinen. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation

// MARK: - ParseClient (Convenient Resource Methods)

extension ParseClient {
    
    // MARK: GET Convenience Methods
    
    func getStudentLocations(
        _ limit: Int,
        skip: Int,
        order: String,
        completionHandlerForGetStudentLocations: @escaping (_ error: NSError?) -> Void
    ) {
        
        /* Specify parameters */
        let parameters = [
            ParseClient.ParameterKeys.Limit: limit,
            ParseClient.ParameterKeys.Skip: skip,
            ParseClient.ParameterKeys.Order: order
        ] as [String : Any]
        
        /* Make the request */
        let _ = taskForGETMethod(Methods.StudentLocation, parameters: parameters as [String:AnyObject]) { (results, error) in
            
            /* Send the desired value(s) to completion handler */
            if let error = error {
                completionHandlerForGetStudentLocations(error)
            } else {
    
                if let results = results?[ParseClient.JSONResponseKeys.Results] as? [[String:AnyObject]] {
                    StudentInformation.studentInformations = StudentInformation.studentInformationsFromResults(results)
                    completionHandlerForGetStudentLocations(nil)
                } else {
                    completionHandlerForGetStudentLocations(NSError(
                        domain: "getStudentLocations parsing",
                        code: 0,
                        userInfo: [NSLocalizedDescriptionKey: "Could not parse getStudentLocations"]
                    ))
                }
            }
        }
    }
    
    // MARK: POST Convenience Methods
    
    func postStudentLocation(
        _ mapString: String,
        mediaURL: String,
        coordinates: CLLocationCoordinate2D,
        completionHandlerForPostSession: @escaping (_ error: NSError?) -> Void
    ) {
        
        /* Specify HTTP body */
        let jsonBody = "{\"\(ParseClient.JSONResponseKeys.UniqueKey)\": \"\(UdacityClient.sharedInstance().user!.key)\", \"\(ParseClient.JSONResponseKeys.FirstName)\": \"\(UdacityClient.sharedInstance().user!.firstName)\", \"\(ParseClient.JSONResponseKeys.LastName)\": \"\(UdacityClient.sharedInstance().user!.lastName)\",\"\(ParseClient.JSONResponseKeys.MapString)\": \"\(mapString)\", \"\(ParseClient.JSONResponseKeys.MediaURL)\": \"\(mediaURL)\",\"\(ParseClient.JSONResponseKeys.Latitude)\": \(coordinates.latitude), \"\(ParseClient.JSONResponseKeys.Longitude)\": \(coordinates.longitude)}"
        
        /* Make the request */
        let _ = taskForPOSTMethod(Methods.StudentLocation, parameters: [:], jsonBody: jsonBody) { (results, error) in
            
            if let error = error {
                completionHandlerForPostSession(error)
                return
            }
            
            completionHandlerForPostSession(nil)
        }
    }
}
