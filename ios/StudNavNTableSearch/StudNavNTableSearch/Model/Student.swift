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
 * Purpose: Builds on the Navigation and Table View Controller based app for
 * Manipulating Student information and courses taken. This app adds the ability
 * to search the data displayed in the table view doing a string match with one of
 * two search categories: Student Name, or Course prefix and title.
 * Students have name, id, and an array of courses they take. Launch page
 * includes a table view in which rows (using table view cell style of subtitle)
 * have student name and id number. From the table view you can add or remove students
 * using the edit of + buttons on the navigation bar.
 * Selecting a student takes you to a view that allows editing the courses taken.
 *
 * Points to read and understand in this example:
 * 1. In StudentTableViewController, see class extension or implementation of protocols
 *    for search results updating and search bar delegate.
 * 2. Definition, initialization, and binding of the search and scope bars in the
 *    view did load method.
 * 3. Addition of delegate methods: updateSearchResults and searchBar selectedScopeButton
 *    to properly modify signal search. As well as private functions: searchBarIsEmpty,
 *    filter, filterOnName, and filterOnCourse. These return an array of strings which is
 *    the model for the tableview. Note the model changes in data source methods.
 *
 * Ser423 Mobile Applications
 * see http://pooh.poly.asu.edu/Mobile
 * @author Tim Lindquist Tim.Lindquist@asu.edu
 *         Software Engineering, CIDSE, IAFSE, ASU Poly
 * @version November 2017
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

