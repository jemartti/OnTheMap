//
//  StudentInformation.swift
//  OnTheMap
//
//  Created by Jacob Marttinen on 3/5/17.
//  Copyright © 2017 Jacob Marttinen. All rights reserved.
//

struct StudentInformation {
    
    // Application State
    static var studentInformations : [StudentInformation] = []
    
    // MARK: Properties
    
    let objectId: String
    let uniqueKey: String?
    let firstName: String?
    let lastName: String?
    let mapString: String?
    let mediaURL: String?
    let latitude: Float?
    let longitude: Float?
    
    // MARK: Initializers
    
    // construct a StudentInformation from a dictionary
    init(dictionary: [String:AnyObject]) {
        
        objectId = dictionary[ParseClient.JSONResponseKeys.ObjectID] as! String
        uniqueKey = dictionary[ParseClient.JSONResponseKeys.UniqueKey] as? String
        firstName = dictionary[ParseClient.JSONResponseKeys.FirstName] as? String
        lastName = dictionary[ParseClient.JSONResponseKeys.LastName] as? String
        mapString = dictionary[ParseClient.JSONResponseKeys.MapString] as? String
        mediaURL = dictionary[ParseClient.JSONResponseKeys.MediaURL] as? String
        latitude = dictionary[ParseClient.JSONResponseKeys.Latitude] as? Float
        longitude = dictionary[ParseClient.JSONResponseKeys.Longitude] as? Float
    }
    
    // Convert results to an array of StudentInformations
    static func studentInformationsFromResults(_ results: [[String:AnyObject]]) -> [StudentInformation] {
        
        var studentInformations = [StudentInformation]()
        
        // iterate through array of dictionaries, each ParseStudent is a dictionary
        for result in results {
            studentInformations.append(StudentInformation(dictionary: result))
        }
        
        return studentInformations
    }
}

// MARK: - StudentInformation: Equatable

extension StudentInformation: Equatable {}

func ==(lhs: StudentInformation, rhs: StudentInformation) -> Bool {
    return lhs.objectId == rhs.objectId
}
