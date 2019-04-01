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
 * have student name and id number. From the table view you can add or remove students
 * using the edit of + buttons on the navigation bar.
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
class StudentTableViewController : UITableViewController {
    
    var students:[String:Student] = [String:Student]()
    var names:[String] = [String]()
    
    @IBOutlet weak var studentTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSLog("viewDidLoad")
        
        // add an edit button, which is handled by the table view editing forRowAt
        self.navigationItem.leftBarButtonItem = self.editButtonItem
        // place an add button on the right side of the nav bar for adding a student
        // call addStudent function when clicked.
        let addButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(StudentTableViewController.addStudent))
        self.navigationItem.rightBarButtonItem = addButton
        
        let tim:Student = Student(jsonStr: "{\"name\":\"Tim Lindquist\",\"studentid\":50,\"takes\":[\"Ser423 Mobile Computing\",\"Cse494 Mobile Computing\"]}")
        self.students["Tim Lindquist"] = tim
        
        if let path = Bundle.main.path(forResource: "students", ofType: "json"){
            do {
                let jsonStr:String = try String(contentsOfFile:path)
                let data:Data = jsonStr.data(using: String.Encoding.utf8)!
                let dict:[String:Any] = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! [String:Any]
                for aStudName:String in dict.keys {
                    let aStud:Student = Student(dict: dict[aStudName] as! [String:Any])
                    self.students[aStudName] = aStud
                }
            } catch {
                print("contents of students.json could not be loaded")
            }
        }
        // sort so the names are listed in the table alphabetically (first name)
        self.names = Array(students.keys).sorted()
        self.title = "Student List"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // called with the Navigation Bar Add button (+) is clicked
    func addStudent() {
        print("add student button clicked")
        
        //  query the user for the new student name and number. empty takes
        let promptND = UIAlertController(title: "New Student", message: "Enter Student Name & Number", preferredStyle: UIAlertControllerStyle.alert)
        // if the user cancels, we don't want to add a student so nil handler
        promptND.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: nil))
        // setup the OK action and provide a closure to be executed when/if OK selected
        promptND.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) -> Void in
            //print("you entered name: \(String(describing: promptND.textFields?[0].text)). Number: \(String(describing: promptND.textFields?[1].text)).")
            // Want to provide default values for name and studentid
            let newStudName:String = (promptND.textFields?[0].text == "") ?
                                    "unknown" : (promptND.textFields?[0].text)!
            // since didn't specify the keyboard, don't know whether id is empty, alpha, or numeric:
            var newStudID:Int = -1
            if let myNumber = NumberFormatter().number(from: (promptND.textFields?[1].text)!) {
                newStudID = myNumber.intValue
            }
            //print("creating and adding student \(newStudName) with id: \(newStudID)")
            let aStud:Student = Student(name: newStudName, id: newStudID)
            self.students[newStudName] = aStud
            self.names = Array(self.students.keys).sorted()
            self.tableView.reloadData()
        }))
        promptND.addTextField(configurationHandler: {(textField: UITextField!) in
            textField.placeholder = "Student Name"
        })
        promptND.addTextField(configurationHandler: {(textField: UITextField!) in
            textField.placeholder = "Student ID Number"
        })
        present(promptND, animated: true, completion: nil)
    }
    
    // Support editing of the table view. Note, edit button must have been added
    // to the navigationitem (in this case left side) explicitly (view did load)
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        print("tableView editing row at: \(indexPath.row)")
        if editingStyle == .delete {
            let selectedStudent:String = names[indexPath.row]
            print("deleting the student \(selectedStudent)")
            students.removeValue(forKey: selectedStudent)
            names = Array(students.keys)
            tableView.deleteRows(at: [indexPath], with: .fade)
            // don't need to reload data, using delete to make update
        }
    }
    
    // MARK: - Table view data source methods
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return names.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Get and configure the cell...
        let cell = tableView.dequeueReusableCell(withIdentifier: "StudentCell", for: indexPath)
        let aStud = students[names[indexPath.row]]! as Student
        cell.textLabel?.text = aStud.name
        cell.detailTextLabel?.text = "\(aStud.studentid)"
        return cell
    }
    
    // MARK: - Navigation
    // Storyboard seque: do any advance work before navigation, and/or pass data
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object (and model) to the new view controller.
        //NSLog("seque identifier is \(String(describing: segue.identifier))")
        if segue.identifier == "StudentDetail" {
            let viewController:ViewController = segue.destination as! ViewController
            let indexPath = self.tableView.indexPathForSelectedRow!
            viewController.students = self.students
            viewController.selectedStudent = self.names[indexPath.row]
        }
    }
    
}
