//
//  ParseConvenience.swift
//  OnTheMap
//
//  Created by Jacob Marttinen on 3/5/17.
//  Copyright © 2017 Jacob Marttinen. All rights reserved.
//

import UIKit
import Foundation

// MARK: - ParseClient (Convenient Resource Methods)

extension ParseClient {
    
    // MARK: GET Convenience Methods
    
    func getStudentLocations(_ limit: Int, skip: Int, order: String, completionHandlerForGetStudentLocations: @escaping (_ result: [StudentInformation]?, _ error: NSError?) -> Void) {
        
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
                completionHandlerForGetStudentLocations(nil, error)
            } else {
                
                if let results = results?[ParseClient.JSONResponseKeys.Results] as? [[String:AnyObject]] {
                    
                    let studentInformations = StudentInformation.studentInformationsFromResults(results)
                    completionHandlerForGetStudentLocations(studentInformations, nil)
                } else {
                    completionHandlerForGetStudentLocations(nil, NSError(domain: "getStudentLocations parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse getStudentLocations"]))
                }
            }
        }
    }
    
    func getStudentLocations2(_ limit: Int, skip: Int, order: String, completionHandlerForGetStudentLocations: @escaping (_ error: NSError?) -> Void) {
        
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
                    
                    ParseClient.sharedInstance().studentInformations = StudentInformation.studentInformationsFromResults(results)
                    completionHandlerForGetStudentLocations(nil)
                } else {
                    completionHandlerForGetStudentLocations(NSError(domain: "getStudentLocations parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse getStudentLocations"]))
                }
            }
        }
    }
    
    // MARK: POST Convenience Methods
    
//    func postToFavorites(_ studentInformation: StudentInformation, favorite: Bool, completionHandlerForFavorite: @escaping (_ result: Int?, _ error: NSError?) -> Void) {
//        
//        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
//        let parameters = [ParseClient.ParameterKeys.SessionID : ParseClient.sharedInstance().sessionID!]
//        var mutableMethod: String = Methods.AccountIDFavorite
//        mutableMethod = ClientHelpers.substituteKeyInMethod(mutableMethod, key: ParseClient.URLKeys.UserID, value: String(ParseClient.sharedInstance().userID!))!
//        let jsonBody = "{\"\(ParseClient.JSONBodyKeys.MediaType)\": \"studentInformation\",\"\(ParseClient.JSONBodyKeys.MediaID)\": \"\(studentInformation.id)\",\"\(ParseClient.JSONBodyKeys.Favorite)\": \(favorite)}"
//        
//        /* 2. Make the request */
//        let _ = taskForPOSTMethod(mutableMethod, parameters: parameters as [String:AnyObject], jsonBody: jsonBody) { (results, error) in
//            
//            /* 3. Send the desired value(s) to completion handler */
//            if let error = error {
//                completionHandlerForFavorite(nil, error)
//            } else {
//                if let results = results?[ParseClient.JSONResponseKeys.StatusCode] as? Int {
//                    completionHandlerForFavorite(results, nil)
//                } else {
//                    completionHandlerForFavorite(nil, NSError(domain: "postToFavoritesList parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse postToFavoritesList"]))
//                }
//            }
//        }
//    }
}
