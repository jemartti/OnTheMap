//
//  ParseMovie.swift
//  OnTheMap
//
//  Created by Jacob Marttinen on 3/5/17.
//  Copyright © 2017 Jacob Marttinen. All rights reserved.
//

struct ParseMovie {
    
    // MARK: Properties
    
    let title: String
    let id: Int
    let posterPath: String?
    let releaseYear: String?
    
    // MARK: Initializers
    
    // construct a ParseMovie from a dictionary
    init(dictionary: [String:AnyObject]) {
        title = dictionary[ParseClient.JSONResponseKeys.MovieTitle] as! String
        id = dictionary[ParseClient.JSONResponseKeys.MovieID] as! Int
        posterPath = dictionary[ParseClient.JSONResponseKeys.MoviePosterPath] as? String
        
        if let releaseDateString = dictionary[ParseClient.JSONResponseKeys.MovieReleaseDate] as? String, releaseDateString.isEmpty == false {
            releaseYear = releaseDateString.substring(to: releaseDateString.characters.index(releaseDateString.startIndex, offsetBy: 4))
        } else {
            releaseYear = ""
        }
    }
    
    static func moviesFromResults(_ results: [[String:AnyObject]]) -> [ParseMovie] {
        
        var movies = [ParseMovie]()
        
        // iterate through array of dictionaries, each Movie is a dictionary
        for result in results {
            movies.append(ParseMovie(dictionary: result))
        }
        
        return movies
    }
}

// MARK: - ParseMovie: Equatable

extension ParseMovie: Equatable {}

func ==(lhs: ParseMovie, rhs: ParseMovie) -> Bool {
    return lhs.id == rhs.id
}
