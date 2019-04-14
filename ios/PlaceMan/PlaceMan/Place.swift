//
//  Place.swift
//  PlaceMan

//  Tim Lindquist and ASU instructors have the right to build and evaluate the software package for the purpose of determining grade and program assessment
//  Copyright © 2019 Jesse Bu. All rights reserved.
//  @author Jesse Bu mailto:jbbu1@asu.edu.
//  @version March 31, 2019
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
    
    public init(name: String, description: String, category: String, address_title: String, address_street: String, elevation: Double, latitude: Double, longitude: Double){
        self.name = name
        self.description = description
        self.category = category
        self.address_title = address_title
        self.address_street = address_street
        self.elevation = elevation
        self.latitude = latitude
        self.longitude = longitude
    }

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

    init(dict: [String:Any]){
        self.name = dict["name"] as! String
        self.description = (dict["description"] as! String)
        self.category = (dict["category"] as! String)
        self.address_title = (dict["address-title"] as! String)
        self.address_street = (dict["address-street"] as! String)
        self.elevation = (dict["elevation"] as! Double)
        self.latitude = (dict["latitude"] as! Double)
        self.longitude = (dict["longitude"] as! Double)
    }

    func toDict() -> [String:Any] {
        let dict:[String:Any] = ["name": name, "description": description, "category": category, "address-title": address_title, "address-street": address_street, "elevation": elevation, "latitude": latitude, "longitude": longitude] as [String : Any]
        return dict
    }
}
