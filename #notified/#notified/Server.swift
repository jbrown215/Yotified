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
    static let SERVER = "http://ec1880c5.ngrok.io/"
    
    static func pingServer() {
        Alamofire.request(.GET, SERVER).responseString(completionHandler: {
            response in
            print(response.request)  // original URL request
            print(response.response) // URL response
            var dataString = NSString(data: response.data!, encoding:NSUTF8StringEncoding)
            print(dataString!)
            print(response.result)   // result of response serialization

        })
    }
}


