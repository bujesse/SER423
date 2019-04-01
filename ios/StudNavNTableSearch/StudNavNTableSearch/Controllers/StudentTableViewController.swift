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
class StudentTableViewController : UITableViewController, UISearchResultsUpdating,
                                   UISearchBarDelegate {
    
    // students is a dictionary, key is name, value is Student object
    var students:[String:Student] = [String:Student]()
    // names and filtered are arrays of strings -- student names
    var names:[String] = [String]()
    var filtered:[String] = [String]()
    // allow searches by name and by course
    let scopeTitles:[String] = ["Name", "Course"]
    var selectedScopeIndex:Int = 0
    // create a search controller to display in this view (nil results cntrller)
    let searchController = UISearchController(searchResultsController: nil)
    
    @IBOutlet weak var studentTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //NSLog("viewDidLoad")
        
        self.title = "Student List"
        // add an edit button, which is handled by the func table view editing forRowAt
        self.navigationItem.leftBarButtonItem = self.editButtonItem
        // place an add button on the right side of the nav bar for adding a student
        // call addStudent function when clicked.
        let addButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(StudentTableViewController.addStudent))
        self.navigationItem.rightBarButtonItem = addButton
        
        // Setup the Search Controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search String"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        // Setup the Scope Bar
        searchController.searchBar.scopeButtonTitles = scopeTitles
        searchController.searchBar.delegate = self
        
        // setup the model
        let tim:Student = Student(jsonStr: "{\"name\":\"Tim Lindquist\",\"studentid\":50,\"takes\":[\"Ser423 Mobile Computing\",\"Cse494 Mobile Computing\"]}")
        self.students["Tim Lindquist"] = tim
        
        // construct the student dictionary from the json file containing students
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
        // names won't vary after this setting. filtered changes depending on search bar
        self.names = Array(students.keys).sorted()
        self.filtered = Array(students.keys).sorted()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        //print("search for content \(String(describing: searchController.searchBar.text))")
        self.filtered = self.filter(on: self.selectedScopeIndex, with: searchController.searchBar.text)
        self.tableView.reloadData()
    }

    // MARK: - UISearchBarDelegate
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        //print("search for content \(String(describing: searchController.searchBar.text)) scope index: \(String(describing: selectedScope)))")
        self.selectedScopeIndex = selectedScope
    }
    
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filter(on:Int, with:String?) -> [String] {
        var ret:[String] = [String]()
        //print("in filter. isActive \(searchController.isActive) isEmpty \(searchBarIsEmpty())")
        if searchController.isActive && !searchBarIsEmpty() {
            if on == 0 {
                ret = filterOnName(nameStr:with!)
            } else {
                ret = filterOnCourse(courseStr:with!)
            }
            ret = ret.sorted()
        } else {
            ret = names
        }
        return ret
    }
    
    func filterOnName(nameStr:String) -> [String] {
        var ret:[String] = [String]()
        for aName in names {
            if aName.lowercased().contains(nameStr.lowercased()) {
                ret.append(aName)
            }
        }
        return ret
    }

    func filterOnCourse(courseStr:String) -> [String] {
        var ret:[String] = [String]()
        for aName in names {
            let aStud:Student = students[aName]!
            for aCourse in aStud.takes {
                if aCourse.lowercased().contains(courseStr.lowercased()) {
                    if !ret.contains(aName) {
                        //print("adding \(aName) to list of students taking \(courseStr)")
                        ret.append(aName)
                    }
                }
            }
        }
        return ret
    }
    
    // called with the Navigation Bar Add button (+) is clicked
    @objc func addStudent() {
        print("add button clicked")
        //  query the user for the new student name and number. empty takes
        let promptND = UIAlertController(title: "New Student", message: "Enter Student Name & Number", preferredStyle: UIAlertControllerStyle.alert)
        // if the user cancels, we don't want to add a student
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
            self.filtered = Array(self.students.keys).sorted()
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
    // to the navigation item (in this case left side) explicitly. See: view did load
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        print("tableView editing row at: \(indexPath.row)")
        if editingStyle == .delete {
            let selectedStudent:String = names[indexPath.row]
            //print("deleting the student \(selectedStudent)")
            students.removeValue(forKey: selectedStudent)
            names = Array(students.keys).sorted()
            filtered = Array(students.keys).sorted()
            tableView.deleteRows(at: [indexPath], with: .fade)
            // don't need to reload data, using delete to make update
        }
    }
    
    // MARK: - Table view data source methods
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filtered.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Get and configure the cell...
        let cell = tableView.dequeueReusableCell(withIdentifier: "StudentCell", for: indexPath)
        let aStud = students[filtered[indexPath.row]]! as Student
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
            viewController.selectedStudent = self.filtered[indexPath.row]
        }
    }
    
}

