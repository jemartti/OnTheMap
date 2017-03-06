//
//  UdacityConstants.swift
//  OnTheMap
//
//  Created by Jacob Marttinen on 3/5/17.
//  Copyright © 2017 Jacob Marttinen. All rights reserved.
//

extension UdacityClient {
    
    // MARK: Constants
    struct Constants {
        
        // MARK: URLs
        
        static let ApiScheme = "https"
        static let ApiHost = "www.udacity.com"
        static let ApiPath = "/api"
    }
    
    // MARK: Methods
    struct Methods {
        
        // MARK: Account
        
        static let Account = "/session"
        
        // MARK: Users
        
        static let UsersKey = "/users/{key}"
    }
    
    // MARK: URL Keys
    
    struct URLKeys {
        static let UserKey = "key"
    }
    
    // MARK: JSON Body Keys
    
    struct JSONBodyKeys {
        static let Udacity = "udacity"
        static let Username = "username"
        static let Password = "password"
    }
    
    // MARK: JSON Response Keys
    
    struct JSONResponseKeys {
        
        // MARK: Account
        
        static let Account = "account"
        static let AccountRegistered = "registered"
        static let AccountKey = "key"
        
        // MARK: Session
        
        static let Session = "session"
        static let SessionID = "id"
        
        // MARK: User
        
        static let User = "user"
        static let UserKey = "key"
        static let UserFirstName = "first_name"
        static let UserLastName = "last_name"
    }
}
