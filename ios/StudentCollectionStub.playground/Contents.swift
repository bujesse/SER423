/*
* Copyright 2019 Tim Lindquist,
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
* Purpose: Example Swift playground to demonstrate a client stub class
* for the Java JsonRPC student collection server.
 * This playground contains two classes. The First is a Student 
*
* Ser423 Mobile Applications
* see http://pooh.poly.asu.edu/Mobile
* @author Tim Lindquist Tim.Lindquist@asu.edu
*         Software Engineering, CIDSE, IAFSE, ASU Poly
* @version Februsary 2019
*/

import UIKit
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true
URLCache.shared = URLCache(memoryCapacity: 0, diskCapacity: 0, diskPath: nil)

var str = "Hello, playground"

public class Student {
    public var name: String
    public var studentid: Int
    public var takes:[String]=[String]()
    
    init(name:String){
        self.name = name
        self.studentid = 0
        self.takes = [String]()
    }
    
    init (jsonStr: String){
        self.name = ""
        self.studentid=0
        if let data: Data = jsonStr.data(using: String.Encoding.utf8) as Data?{
            do{
                let dict = try JSONSerialization.jsonObject(with: data as Data,options:.mutableContainers) as?[String:Any]
                self.name = (dict!["name"] as? String)!
                self.studentid = (dict!["studentid"] as? Int)!
                self.takes = (dict!["takes"] as? [String])!
            } catch {
                print("unable to convert to dictionary")
                
            }
        }
    }
    
    init(dict:[String:Any]){
        self.name = dict["name"] as! String
        self.studentid = dict["studentid"] as! Int
        self.takes = dict["takes"] as! [String]
    }
    
    func toJsonString() -> String {
        var jsonStr = "";
        let dict:[String:Any] = ["name": name, "studentid": studentid, "takes": takes] as [String : Any]
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dict, options: JSONSerialization.WritingOptions.prettyPrinted)
            // here "jsonData" is the dictionary encoded in JSON data
            jsonStr = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)! as String
        } catch let error as NSError {
            print(error)
        }
        return jsonStr
    }
    
    func toString() -> String {
        return "\(name) is a student with id \(studentid) who takes \(takes.joined(separator: ", "))"
    }
}

// sample use of student class

let studTim = Student(jsonStr: "{\"name\":\"Tim\", \"studentid\":629, \"takes\":[\"Ser423\",\"Ser321\",\"Cse445\"]}")
print("Tim from json then converted back to json string is: \(studTim.toJsonString())")

let timDict:[String:Any] = ["name":"Tim", "studentid":629, "takes":["Ser423","Ser321","Cse445"]]
let studTimToo = Student(dict: timDict)
print("TimToo from Dictionary as json string \(studTimToo.toJsonString())")

// We can literal the dictionary as an argument to the Student init method
let studTimThree = Student(dict: ["name":"Tim", "studentid":629, "takes":["Ser423","Ser321","Cse445"]])
print("TimThree from Dictionary as json string \(studTimThree.toJsonString())")


// OK, thats how the Student class works. Now lets create a Proxy for the Java JsonRPC StudentCollection Server
public class StudentCollectionStub {
    
    static var id:Int = 0
    
    var url:String
    
    init(urlString: String){
        self.url = urlString
    }
    
    // used by methods below to send a request asynchronously.
    // creates and posts a URLRequest that attaches a JSONRPC request as a Data object. The URL session
    // executes in the background and calls its completion handler when the result is available.
    func asyncHttpPostJSON(url: String,  data: Data,
                           completion: @escaping (String, String?) -> Void) {
        
        let request = NSMutableURLRequest(url: NSURL(string: url)! as URL)
        request.httpMethod = "POST"
        request.addValue("application/json",forHTTPHeaderField: "Content-Type")
        request.addValue("application/json",forHTTPHeaderField: "Accept")
        request.httpBody = data as Data
        //HTTPsendRequest(request: request, callback: completion)
        // task.resume() below, causes the shared session http request to be posted in the background
        // (independent of the UI Thread)
        // the use of the DispatchQueue.main.async causes the callback to occur on the main queue --
        // where the UI can be altered, and it occurs after the result of the post is received.
        let task:URLSessionDataTask = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {
            (data, response, error) -> Void in
            if (error != nil) {
                completion("", error!.localizedDescription)
            } else {
                DispatchQueue.main.async(execute: {completion(NSString(data: data!,
                                                                       encoding: String.Encoding.utf8.rawValue)! as String, nil)})
            }
        })
        task.resume()
    }
    
    func get(name: String, callback:@escaping (String, String?) -> Void) -> Bool{
        var ret:Bool = false
        StudentCollectionStub.id = StudentCollectionStub.id + 1
        do {
            let dict:[String:Any] = ["jsonrpc":"2.0", "method":"get", "params":[name], "id":StudentCollectionStub.id]
            let reqData:Data = try JSONSerialization.data(withJSONObject: dict, options: JSONSerialization.WritingOptions(rawValue: 0))
            self.asyncHttpPostJSON(url:self.url, data:reqData, completion:callback)
            ret = true
        } catch let error as NSError {
            print(error)
        }
        return ret
    }
    
    func getNames(callback:@escaping(String, String?) -> Void) -> Bool{
        var ret:Bool = false
        StudentCollectionStub.id = StudentCollectionStub.id + 1
        do {
            let dict:[String:Any] = ["jsonrpc":"2.0", "method":"getNames", "params":[ ], "id":StudentCollectionStub.id]
            let reqData:Data = try JSONSerialization.data(withJSONObject:dict, options:JSONSerialization.WritingOptions(rawValue:0))
            self.asyncHttpPostJSON(url:self.url, data:reqData, completion:callback)
            ret = true
        } catch let error as NSError {
            print(error)
        }
        return ret
    }

    // callbacks to getNames remote method may use this method to get the array of strings from the jsonrpc result string
    func getStringArrayResult(jsonRPCResult:String) -> [String] {
        var ret:[String] = [String]()
        if let data:NSData = jsonRPCResult.data(using:String.Encoding.utf8) as NSData?{
            do{
                let dict = try JSONSerialization.jsonObject(with: data as Data,options:.mutableContainers) as?[String:AnyObject]
                let resArr:[String] = dict?["result"] as! [String]
                ret = resArr
            } catch {
                print("unable to convert Json to a dictionary")
            }
        }
        return ret
    }
    
    // callbacks to get remote method may use this method to get the student from the jsonrpc result string
    func getStudentResult(jsonRPCResult:String) -> Student {
        var ret:Student = Student(name: "Un Known")
        if let data:NSData = jsonRPCResult.data(using:String.Encoding.utf8) as NSData?{
            do{
                let dict = try JSONSerialization.jsonObject(with: data as Data,options:.mutableContainers) as?[String:AnyObject]
                let aStud:Student = Student(dict:dict?["result"] as! [String:Any])
                ret = aStud
            } catch {
                print("unable to convert Json to a dictionary")
            }
        }
        return ret
    }

}

// Now the method calls have callbacks included with them. So, lets look at sample uses of these classes
let aStud:Student = Student(jsonStr: "{\"name\":\"Tim Lindquist\", \"studentid\":629, \"takes\":[\"Ser423\",\"Ser321\",\"Cse445\"]}")
print("Student: \(aStud.toJsonString())")

// the ip 127.0.0.1 is the simplest form for localhost. This is the ip and port of the student collection server.
let aConnect:StudentCollectionStub = StudentCollectionStub(urlString: "http://127.0.0.1:8080")
let resGetNames:Bool = aConnect.getNames(callback: { (res: String, err: String?) -> Void in
    if err != nil {
        print("Error: \(String(describing: err))")
    }else{
        // no error, then the result, is a jsonrpc response with the value of result being an array of student names.
        print("jsonrpc response to getNames is: \(res)")
        let names:[String] = aConnect.getStringArrayResult(jsonRPCResult: res)
        print("registered students are:")
        for aName in names {
            print("   \(aName)")
        }
    }
})

let resGet:Bool = aConnect.get(name: "Sally Smith", callback: { (res: String, err: String?) -> Void in
    if err != nil {
        print("Error: \(String(describing: err))")
    }else{
        // this result should be a Json Object whose result property is a Json Object representing
        // the student Sally Smith.
        print("jsonrpc response to get Sally Smith: \(res)")
        let sally:Student = aConnect.getStudentResult(jsonRPCResult:res)
        print("Sally found on server as: \(sally.toString())")
    }
})



