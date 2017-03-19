//
//  UdacityUser.swift
//  OnTheMap
//
//  Created by Jacob Marttinen on 3/5/17.
//  Copyright © 2017 Jacob Marttinen. All rights reserved.
//

struct UdacityUser {
    
    // MARK: Properties
    
    let key: String
    let firstName: String
    let lastName: String
    
    // MARK: Initializers
    
    // construct a UdacityUser from a dictionary
    init(dictionary: [String:AnyObject]) {
        
        key = dictionary[UdacityClient.JSONResponseKeys.UserKey] as! String
        firstName = dictionary[UdacityClient.JSONResponseKeys.UserFirstName] as! String
        lastName = dictionary[UdacityClient.JSONResponseKeys.UserLastName] as! String
    }
    
    // convert a result to a UdacityUser
    static func userFromResult(_ result: [String:AnyObject]) -> UdacityUser {
        return UdacityUser(dictionary: result)
    }
}
