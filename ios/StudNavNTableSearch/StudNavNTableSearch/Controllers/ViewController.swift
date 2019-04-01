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
class ViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource,
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
        
        // round the buttons
        addButt.layer.cornerRadius = 15
        removeButt.layer.cornerRadius = 15

        // Do any additional setup after loading the view, typically from a nib.
        NSLog("in ViewController.viewDidLoad with: \(selectedStudent)")
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
        takes = students[selectedStudent]!.takes
        takes = takes.sorted()
        
        // setup delegate and data source for table view
        courseTableView.delegate = self
        courseTableView.dataSource = self
        
        // setup a picker for selecting a course to be added for this student.
        coursesPicker.delegate = self
        coursesPicker.dataSource = self
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
    
    @IBAction func addButtClicked(_ sender: Any) {
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
        //print("titleForRow \(row) is \(tokens[0]) course is \(courses[row])")
        return tokens[0]
    }
    
    // MARK: -- UIPickerviewDataSource method
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
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
        print("tableView didSelectRowAT \(indexPath.row)")
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
        print("entered navigationController willShow viewController")
        if let controller = viewController as? StudentTableViewController {
            // pass back the students dictionary with potentially modified takes.
            controller.students = self.students
            // don't need to reload data. Students don't change here, but it can be done
            controller.tableView.reloadData()
        }
    }
}

