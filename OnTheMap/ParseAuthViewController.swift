//
//  ParseAuthViewController.swift
//  OnTheMap
//
//  Created by Jacob Marttinen on 3/5/17.
//  Copyright © 2017 Jacob Marttinen. All rights reserved.
//

import UIKit

// MARK: - ParseAuthViewController: UIViewController

class ParseAuthViewController: UIViewController {
    
    // MARK: Properties
    
    var urlRequest: URLRequest? = nil
    var requestToken: String? = nil
    var completionHandlerForView: ((_ success: Bool, _ errorString: String?) -> Void)? = nil
    
    // MARK: Outlets
    
    @IBOutlet weak var webView: UIWebView!
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.delegate = self
        
        navigationItem.title = "TheMovieDB Auth"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelAuth))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let urlRequest = urlRequest {
            webView.loadRequest(urlRequest)
        }
    }
    
    // MARK: Cancel Auth Flow
    
    func cancelAuth() {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - ParseAuthViewController: UIWebViewDelegate

extension ParseAuthViewController: UIWebViewDelegate {
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        
        // if user has to login, this will redirect them back to the authorization url
        if webView.request!.url!.absoluteString.contains(ParseClient.Constants.AccountURL) {
            if let urlRequest = urlRequest {
                webView.loadRequest(urlRequest)
            }
        }
        
        if webView.request!.url!.absoluteString == "\(ParseClient.Constants.AuthorizationURL)\(requestToken!)/allow" {
            
            dismiss(animated: true) {
                self.completionHandlerForView!(true, nil)
            }
        }
    }
}
