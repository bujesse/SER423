//
//  ViewController.swift
//  PlaceMan
//
//  Created by Jesse Bu on 3/31/19.
//  Copyright © 2019 Jesse Bu. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate {
    
    var urlString:String = "http://127.0.0.1:8080"
    var places:[String]=[String]()
    var selectedPlace:String = "unknown"

    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var descTF: UITextField!
    @IBOutlet weak var categoryTF: UITextField!
    @IBOutlet weak var addressTitleTF: UITextField!
    @IBOutlet weak var addressStreetTF: UITextField!
    @IBOutlet weak var elevationTF: UITextField!
    @IBOutlet weak var latitudeTF: UITextField!
    @IBOutlet weak var longitudeTF: UITextField!
    
    @IBOutlet weak var saveBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSLog("ViewController.viewDidLoad was called")
        saveBtn.layer.cornerRadius = 15  // round the button
        
        self.setURL()
        self.callGetNPopulateUIFields(self.selectedPlace)
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

    func callGetNPopulateUIFields(_ name: String){
        let aConnect:PlaceCollectionStub = PlaceCollectionStub(urlString: urlString)
        let _:Bool = aConnect.get(name: name, callback: { (res: String, err: String?) -> Void in
            if err != nil {
                NSLog(err!)
            }else{
                NSLog(res)
                if let data: Data = res.data(using: String.Encoding.utf8){
                    do{
                        let dict = try JSONSerialization.jsonObject(with: data,options:.mutableContainers) as?[String:AnyObject]
                        let aDict:[String:AnyObject] = (dict!["result"] as? [String:AnyObject])!
                        let aPlace:Place = Place(dict: aDict)
                        
                        self.nameTF.text = aPlace.name
                        self.descTF.text = aPlace.description
                        self.categoryTF.text = aPlace.category
                        self.addressTitleTF.text = aPlace.address_title
                        self.addressStreetTF.text = aPlace.address_street
                        self.elevationTF.text = String(aPlace.elevation)
                        self.latitudeTF.text = String(aPlace.latitude)
                        self.longitudeTF.text = String(aPlace.longitude)
                    } catch {
                        NSLog("unable to convert to dictionary")
                    }
                }
            }
        })
    }

    // touch events on this view
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.nameTF.resignFirstResponder()
    }
    
    @IBAction func saveBtnClicked(_ sender: Any) {
        print("Save Button Clicked")
        print(self.nameTF.text!)
    }
    
    // MARK: -- UITextFieldDelegate Method
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.nameTF.resignFirstResponder()
        return true
    }

//  Called after clicking back, but before loading the table view, so reload that data with this view's data
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool){
        print("entered navigationController willShow viewController")
        if let controller = viewController as? PlaceTableViewController {
            controller.places = self.places
            controller.tableView.reloadData()
        }
    }

}

