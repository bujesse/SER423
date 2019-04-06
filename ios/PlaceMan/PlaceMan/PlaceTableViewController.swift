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
        
        self.setURL()
        self.getPlaces()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

         self.navigationItem.rightBarButtonItem = self.editButtonItem
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
