//
//  PlaceTableViewController.swift
//  PlaceMan
//
//  Created by Jesse Bu on 3/31/19.
//  Copyright © 2019 Jesse Bu. All rights reserved.
//

import UIKit
import Foundation

class PlaceTableViewController: UITableViewController {
    
    var urlString:String = "http://127.0.0.1:8080"
    var places:[String]=[String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSLog("PlaceTableViewController.viewDidLoad was called")
        
//        UI Components
        self.navigationItem.leftBarButtonItem = self.editButtonItem
        let addButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(PlaceTableViewController.addPlace))
        self.navigationItem.rightBarButtonItem = addButton
        
        self.setURL()
        self.getPlaces()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
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
            } else {
                NSLog(res)
                if let data: Data = res.data(using: String.Encoding.utf8) {
                    do {
                        let dict = try JSONSerialization.jsonObject(with: data,options:.mutableContainers) as?[String:AnyObject]
                        self.places = (dict!["result"] as? [String])!
                        self.places = Array(self.places).sorted()
                        if self.places.count > 0 {
                            NSLog("Got places successfully")
                            for element in self.places {
                                print(element)
                            }
                            self.tableView.reloadData()
                        }
                    } catch {
                        print("unable to convert to dictionary")
                    }
                }
                
            }
        })
    }
    
    // called with the Navigation Bar Add button (+) is clicked
    @objc func addPlace() {
        print("add button clicked")
        //  query the user for the new place name and number. empty takes
        let promptND = UIAlertController(title: "New Place", message: "Enter Place Information", preferredStyle: UIAlertControllerStyle.alert)
        // if the user cancels, we don't want to add a place
        promptND.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: nil))
        // setup the OK action and provide a closure to be executed when/if OK selected
        promptND.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) -> Void in
            let newPlaceName:String = (promptND.textFields?[0].text == "") ? "unknown" : (promptND.textFields?[0].text)!
            let newPlaceDesc:String = (promptND.textFields?[1].text == "") ? "unknown" : (promptND.textFields?[1].text)!
            let newPlaceCat:String = (promptND.textFields?[2].text == "") ? "unknown" : (promptND.textFields?[2].text)!
            let newPlaceAddressTitle:String = (promptND.textFields?[3].text == "") ? "unknown" : (promptND.textFields?[3].text)!
            let newPlaceAddressStreet:String = (promptND.textFields?[4].text == "") ? "unknown" : (promptND.textFields?[4].text)!
            
            // since didn't specify the keyboard, don't know whether id is empty, alpha, or numeric:
            var newPlaceElev:Double = -1
            if let myNumber = NumberFormatter().number(from: (promptND.textFields?[5].text)!) {
                newPlaceElev = myNumber.doubleValue
            }
            var newPlaceLat:Double = -1
            if let myNumber = NumberFormatter().number(from: (promptND.textFields?[6].text)!) {
                newPlaceLat = myNumber.doubleValue
            }
            var newPlaceLong:Double = -1
            if let myNumber = NumberFormatter().number(from: (promptND.textFields?[7].text)!) {
                newPlaceLong = myNumber.doubleValue
            }

            let place:Place = Place(name: newPlaceName, description: newPlaceDesc, category: newPlaceCat, address_title: newPlaceAddressTitle, address_street: newPlaceAddressStreet, elevation: newPlaceElev, latitude: newPlaceLat, longitude: newPlaceLong)
            let aConnect:PlaceCollectionStub = PlaceCollectionStub(urlString: self.urlString)
            let _:Bool = aConnect.add(place: place, callback: { _,_  in
                self.places.append(newPlaceName)
                self.places = Array(self.places).sorted()
                self.tableView.reloadData()
            })
        }))
        
        promptND.addTextField(configurationHandler: {(textField: UITextField!) in
            textField.placeholder = "Name"
        })
        promptND.addTextField(configurationHandler: {(textField: UITextField!) in
            textField.placeholder = "Description"
        })
        promptND.addTextField(configurationHandler: {(textField: UITextField!) in
            textField.placeholder = "Category"
        })
        promptND.addTextField(configurationHandler: {(textField: UITextField!) in
            textField.placeholder = "Address Title"
        })
        promptND.addTextField(configurationHandler: {(textField: UITextField!) in
            textField.placeholder = "Address Street"
        })
        promptND.addTextField(configurationHandler: {(textField: UITextField!) in
            textField.placeholder = "Elevation"
        })
        promptND.addTextField(configurationHandler: {(textField: UITextField!) in
            textField.placeholder = "Latitude"
        })
        promptND.addTextField(configurationHandler: {(textField: UITextField!) in
            textField.placeholder = "Longitude"
        })

        present(promptND, animated: true, completion: nil)
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.places.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceCell", for: indexPath)
        let nameParts = self.places[indexPath.row].split(separator: "-")
        let count = nameParts.count == 1 ? 1 : nameParts.count - 1
        cell.textLabel?.text = nameParts.prefix(count).joined(separator: " ")
        cell.detailTextLabel?.text = String(nameParts.last!)

        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PlaceDetail" {
            let viewController:ViewController = segue.destination as! ViewController
            let indexPath = self.tableView.indexPathForSelectedRow!
            viewController.places = self.places
            viewController.selectedPlace = self.places[indexPath.row]
        }
    }

}
