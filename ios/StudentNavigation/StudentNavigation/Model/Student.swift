import UIKit

/*
 * Copyright 2017 Tim Lindquist,
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * Purpose: Navigation Controller based app using Student class as sample model.
 * Students have name, id, and an array of courses they take. Launch page
 * includes a table view in which rows (using table view cell style of subtitle).
 * Selecting a student takes you to a view that allows editing the courses taken.
 * Points to read and understand in this example:
 * 1. Building a Navigation Controller (nav bar at top) based app from a single view start
 * 2. Adding classes to an iOS app and associating them with storyboard scenes
 * 3. Adding built-in table view editing through the nav bar. Handling editing events to
 *    properly modify the underlying model and table. (tableView property for UITableView)
 * 4. Adding a button to the nav bar (here its an Add button (+) for adding a new student.
 * 5. Programmatic wire-up of button to a method to handle actions.
 * 6. Using an Alert Controller to query the user (or notify the user). In this case, to
 *    prompt the user to enter student name and id number.
 * 7. Using prepare for segue to pass data to another scene's view controller
 *    And, returning data back to the originating scene using the nav contoller delegate
 *    method: navigationController willShow viewController. (see ViewController class)
 * 8. Manually creating a UITableView as one among other components of a scene's view.
 * 9. DataSources and Delegates (Nav Controller, TableView, and Picker)
 *10. UITableView with single (1) prototype cell. Table View Cell
 *    whose style is custom (and custom identifier for reuse purposes). Dragging
 *    components into the prototype cell, creating IBOutlets for them in the custom
 *    tableviewcell class (CourseTableViewCell), and as an example exposing those
 *    outlets using Swift properties (not necessary).
 *11. Reading a data file from the app bundle and using it to initialize a model object.
 *
 * Ser423 Mobile Applications
 * see http://pooh.poly.asu.edu/Mobile
 * @author Tim Lindquist Tim.Lindquist@asu.edu
 *         Software Engineering, CIDSE, IAFSE, ASU Poly
 * @version February 2017
 */
public class Student {
    public var name: String
    public var studentid: Int
    public var takes: Array<String>
    
    public init(name: String, id: Int){
        self.name = name
        self.studentid = id
        takes = [String]()
    }
    
    public init (jsonStr: String){
        self.name = ""
        self.studentid=0
        self.takes = [String]()
        if let data: NSData = jsonStr.data(using: String.Encoding.utf8) as NSData?{
            do{
                let dict = try JSONSerialization.jsonObject(with: data as Data,options:.mutableContainers) as?[String:AnyObject]
                self.name = (dict!["name"] as? String)!
                self.studentid = (dict!["studentid"] as? Int)!
                self.takes = (dict!["takes"] as? Array<String>)!
            } catch {
                print("unable to convert Json to a dictionary")
                
            }
        }
    }
    
    public init(dict:[String:Any]){
        self.name = dict["name"] == nil ? "unknown" : dict["name"] as! String
        self.studentid = dict["studentid"] == nil ? 0 : dict["studentid"] as! Int
        self.takes = [String]()
        let takesArr:[String] = dict["takes"] == nil ? [String]() : dict["takes"] as! [String]
        for aCrs:String in takesArr {
            self.takes.append(aCrs)
        }
    }
    
    public func toJsonString() -> String {
        var jsonStr = "";
        let dict:[String : Any] = ["name": name, "studentid": studentid, "takes":takes] as [String : Any]
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dict, options: JSONSerialization.WritingOptions.prettyPrinted)
            // here "jsonData" is the dictionary encoded in JSON data
            jsonStr = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)! as String
        } catch let error as NSError {
            print("unable to convert dictionary to a Json Object with error: \(error)")
        }
        return jsonStr
    }
}
