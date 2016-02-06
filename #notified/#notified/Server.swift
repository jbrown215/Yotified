//
//  Server.swift
//  #notified
//
//  Created by Jordan Brown on 2/5/16.
//  Copyright © 2016 woosufjordaline. All rights reserved.
//

import Foundation
import Alamofire
import UIKit

class Server {
    static let SERVER = "http://3ff619ec.ngrok.io/"
    
    static func pingServer() {
        Alamofire.request(.GET, SERVER + "roster").responseString(completionHandler: {
            response in
            print(response.request)  // original URL request
            print(response.response) // URL response
            let dataString = NSString(data: response.data!, encoding:NSUTF8StringEncoding)
            print(dataString!)
            print(response.result)   // result of response serialization

        })
    }
    
    // API Calls
    
    //  Admin Calls
    
    static func genRoster (callback: Array<User> -> Void) {
        Alamofire.request(.GET, SERVER + "roster").responseJSON(
            options: NSJSONReadingOptions(rawValue: 0),
            completionHandler: {
            (response: Response<AnyObject, NSError>) in
                callback(parseUserListJSON(response.result.value!))
        })
    }
    
    static func genAdmins (callback: Array<User> -> Void) {
        Alamofire.request(.GET, SERVER + "admins").responseJSON(
            completionHandler: {
                (response: Response<AnyObject, NSError>) in
                callback(parseUserListJSON(response.result.value!))
        })
    }
    
    //  User Calls
    
    static func checkIn (lat : Float, long : Float, userId : Int) {
        let parameters = [
            "lat": String(lat),
            "long": String(long),
            "id": String(userId)
        ]
        
        Alamofire.request(.POST, SERVER + "checkin", parameters: parameters)/*.responseString(completionHandler: {
            response in
            print(response.request)  // original URL request
            print(response.response) // URL response
            let dataString = NSString(data: response.data!, encoding:NSUTF8StringEncoding)
            print(dataString!)
            print(response.result)   // result of response serialization
        })*/
    }
    
    static func checkOut (userId :Int) {
        let parameters = [ "_id": userId ]
        
        Alamofire.request(.POST, SERVER + "checkout", parameters: parameters)
    }
    
    static func report (lat: Double, long: Double, anon: Bool, userId: Int, callback: Int -> Void) {
        let parameters = [
            "lat": String(lat),
            "long": String(long),
            "anon": String(anon),
            "_id": String(userId)]
        
        Alamofire.request(.POST, SERVER + "report", parameters: parameters).responseJSON(completionHandler: {
            response in callback(parseReportJSON(response.result.value!)._id) })
    }

    static func lowBattery (lat: Double, long: Double, userId: Int) {
        let parameters = [
            "lat": String(lat),
            "long": String(long),
            "_id:": String(userId)]
        
        Alamofire.request(.POST, SERVER + "lowbatt", parameters: parameters)
    }
    
    static func reportInfo (data: String, reportId: Int) {
        let parameters = [
            "data": data,
            "_id": String(reportId)]
        
        Alamofire.request(.POST, SERVER + "reportinfo", parameters: parameters)
    }
    
    static func register (name: String, phone: Int, username: String, pword: String, callback: User -> Void) {
        let parameters = [
            "name": name,
            "phone": String(phone),
            "username": username,
            "password": pword, // BAD BAD BAD BAD
            "token": UIDevice.currentDevice().identifierForVendor!.UUIDString
        ]
        
        Alamofire.request(.POST, SERVER + "register", parameters: parameters).responseJSON(completionHandler: {
            response in callback(parseUserJSON(response.result.value!)) })
    }
    // JSON Parsing
    
    static func parseUserJSON (obj: AnyObject) -> User {
        let u:User = User()
        u.name = (obj["name"] as AnyObject? as? String) ?? ""
        u._id = Int((obj["_id"] as AnyObject? as? String) ?? "0")!
        u.phone = Int((obj["phone"] as AnyObject? as? String) ?? "0")!
        u.lat = Double((obj["lat"] as AnyObject? as? String) ?? "0.0")!
        u.long = Double((obj["long"] as AnyObject? as? String) ?? "0.0")!
        u.checkedin = (obj["checkedin"] as AnyObject? as? Bool) ?? false
        return u
    }
    
    static func parseUserListJSON (obj : AnyObject) -> Array<User> {
        var list: Array<User> = []
        
        let roster = (obj["roster"] as AnyObject? as? Array<AnyObject>) ?? []
            
        for json in roster {
            list.append(parseUserJSON(json))
        }
        
        return list
    }
    
    static func parseReportJSON (obj: AnyObject) -> Report {
        let r:Report = Report()
        r._id = Int((obj["_id"] as AnyObject? as? String) ?? "0")!
        r.name = (obj["name"] as AnyObject? as? String) ?? ""
        r.sender = Int((obj["sender"] as AnyObject? as? String) ?? "0")!
        r.handler = Int((obj["handler"] as AnyObject? as? String) ?? "0")!
        r.lat = Double((obj["lat"] as AnyObject? as? String) ?? "0.0")!
        r.long = Double((obj["long"] as AnyObject? as? String) ?? "0.0")!
        r.data = (obj["data"] as AnyObject? as? String) ?? ""
        
        return r
    }
    
    static func parseReportListJSON (obj : AnyObject) -> Array<Report> {
        var list: Array<Report> = []
        
        let roster = (obj["reports"] as AnyObject? as? Array<AnyObject>) ?? []
        
        for json in roster {
            list.append(parseReportJSON(json))
        }
        
        return list
    }
}

class User {
    var name = ""
    var _id = 0
    var phone = 0
    var lat = 0.0
    var long = 0.0
    var checkedin = false
    var admin = false
    var username = ""
    var password = ""
}

class Report {
    var _id = 0
    var name = ""
    var sender = 0
    var handler = 0
    var lat = 0.0
    var long = 0.0
    var data = ""
}


