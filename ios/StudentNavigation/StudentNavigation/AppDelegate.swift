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
 *
 * Ser423 Mobile Applications
 * see http://pooh.poly.asu.edu/Mobile
 * @author Tim Lindquist Tim.Lindquist@asu.edu
 *         Software Engineering, CIDSE, IAFSE, ASU Poly
 * @version February 2017
 */
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

