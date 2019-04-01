/*
 * Copyright 2018 Tim Lindquist,
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
 * Purpose: Example Swift Client for a Java student collection JsonRPC server.
 *
 * Ser423 Mobile Applications
 * see http://pooh.poly.asu.edu/Mobile
 * @author Tim Lindquist Tim.Lindquist@asu.edu
 *         Software Engineering, CIDSE, IAFSE, ASU Poly
 * @version January 2018
 */

import Foundation

public class Student {
    open var name: String
    open var studentid: Int
    open var takes:[String]=[String]()
    
    init (jsonStr: String){
        self.name = ""
        self.studentid=0
        if let data: Data = jsonStr.data(using: String.Encoding.utf8){
            do{
                let dict = try JSONSerialization.jsonObject(with: data,options:.mutableContainers) as?[String:AnyObject]
                self.name = (dict!["name"] as? String)!
                self.studentid = (dict!["studentid"] as? Int)!
                self.takes = (dict!["takes"] as? [String])!
            } catch {
                print("unable to convert to dictionary")
                
            }
        }
    }
    
    init(dict: [String:Any]){
        self.name = dict["name"] as! String
        self.studentid = dict["studentid"] as! Int
        self.takes = dict["takes"] as! [String]
    }
    
    func toJsonString() -> String {
        var jsonStr = "";
        let dict = ["name": name, "studentid": studentid, "takes":takes] as [String : Any]
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dict, options: JSONSerialization.WritingOptions.prettyPrinted)
            // here "jsonData" is the dictionary encoded in JSON data
            jsonStr = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)! as String
        } catch let error as NSError {
            print(error)
        }
        return jsonStr
    }

    func toDict() -> [String:Any] {
        let dict:[String:Any] = ["name": name, "studentid": studentid, "takes":takes] as [String : Any]
        return dict
    }
}
