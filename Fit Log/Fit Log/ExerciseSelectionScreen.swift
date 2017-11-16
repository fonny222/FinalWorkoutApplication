//
//  ExerciseSelectionScreen.swift
//  Fit Log
//
//  Created by King Christopher on 11/1/17.
//  Copyright © 2017 Fontana Technologies. All rights reserved.
//

import UIKit

class ExerciseSelectionScreen: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    // writing to the plist
    let exerciseKey = "ExerciseSelector"
    var exItemValue: String?
    
    
    
    // this is a global var to be used to store the value of the cell you click on in the table
    var valueToPass:String!
    
    //array to load data into table
    var exSelection:[String] = []
    
    // this array holds data from the previous view controller
    var viewControllerExName:[String] = []
    
    // use this to parse the string variable from the plist
    var exSelectVariable = ""
    
    
    // this is the text field to create new exercises
    @IBOutlet weak var exerciseCreation: UITextField!
    
    // this is the outlet for the tableview
    @IBOutlet weak var exSelectionTable: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // this is for return removes keyboard
        self.exerciseCreation.delegate = self
        
        // this runs the loadData plist function
        loadData()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    
    
    // this loads the data from the plist
    func loadData(){
    let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as NSArray
        
        let documentDirectory = paths[0] as! String
        let path = documentDirectory.appending("ExerciseLog.plist")
        let fileManager = FileManager.default
        if(!fileManager.fileExists(atPath: path)){
            if let bundlePath = Bundle.main.path(forResource: "ExerciseLog", ofType: "plist"){
                let result = NSMutableDictionary(contentsOfFile: bundlePath)
                print("Bundle File ExerciseLog.plist is -> \(result?.description)")
                do{
                    try fileManager.copyItem(atPath: bundlePath, toPath: path)
                }catch{
                    print("copy failure.")
                }
            }else{
                print("file ExerciseLog.plist not found.")
            }
        }else{
            print("file ExerciseLog.plist already exits at path")
        }
        
        let resultDictionary = NSMutableDictionary(contentsOfFile: path)
        //print("load ExerciseLog.plist is -> \(resultDictionary?.description)")
        
        let myDict = NSDictionary(contentsOfFile: path)
        
        if let dict = myDict{
            
            exItemValue = dict.object(forKey: exerciseKey) as! String
            
            exSelectVariable = exItemValue!
            
            //print(exSelectVariable)
            // this parses the string into the array to load the data in the table
            exSelection = exSelectVariable.components(separatedBy: ":")
            
            print("The loadData() function in ExerciseSelection view just loaded")
        }else{
            print("load failure.")
        }
    }
    
    
// this saves the data for the array into the dictionary
    func saveData(value:String){
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as NSArray
        let documentDirectory = paths.object(at: 0) as! String
        
        let path = documentDirectory.appending("ExerciseLog.plist")
        
        let dict: NSMutableDictionary = [:]
        
        dict.setObject(value, forKey: exerciseKey as NSCopying)
        dict.write(toFile: path, atomically: false)
        print("saved.")
        print("saved data function in exercise selection class just loaded")
    }
    
    
    
    
    
    
    
    
    
    // this function makes the keyboard go away when you press return key
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        // takes variable from text field when you hit return
        var exTextField = exerciseCreation.text
      
        
        // appends the array that feeds the tableview
        exSelection.append(exTextField!)
        
        exSelectVariable = exSelection.joined(separator: ":")
        saveData(value: exSelectVariable)
        
        //print(exSelectVariable)
        
        // this reloads the table with the new data
        exSelectionTable.reloadData()
        
        exerciseCreation.resignFirstResponder()
        
            return true
        
    }
    
    
    
    // tableview delegates
    // this fills the table/sets the rows and columns based on the exSelection array size
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return exSelection.count
    }
    
    // this fills the table with whats in the array
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // not sure if I need this...
        var cell = tableView.dequeueReusableCell(withIdentifier: "SimpleTableIdentifier")
        
        // this checks to see if it the cell is nil and takes care of optional problem
        if(cell == nil){
            cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "SimpleTableIdentifier")
        }
        
        // this loads the table with the array after the '=' sign
        cell?.textLabel?.text = exSelection[indexPath.row]
        
        //print(exercises[indexPath.row])
        
        return cell!
    }
    
    
    
    // this grabs the string that was at the index path you select in the table
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        valueToPass = exSelection[indexPath.row]
        
        print("\(valueToPass)")
    }
    
    
    // this takes the segue that sends you back to the home screen and sends the data
    //from the cell you picked along with it.
    override func prepare(for segue: UIStoryboardSegue, sender: Any!){
        if(segue.identifier == "exSelectToHomeSegue"){
            let viewController = segue.destination as! ViewController
            
            if(valueToPass == nil){
                let title = "No Selection Made!"
                let alert = UIAlertController(title: title, message: "Please Select an Exercise", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(action)
                present(alert, animated: true, completion: nil)
            }else{
                print("\(valueToPass)")
                viewControllerExName.append(valueToPass)
                viewController.todayEx = viewControllerExName
            }
            
        }
    }
    
    
}
