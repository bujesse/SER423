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

import UIKit

class ViewController: UIViewController, UIPickerViewDelegate, UITextFieldDelegate{

    @IBOutlet weak var studLabel: UILabel!
    @IBOutlet weak var studentNumTF: UITextField!
    @IBOutlet weak var takesTF: UITextField!
    @IBOutlet weak var studSelectTF: UITextField!
    @IBOutlet weak var takesPicker: UIPickerView!
    @IBOutlet weak var studentPicker: UIPickerView!
    
    var selectedStudent:String=""
    var selectedCourse:String=""
    var students:[String]=[String]()
    var takes: [String] = [String]()
    
    var urlString:String = "http://127.0.0.1:8080"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.studentNumTF.keyboardType = UIKeyboardType.numberPad
        self.studentNumTF.delegate = self
        
        self.studentPicker.removeFromSuperview()
        self.studentPicker.delegate = self
        self.studSelectTF.inputView = self.studentPicker
        
        self.takesPicker.removeFromSuperview()
        self.takesPicker.delegate = self
        self.takesTF.inputView = self.takesPicker

        self.urlString = self.setURL()
        self.callGetNamesNUpdateStudentsPicker()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setURL () -> String {
        var serverhost:String = "localhost"
        var jsonrpcport:String = "8080"
        var serverprotocol:String = "http"
        // access and log all of the app settings from the settings bundle resource
        if let path = Bundle.main.path(forResource: "ServerInfo", ofType: "plist"){
            // defaults
            if let dict = NSDictionary(contentsOfFile: path) as? [String:AnyObject] {
                serverhost = (dict["server_host"] as? String)!
                jsonrpcport = (dict["jsonrpc_port"] as? String)!
                serverprotocol = (dict["server_protocol"] as? String)!
            }
        }
        print("setURL returning: \(serverprotocol)://\(serverhost):\(jsonrpcport)")
        return "\(serverprotocol)://\(serverhost):\(jsonrpcport)"
    }
    
    func callGetNamesNUpdateStudentsPicker() {
        let aConnect:StudentCollectionStub = StudentCollectionStub(urlString: urlString)
        let _:Bool = aConnect.getNames(callback: { (res: String, err: String?) -> Void in
            if err != nil {
                NSLog(err!)
            }else{
                NSLog(res)
                if let data: Data = res.data(using: String.Encoding.utf8){
                    do{
                        let dict = try JSONSerialization.jsonObject(with: data,options:.mutableContainers) as?[String:AnyObject]
                        self.students = (dict!["result"] as? [String])!
                        self.students = Array(self.students).sorted()
                        self.studSelectTF.text = ((self.students.count>0) ? self.students[0] : "")
                        self.studentPicker.reloadAllComponents()
                        if self.students.count > 0 {
                            self.callGetNPopulatUIFields(self.students[0])
                        }
                    } catch {
                        print("unable to convert to dictionary")
                    }
                }
                
            }
        })  // end of method call to getNames
    }
    
    func callGetNPopulatUIFields(_ name: String){
        let aConnect:StudentCollectionStub = StudentCollectionStub(urlString: urlString)
        let _:Bool = aConnect.get(name: name, callback: { (res: String, err: String?) -> Void in
            if err != nil {
                NSLog(err!)
            }else{
                NSLog(res)
                if let data: Data = res.data(using: String.Encoding.utf8){
                    do{
                        let dict = try JSONSerialization.jsonObject(with: data,options:.mutableContainers) as?[String:AnyObject]
                        let aDict:[String:AnyObject] = (dict!["result"] as? [String:AnyObject])!
                        let aStud:Student = Student(dict: aDict)
                        self.studentNumTF.text = "\(aStud.studentid)"
                        self.studLabel.text = aStud.name
                        self.takes = Array(aStud.takes).sorted()
                        self.takesTF.text = ((self.takes.count > 0) ? self.takes[0] : "")
                        self.takesPicker.reloadAllComponents()
                    } catch {
                        NSLog("unable to convert to dictionary")
                    }
                }
            }
    })
    }

    
    @IBAction func dropCourseClicked(_ sender: Any) {
        if self.takes.contains(takesTF.text!) {
            self.takes.remove(at: self.takes.index(of: takesTF.text!)!)
        }
        let aStud:Student = Student(dict:["name": studLabel.text!, "studentid": Int(studentNumTF.text!)!, "takes":takes])
        let aConnect:StudentCollectionStub = StudentCollectionStub(urlString: urlString)
        let _:Bool = aConnect.add(student: aStud,callback: { _ in
            print("\(aStud.name) added as: \(aStud.toJsonString())")
            self.callGetNPopulatUIFields(self.studLabel.text!)})
    }
    
    @IBAction func addCourseClicked(_ sender: Any) {
        let promptND = UIAlertController(title: "New Course Name", message: "Enter Course to be Added To \(String(describing: self.studLabel.text!))'s Schedule", preferredStyle: UIAlertControllerStyle.alert)
        // if the user cancels, we don't want to add an annotation or pin
        promptND.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: nil))
        // setup the OK action and the closure to be executed when/if OK selected
        promptND.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) -> Void in
            //print("you entered title: \(promptND.textFields?[0].text)")
            let newCrsName = (promptND.textFields?[0].text)!
            if !self.takes.contains(newCrsName) {
                self.takesTF.text = newCrsName
                self.takes.append(newCrsName)
                let aStud:Student = Student(dict:["name": self.studLabel.text!, "studentid": Int(self.studentNumTF.text!)!, "takes":self.takes])
                let aConnect:StudentCollectionStub = StudentCollectionStub(urlString: self.urlString)
                let _:Bool = aConnect.add(student: aStud,callback: { _ in
                    print("\(aStud.name) added as: \(aStud.toJsonString())")
                    self.callGetNPopulatUIFields(self.studLabel.text!)})
            }
        }))
        promptND.addTextField(configurationHandler: {(textField: UITextField!) in textField.placeholder = "SerXXX"})
        present(promptND, animated: true, completion: nil)
    }
  
    @IBAction func removeStudentClicked(_ sender: Any) {
        let aConnect:StudentCollectionStub = StudentCollectionStub(urlString: urlString)
        let _:Bool = aConnect.remove(studentName: studLabel.text!,callback: { _ in
            self.callGetNamesNUpdateStudentsPicker()
            })
    }
    
    @IBAction func addStudentClicked(_ sender: Any) {
        let promptND = UIAlertController(title: "New Student Name", message: "Enter First and Last Name of a New Student", preferredStyle: UIAlertControllerStyle.alert)
        // if the user cancels, we don't want to add an annotation or pin
        promptND.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: nil))
        // setup the OK action and the closure to be executed when/if OK selected
        promptND.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) -> Void in
            //print("you entered title: \(promptND.textFields?[0].text)")
            let newStudName = (promptND.textFields?[0].text)!
            if !self.students.contains(newStudName) {
                let aStud:Student = Student(dict:["name":newStudName, "studentid":Int(self.studentNumTF.text!)!, "takes":self.takes])
                let aConnect:StudentCollectionStub = StudentCollectionStub(urlString: self.urlString)
                let _:Bool = aConnect.add(student: aStud,callback: { _ in
                    print("\(aStud.name) added as: \(aStud.toJsonString())")
                    self.callGetNamesNUpdateStudentsPicker()})
            }
        }))
        promptND.addTextField(configurationHandler: {(textField: UITextField!) in textField.placeholder = "SerXXX"})
        present(promptND, animated: true, completion: nil)
        let studName:String = self.studSelectTF.text!
        let aStud:Student = Student(dict:["name": studName, "studentid": Int(studentNumTF.text!)!, "takes":takes])
        let aConnect:StudentCollectionStub = StudentCollectionStub(urlString: urlString)
        let _:Bool = aConnect.add(student: aStud,callback: { _ in
            self.students.append(studName)
            self.studentPicker.reloadAllComponents()
            self.callGetNPopulatUIFields(studName)
            })
    }
    
    // touch events on this view
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.studentNumTF.resignFirstResponder()
        self.studSelectTF.resignFirstResponder()
        self.takesTF.resignFirstResponder()
    }

    // UITextFieldDelegate Method
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.studentNumTF.resignFirstResponder()
        self.studSelectTF.resignFirstResponder()
        return true
    }

    // MARK: -- UIPickerVeiwDelegate methods
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == takesPicker {
            self.selectedCourse = takes[row]
            self.takesTF.text = self.selectedCourse
            self.takesTF.resignFirstResponder()
            
        } else {
            self.selectedStudent = students[row]
            self.studSelectTF.text = self.selectedStudent
            self.studSelectTF.resignFirstResponder()
            self.callGetNPopulatUIFields(self.selectedStudent)
        }
    }
    
    func numberOfComponentsInPickerView(_ pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return ((pickerView == takesPicker) ? takes.count : students.count)
    }
    
    func pickerView (_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return ((pickerView == takesPicker) ? takes[row] : students[row])
    }
    
}

