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
class ViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate,
                                        UITableViewDelegate, UITableViewDataSource,
                                        UINavigationControllerDelegate {

    var students:[String:Student] = [String:Student]()
    var selectedStudent:String = "unknown"
    var courses:[String] = [String]()
    var selectedCourse:String = ""
    var takes:[String] = [String]()
    var selectedTakesStr:String = ""
    var selectedTakesIndex:Int = -1
    
    @IBOutlet weak var courseTableView: UITableView!
    @IBOutlet weak var studIdLab: UILabel!
    @IBOutlet weak var coursesTF: UITextField!
    @IBOutlet weak var coursesPicker: UIPickerView!
    @IBOutlet weak var addButt: UIButton!
    @IBOutlet weak var removeButt: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //NSLog("in ViewController.viewDidLoad with: \(selectedStudent)")
        courseTableView.delegate = self
        courseTableView.dataSource = self
 
        
        // round the buttons
        addButt.layer.cornerRadius = 15
        removeButt.layer.cornerRadius = 15
        
        //optional unwrapping with ? first below displays an optional value, which must be unwrapped.
        // ? is optional unwrapping whereas ! is forced unwrapping. Only use ! when you know
        // unwrapping will not result in nil value. Otherwise use if-let
        //studIdLab.text = "\(students[selectedStudent]?.studentid)"
        // Below works OK, but without using a guard (if) to protect against nil
        //studIdLab.text = NSString(format:"%i",(students[selectedStudent]?.studentid)!) as String
        // see also the if-let construction, as example in AlertView OK of StudentTableViewController
        
        studIdLab.text = "\(students[selectedStudent]!.studentid)"
        self.title = students[selectedStudent]?.name
        
        courses = ["Cse110 Programming I",
                   "Cse340 Language Design",
                   "Cse445 Distributed Software",
                   "Cse494 Mobile Computing",
                   "Ser315 SE Design",
                   "Ser316 SE Construction",
                   "Ser321 Distributed Apps",
                   "Ser401 SE Project",
                   "Ser421 Web",
                   "Ser423 Mobile Computing"]
        courses = courses.sorted()
        takes = students[selectedStudent]!.takes.sorted()
        
        // setup a picker for selecting a course to be added for this student.
        coursesPicker.delegate = self
        coursesPicker.removeFromSuperview()
        coursesTF.inputView = coursesPicker
        // of course count is greater than 0. All courses must have space after pre/num
        selectedCourse =  (courses.count > 0) ? courses[0] : "unknown unknown"
        let crs:[String] = selectedCourse.components(separatedBy: " ")
        coursesTF.text = crs[0]

        // so we can return a modified student
        self.navigationController?.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func addButtonClicked(_ sender: Any) {
        // add the selected course to the students takes
        //print("Adding course \(selectedCourse) to takes for \(selectedStudent)")
        if !(students[selectedStudent]?.takes.contains(selectedCourse))!{
            students[selectedStudent]?.takes.append(selectedCourse)
            takes = (students[selectedStudent]?.takes)!
            takes = takes.sorted()
            courseTableView.reloadData()
        }
    }
    
    @IBAction func removeButtClicked(_ sender: Any) {
        // remove the selected course from the student takes
        //print("Removing course \(selectedCourse) to takes for \(selectedStudent)")
        if (students[selectedStudent]?.takes.contains(selectedCourse))!{
            let index:Int = (students[selectedStudent]?.takes.index(of: selectedCourse))!
            students[selectedStudent]?.takes.remove(at: index)
            takes = (students[selectedStudent]?.takes)!
            takes = takes.sorted()
            courseTableView.reloadData()
        }
    }
    
    // touch events on this view
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.coursesTF.resignFirstResponder()
    }
    
    // MARK: -- UITextFieldDelegate Method
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.coursesTF.resignFirstResponder()
        return true
    }
    
    // MARK: -- UIPickerVeiwDelegate method
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedCourse = courses[row]
        let tokens:[String] = selectedCourse.components(separatedBy: " ")
        self.coursesTF.text = tokens[0]
        self.coursesTF.resignFirstResponder()
    }
    
    // UIPickerViewDelegate method
    func pickerView (_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let crs:String = courses[row]
        let tokens:[String] = crs.components(separatedBy: " ")
        return tokens[0]
    }
    
    // MARK: -- UIPickerviewDataSource method
    func numberOfComponentsInPickerView(_ pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // UIPickerviewDataSource method
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return courses.count
    }
    
    // MARK: -- UITableViewDataSource methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
   
    // UITableViewDataSource method
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return takes.count
    }
    
    // UITableViewDataSource method
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //print("in tableView cellForRowAt, row: \(indexPath.row)")
        let cell = tableView.dequeueReusableCell(withIdentifier: "CourseCell", for: indexPath) as! CourseTableViewCell
        let crsSegs:[String] = takes[indexPath.row].components(separatedBy: " ")
        cell.courseNum = crsSegs[0]
        var titleStr:String = ""
        for i:Int in 1 ..< crsSegs.count {
            titleStr.append("\(crsSegs[i]) ")
        }
        cell.courseTitle = titleStr
        return cell
    }
    
    //tableview delegate (UITableViewDelegate method
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print("tableView didSelectRowAT \(indexPath.row)")
        selectedTakesStr = ((students[selectedStudent])?.takes[indexPath.row])!
        selectedTakesIndex = indexPath.row
    }
    
    // If self is a navigation controller delegate (see above in view did load)
    // then this method will be called after the Nav Conroller back button click, but
    // before returning to the previous view. This provides an opportunity to update
    // that view's data with any changes from this view. This approach is
    // accepted practice for sending data back after a segue with nav controller.
    // Here this is only important to be sure the same courses persist coming back here.
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool){
        //print("entered navigationController willShow viewController")
        if let controller = viewController as? StudentTableViewController {
            // pass back the students dictionary with potentially modified takes.
            controller.students = self.students
            // don't need to reload data. Students don't change here, but it can be done
            controller.tableView.reloadData()
        }
    }
    
}

