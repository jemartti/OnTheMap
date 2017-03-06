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
    
    // MARK: Authentication (GET) Methods
    /*
     Steps for Authentication...
     https://www.themoviedb.org/documentation/api/sessions
     
     Step 1: Create a new request token
     Step 2a: Ask the user for permission via the website
     Step 3: Create a session ID
     Bonus Step: Go ahead and get the user id 😄!
     */
    func authenticateWithViewController(_ hostViewController: UIViewController, completionHandlerForAuth: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
        
        // chain completion handlers for each request so that they run one after the other
        getRequestToken() { (success, requestToken, errorString) in
            
            if success {
                
                // success! we have the requestToken!
                self.requestToken = requestToken
                
                self.loginWithToken(requestToken, hostViewController: hostViewController) { (success, errorString) in
                    
                    if success {
                        self.getSessionID(requestToken) { (success, sessionID, errorString) in
                            
                            if success {
                                
                                // success! we have the sessionID!
                                self.sessionID = sessionID
                                
                                self.getUserID() { (success, userID, errorString) in
                                    
                                    if success {
                                        
                                        if let userID = userID {
                                            
                                            // and the userID 😄!
                                            self.userID = userID
                                        }
                                    }
                                    
                                    completionHandlerForAuth(success, errorString)
                                }
                            } else {
                                completionHandlerForAuth(success, errorString)
                            }
                        }
                    } else {
                        completionHandlerForAuth(success, errorString)
                    }
                }
            } else {
                completionHandlerForAuth(success, errorString)
            }
        }
    }
    
    private func getRequestToken(_ completionHandlerForToken: @escaping (_ success: Bool, _ requestToken: String?, _ errorString: String?) -> Void) {
        
        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
        let parameters = [String:AnyObject]()
        
        /* 2. Make the request */
        let _ = taskForGETMethod(Methods.AuthenticationTokenNew, parameters: parameters) { (results, error) in
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                print(error)
                completionHandlerForToken(false, nil, "Login Failed (Request Token).")
            } else {
                if let requestToken = results?[ParseClient.JSONResponseKeys.RequestToken] as? String {
                    completionHandlerForToken(true, requestToken, nil)
                } else {
                    print("Could not find \(ParseClient.JSONResponseKeys.RequestToken) in \(results)")
                    completionHandlerForToken(false, nil, "Login Failed (Request Token).")
                }
            }
        }
    }
    
    /* This function opens a ParseAuthViewController to handle Step 2a of the auth flow */
    private func loginWithToken(_ requestToken: String?, hostViewController: UIViewController, completionHandlerForLogin: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
        
        let authorizationURL = URL(string: "\(ParseClient.Constants.AuthorizationURL)\(requestToken!)")
        let request = URLRequest(url: authorizationURL!)
        let webAuthViewController = hostViewController.storyboard!.instantiateViewController(withIdentifier: "ParseAuthViewController") as! ParseAuthViewController
        webAuthViewController.urlRequest = request
        webAuthViewController.requestToken = requestToken
        webAuthViewController.completionHandlerForView = completionHandlerForLogin
        
        let webAuthNavigationController = UINavigationController()
        webAuthNavigationController.pushViewController(webAuthViewController, animated: false)
        
        performUIUpdatesOnMain {
            hostViewController.present(webAuthNavigationController, animated: true, completion: nil)
        }
    }
    
    private func getSessionID(_ requestToken: String?, completionHandlerForSession: @escaping (_ success: Bool, _ sessionID: String?, _ errorString: String?) -> Void) {
        
        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
        let parameters = [ParseClient.ParameterKeys.RequestToken: requestToken!]
        
        /* 2. Make the request */
        let _ = taskForGETMethod(Methods.AuthenticationSessionNew, parameters: parameters as [String:AnyObject]) { (results, error) in
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                print(error)
                completionHandlerForSession(false, nil, "Login Failed (Session ID).")
            } else {
                if let sessionID = results?[ParseClient.JSONResponseKeys.SessionID] as? String {
                    completionHandlerForSession(true, sessionID, nil)
                } else {
                    print("Could not find \(ParseClient.JSONResponseKeys.SessionID) in \(results)")
                    completionHandlerForSession(false, nil, "Login Failed (Session ID).")
                }
            }
        }
    }
    
    private func getUserID(_ completionHandlerForUserID: @escaping (_ success: Bool, _ userID: Int?, _ errorString: String?) -> Void) {
        
        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
        let parameters = [ParseClient.ParameterKeys.SessionID: ParseClient.sharedInstance().sessionID!]
        
        /* 2. Make the request */
        let _ = taskForGETMethod(Methods.Account, parameters: parameters as [String:AnyObject]) { (results, error) in
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                print(error)
                completionHandlerForUserID(false, nil, "Login Failed (User ID).")
            } else {
                if let userID = results?[ParseClient.JSONResponseKeys.UserID] as? Int {
                    completionHandlerForUserID(true, userID, nil)
                } else {
                    print("Could not find \(ParseClient.JSONResponseKeys.UserID) in \(results)")
                    completionHandlerForUserID(false, nil, "Login Failed (User ID).")
                }
            }
        }
    }
    
    // MARK: GET Convenience Methods
    
    func getFavoriteMovies(_ completionHandlerForFavMovies: @escaping (_ result: [ParseMovie]?, _ error: NSError?) -> Void) {
        
        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
        let parameters = [ParseClient.ParameterKeys.SessionID: ParseClient.sharedInstance().sessionID!]
        var mutableMethod: String = Methods.AccountIDFavoriteMovies
        mutableMethod = ClientHelpers.substituteKeyInMethod(mutableMethod, key: ParseClient.URLKeys.UserID, value: String(ParseClient.sharedInstance().userID!))!
        
        /* 2. Make the request */
        let _ = taskForGETMethod(mutableMethod, parameters: parameters as [String:AnyObject]) { (results, error) in
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                completionHandlerForFavMovies(nil, error)
            } else {
                
                if let results = results?[ParseClient.JSONResponseKeys.MovieResults] as? [[String:AnyObject]] {
                    
                    let movies = ParseMovie.moviesFromResults(results)
                    completionHandlerForFavMovies(movies, nil)
                } else {
                    completionHandlerForFavMovies(nil, NSError(domain: "getFavoriteMovies parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse getFavoriteMovies"]))
                }
            }
        }
    }
    
    func getWatchlistMovies(_ completionHandlerForWatchlist: @escaping (_ result: [ParseMovie]?, _ error: NSError?) -> Void) {
        
        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
        let parameters = [ParseClient.ParameterKeys.SessionID: ParseClient.sharedInstance().sessionID!]
        var mutableMethod: String = Methods.AccountIDWatchlistMovies
        mutableMethod = ClientHelpers.substituteKeyInMethod(mutableMethod, key: ParseClient.URLKeys.UserID, value: String(ParseClient.sharedInstance().userID!))!
        
        /* 2. Make the request */
        let _ = taskForGETMethod(mutableMethod, parameters: parameters as [String:AnyObject]) { (results, error) in
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                completionHandlerForWatchlist(nil, error)
            } else {
                
                if let results = results?[ParseClient.JSONResponseKeys.MovieResults] as? [[String:AnyObject]] {
                    
                    let movies = ParseMovie.moviesFromResults(results)
                    completionHandlerForWatchlist(movies, nil)
                } else {
                    completionHandlerForWatchlist(nil, NSError(domain: "getWatchlistMovies parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse getWatchlistMovies"]))
                }
            }
        }
    }
    
    func getMoviesForSearchString(_ searchString: String, completionHandlerForMovies: @escaping (_ result: [ParseMovie]?, _ error: NSError?) -> Void) -> URLSessionDataTask? {
        
        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
        let parameters = [ParseClient.ParameterKeys.Query: searchString]
        
        /* 2. Make the request */
        let task = taskForGETMethod(Methods.SearchMovie, parameters: parameters as [String:AnyObject]) { (results, error) in
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                completionHandlerForMovies(nil, error)
            } else {
                
                if let results = results?[ParseClient.JSONResponseKeys.MovieResults] as? [[String:AnyObject]] {
                    
                    let movies = ParseMovie.moviesFromResults(results)
                    completionHandlerForMovies(movies, nil)
                } else {
                    completionHandlerForMovies(nil, NSError(domain: "getMoviesForSearchString parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse getMoviesForSearchString"]))
                }
            }
        }
        
        return task
    }
    
    func getConfig(_ completionHandlerForConfig: @escaping (_ didSucceed: Bool, _ error: NSError?) -> Void) {
        
        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
        let parameters = [String:AnyObject]()
        
        /* 2. Make the request */
        let _ = taskForGETMethod(Methods.Config, parameters: parameters) { (results, error) in
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                completionHandlerForConfig(false, error)
            } else if let newConfig = ParseConfig(dictionary: results as! [String:AnyObject]) {
                self.config = newConfig
                completionHandlerForConfig(true, nil)
            } else {
                completionHandlerForConfig(false, NSError(domain: "getConfig parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse getConfig"]))
            }
        }
    }
    
    // MARK: POST Convenience Methods
    
    func postToFavorites(_ movie: ParseMovie, favorite: Bool, completionHandlerForFavorite: @escaping (_ result: Int?, _ error: NSError?) -> Void) {
        
        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
        let parameters = [ParseClient.ParameterKeys.SessionID : ParseClient.sharedInstance().sessionID!]
        var mutableMethod: String = Methods.AccountIDFavorite
        mutableMethod = ClientHelpers.substituteKeyInMethod(mutableMethod, key: ParseClient.URLKeys.UserID, value: String(ParseClient.sharedInstance().userID!))!
        let jsonBody = "{\"\(ParseClient.JSONBodyKeys.MediaType)\": \"movie\",\"\(ParseClient.JSONBodyKeys.MediaID)\": \"\(movie.id)\",\"\(ParseClient.JSONBodyKeys.Favorite)\": \(favorite)}"
        
        /* 2. Make the request */
        let _ = taskForPOSTMethod(mutableMethod, parameters: parameters as [String:AnyObject], jsonBody: jsonBody) { (results, error) in
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                completionHandlerForFavorite(nil, error)
            } else {
                if let results = results?[ParseClient.JSONResponseKeys.StatusCode] as? Int {
                    completionHandlerForFavorite(results, nil)
                } else {
                    completionHandlerForFavorite(nil, NSError(domain: "postToFavoritesList parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse postToFavoritesList"]))
                }
            }
        }
    }
    
    func postToWatchlist(_ movie: ParseMovie, watchlist: Bool, completionHandlerForWatchlist: @escaping (_ result: Int?, _ error: NSError?) -> Void) {
        
        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
        let parameters = [ParseClient.ParameterKeys.SessionID : ParseClient.sharedInstance().sessionID!]
        var mutableMethod: String = Methods.AccountIDWatchlist
        mutableMethod = ClientHelpers.substituteKeyInMethod(mutableMethod, key: ParseClient.URLKeys.UserID, value: String(ParseClient.sharedInstance().userID!))!
        let jsonBody = "{\"\(ParseClient.JSONBodyKeys.MediaType)\": \"movie\",\"\(ParseClient.JSONBodyKeys.MediaID)\": \"\(movie.id)\",\"\(ParseClient.JSONBodyKeys.Watchlist)\": \(watchlist)}"
        
        /* 2. Make the request */
        let _ = taskForPOSTMethod(mutableMethod, parameters: parameters as [String:AnyObject], jsonBody: jsonBody) { (results, error) in
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                completionHandlerForWatchlist(nil, error)
            } else {
                if let results = results?[ParseClient.JSONResponseKeys.StatusCode] as? Int {
                    completionHandlerForWatchlist(results, nil)
                } else {
                    completionHandlerForWatchlist(nil, NSError(domain: "postToWatchlist parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse postToWatchlist"]))
                }
            }
        }
    }
}
