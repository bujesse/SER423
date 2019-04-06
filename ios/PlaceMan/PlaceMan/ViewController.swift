//
//  ViewController.swift
//  PlaceMan
//
//  Created by Jesse Bu on 3/31/19.
//  Copyright © 2019 Jesse Bu. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var urlString:String = "http://127.0.0.1:8080"
    var places:[String]=[String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSLog("ViewController.viewDidLoad was called")
        
        self.setURL()
        self.getPlaces()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setURL () {
        if let infoPlist = Bundle.main.path(forResource: "Info", ofType: "plist") {
            if let dict = NSDictionary(contentsOfFile: infoPlist) as? [String:AnyObject] {
                self.urlString = (dict["ServerURLString"] as? String)!
                NSLog("The default urlString from info.plist is \(self.urlString)")
            }
        } else{
            NSLog("error getting urlString from info.plist")
        }
    }

    func getPlaces() {
        let aConnect:PlaceCollectionStub = PlaceCollectionStub(urlString: self.urlString)
        let _:Bool = aConnect.getNames(callback: { (res: String, err: String?) -> Void in
            if err != nil {
                NSLog(err!)
            }else{
                NSLog(res)
                if let data: Data = res.data(using: String.Encoding.utf8) {
                    do{
                        let dict = try JSONSerialization.jsonObject(with: data,options:.mutableContainers) as?[String:AnyObject]
                        self.places = (dict!["result"] as? [String])!
                        self.places = Array(self.places).sorted()
//                        self.studSelectTF.text = ((self.students.count>0) ? self.students[0] : "")
//                        self.studentPicker.reloadAllComponents()
                        if self.places.count > 0 {
//                            self.callGetNPopulatUIFields(self.students[0])
                            NSLog("Got places successfully")
                            for element in self.places {
                                print(element)
                            }
                        }
                    } catch {
                        print("unable to convert to dictionary")
                    }
                }
                
            }
        })  // end of method call to getNames
    }

}

