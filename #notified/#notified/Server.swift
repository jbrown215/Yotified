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
import CryptoSwift

class Server {
    static let SERVER = "http://3ff619ec.ngrok.io/"
    
    static func pingServer() {
        Alamofire.request(.GET, SERVER + "roster").responseString(completionHandler: {
            response in
            print(response.request)  // original URL request
            print(response.response) // URL response
            print(response.response!.statusCode)
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
                let code = response.response!.statusCode
                if code == 200 {
                    callback(parseUserListJSON(response.result.value!))
                } else {
                    print("genRoster failed with status code " + String(code))
                }
        })
    }
    
    static func genAdmins (callback: Array<User> -> Void) {
        Alamofire.request(.GET, SERVER + "admins").responseJSON(
            completionHandler: {
                (response: Response<AnyObject, NSError>) in
                let code = response.response!.statusCode
                if code == 200 {
                    callback(parseUserListJSON(response.result.value!))
                } else {
                    print("genAdmins failed with status code " + String(code))
                }
        })
    }
    
    static func genCheckedIn (callback: Array<User> -> Void) {
        Alamofire.request(.GET, SERVER + "checkedin").responseJSON(
            options: NSJSONReadingOptions(rawValue: 0),
            completionHandler: {
                (response: Response<AnyObject, NSError>) in
                let code = response.response!.statusCode
                if code == 200 {
                    print("it worked")
                    callback(parseUserListJSON(response.result.value!))
                } else {
                    print("genCheckedIn failed with status code " + String(code))
                }
        })
    }
    
    static func genReports (callback: Array<Report> -> Void) {
        Alamofire.request(.GET, SERVER + "reports").responseJSON(
            options: NSJSONReadingOptions(rawValue: 0),
            completionHandler: {
                (response: Response<AnyObject, NSError>) in
                let code = response.response!.statusCode
                if code == 200 {
                    let dataString = NSString(data: response.data!, encoding:NSUTF8StringEncoding)
                    print(dataString!)
                    let reports = parseReportListJSON(response.result.value!)
                    callback(reports)
                } else {
                    print("genReports failed with status code " + String(code))
                }
        })
    }
    
    static func addAdmin (userId: Int, callback: Void -> Void) {
        Alamofire.request(.POST, SERVER + "addadmin", parameters: ["_id": userId]).responseJSON(
            completionHandler: {
                (response: Response<AnyObject, NSError>) in
                let code = response.response!.statusCode
                if code == 200 {
                    callback ()
                } else {
                    print("addAdmin failed with status code " + String(code))
                }
        })
    }
    
    static func deleteAdmin (userId: Int, successCallback: Void -> Void, failureCallback: Int -> Void) {
        Alamofire.request(.POST, SERVER + "deladmin", parameters: ["_id": userId]).responseJSON(
            completionHandler: {
                (response: Response<AnyObject, NSError>) in
                let code = response.response!.statusCode
                if code == 200 {
                    successCallback ()
                } else {
                    failureCallback (code)
                }
        })
    }
    
    static func toggleDuty (userId: Int, successCallback: Void -> Void, failureCallback: Int -> Void) {
        Alamofire.request(.POST, SERVER + "toggleduty", parameters: ["_id": userId]).responseJSON(
            completionHandler: {
                (response: Response<AnyObject, NSError>) in
                let code = response.response!.statusCode
                if code == 200 {
                    successCallback ()
                } else {
                    failureCallback (code)
                }
        })
    }
    
    static func handleReport (reportId: Int, userId: Int, callback: Void -> Void) {
        Alamofire.request(.POST, SERVER + "handlereport", parameters: ["_id": reportId, "handler": userId]).responseJSON(
            completionHandler: {
                (response: Response<AnyObject, NSError>) in
                let code = response.response!.statusCode
                if code == 200 {
                    callback ()
                } else {
                    print("handleReport failed with status code " + String(code))
                }
        })
    }
    
    static func clearReport (reportId: Int, callback: Void -> Void) {
        Alamofire.request(.POST, SERVER + "clearreport", parameters: ["_id": reportId]).responseJSON(
            completionHandler: {
                (response: Response<AnyObject, NSError>) in
                let code = response.response!.statusCode
                if code == 200 {
                    callback ()
                } else {
                    print("clearReport failed with status code " + String(code))
                }
        })
    }
    
    //  User Calls
    
    static func checkIn (lat : Double, long : Double, userId : Int) {
        let parameters = [
            "lat": String(lat),
            "long": String(long),
            "_id": String(userId)
        ]
        
        Alamofire.request(.POST, SERVER + "checkin", parameters: parameters)
    }
    
    static func checkOut (userId :Int) {
        let parameters = [ "_id": userId ]
        
        Alamofire.request(.POST, SERVER + "checkout", parameters: parameters)
    }
    
    static func report (lat: Double, long: Double, userId: Int, callback: String -> Void) {
        let parameters = [
            "lat": String(lat),
            "long": String(long),
            "_id": String(userId)]
        
        Alamofire.request(.POST, SERVER + "report", parameters: parameters).responseJSON(completionHandler: {
            response in
            let code = response.response!.statusCode
            if code == 200 {
                let report = parseReportJSON(response.result.value!)
                callback(report._id)
            } else {
                print("report failed with status code " + String(code))
            }
        })
    }

    static func lowBattery (lat: Double, long: Double, userId: Int) {
        let parameters = [
            "lat": String(lat),
            "long": String(long),
            "_id:": String(userId)]
        
        Alamofire.request(.POST, SERVER + "lowbatt", parameters: parameters)
    }
    
    static func reportInfo (location: String, drunk: Bool, assault: Bool, drugs: Bool, other: Bool, needs_help: String, reportId: String, anon: Bool, senderId: Int) {
        let parameters = [
            "location": location,
            "drunk": String(drunk),
            "sa": String(assault),
            "drugs": String(drugs),
            "other": String(other),
            "needs_help": needs_help,
            "anon": String(anon),
            "sender": String(senderId),
            "_id": reportId]
        
        Alamofire.request(.POST, SERVER + "reportinfo", parameters: parameters)
    }
    
    static func register (name: String, phone: Int, username: String, pword: String, successCallback: User -> Void, failCallback: Int -> Void) {
        let parameters = [
            "name": name,
            "phone": String(phone),
            "username": username,
            "password": pword.sha224(),
            "token": UIDevice.currentDevice().identifierForVendor!.UUIDString
        ]
        
        Alamofire.request(.POST, SERVER + "register", parameters: parameters).responseJSON(completionHandler: {
            response in
            let code = response.response!.statusCode
            if code == 200 {
                successCallback(parseUserJSON(response.result.value!))
            } else {
                failCallback(code)
            }
        })
    }
    
    static func login (username: String, pword: String, successCallback: User -> Void, failCallback: Int -> Void) {
        let parameters = [
            "username": username,
            "password": pword.sha224()
        ]
        
        Alamofire.request(.POST, SERVER + "login", parameters: parameters).responseJSON(completionHandler: {
            response in
            let code = response.response!.statusCode
            if code == 200 {
                successCallback(parseUserJSON(response.result.value!))
            } else {
                failCallback(code)
            }
        })
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
        r._id = (obj["_id"] as AnyObject? as? String) ?? ""
        r.name = (obj["name"] as AnyObject? as? String) ?? ""
        r.sender = Int((obj["sender"] as AnyObject? as? String) ?? "0")!
        r.handler = Int((obj["handler"] as AnyObject? as? String) ?? "0")!
        r.lat = Double((obj["lat"] as AnyObject? as? String) ?? "0.0")!
        r.long = Double((obj["long"] as AnyObject? as? String) ?? "0.0")!
        r.drunk = (obj["drunk"] as AnyObject? as? Bool) ?? false
        r.sa = (obj["sa"] as AnyObject? as? Bool) ?? false
        r.drugs = (obj[""] as AnyObject? as? Bool) ?? false
        r.other = (obj["other"] as AnyObject? as? Bool) ?? false
        r.location = (obj["location"] as AnyObject? as? String) ?? ""
        r.needs_help = (obj["needs_help"] as AnyObject? as? String) ?? ""
        
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
    var _id = ""
    var name = ""
    var sender = 0
    var handler = 0
    var lat = 0.0
    var long = 0.0
    var drunk = false
    var sa = false
    var drugs = false
    var other = false
    var location = ""
    var needs_help = ""
}


