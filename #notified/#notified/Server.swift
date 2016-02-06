//
//  Server.swift
//  #notified
//
//  Created by Jordan Brown on 2/5/16.
//  Copyright © 2016 woosufjordaline. All rights reserved.
//

import Foundation
import Alamofire

class Server {
    static let SERVER = "http://29b4e03b.ngrok.io/"
    
    static func pingServer() {
        Alamofire.request(.GET, SERVER).responseString(completionHandler: {
            response in
            print(response.request)  // original URL request
            print(response.response) // URL response
            let dataString = NSString(data: response.data!, encoding:NSUTF8StringEncoding)
            print(dataString!)
            print(response.result)   // result of response serialization

        })
    }
    
    static func roster () {
        Alamofire.request(.GET, SERVER + "roster").responseString(completionHandler: {
            response in
            print(response.request)  // original URL request
            print(response.response) // URL response
            let dataString = NSString(data: response.data!, encoding:NSUTF8StringEncoding)
            print(dataString!)
            print(response.result)   // result of response serialization
        })
    }
    
    static func admins () {
        Alamofire.request(.GET, SERVER + "admins").responseString(completionHandler: {
            response in
            print(response.request)  // original URL request
            print(response.response) // URL response
            let dataString = NSString(data: response.data!, encoding:NSUTF8StringEncoding)
            print(dataString!)
            print(response.result)   // result of response serialization
        })
    }
}


