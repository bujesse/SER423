//
//  Place.swift
//  PlaceMan
//
//  Created by Jesse Bu on 3/31/19.

//  Copyright © 2019 Jesse Bu. All rights reserved.
//

import Foundation

public class Place {
    open var name: String
    open var description: String
    open var category: String
    open var address_title: String
    open var address_street: String
    open var elevation: Double
    open var latitude: Double
    open var longitude: Double

    init (jsonStr: String){
        self.name = ""
        self.description = ""
        self.category = ""
        self.address_title = ""
        self.address_street = ""
        self.elevation = 0.0
        self.latitude = 0.0
        self.longitude = 0.0
        
        if let data: Data = jsonStr.data(using: String.Encoding.utf8) {
            do {
                let dict = try JSONSerialization.jsonObject(with: data,options:.mutableContainers) as? [String:AnyObject]
                self.name = (dict!["name"] as? String)!
                self.description = (dict!["description"] as? String)!
                self.category = (dict!["category"] as? String)!
                self.address_title = (dict!["address_title"] as? String)!
                self.address_street = (dict!["address_street"] as? String)!
                self.elevation = (dict!["elevation"] as? Double)!
                self.latitude = (dict!["latitude"] as? Double)!
                self.longitude = (dict!["longitude"] as? Double)!
            } catch {
                print("unable to convert to dictionary")
            }
        }
    }

//    init(dict: [String:Any]){
//        self.name = dict["name"] as! String
//        self.studentid = dict["studentid"] as! Int
//        self.takes = dict["takes"] as! [String]
//    }

//    func toJsonString() -> String {
//        var jsonStr = "";
//        let dict = ["name": name, "studentid": studentid, "takes":takes] as [String : Any]
//        do {
//            let jsonData = try JSONSerialization.data(withJSONObject: dict, options: JSONSerialization.WritingOptions.prettyPrinted)
//            // here "jsonData" is the dictionary encoded in JSON data
//            jsonStr = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)! as String
//        } catch let error as NSError {
//            print(error)
//        }
//        return jsonStr
//    }
//
//    func toDict() -> [String:Any] {
//        let dict:[String:Any] = ["name": name, "studentid": studentid, "takes":takes] as [String : Any]
//        return dict
//    }
}
