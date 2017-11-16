//
//  ViewController.swift
//  Fit Log
//
//  Created by King Christopher on 10/17/17.
//  Copyright © 2017 Fontana Technologies. All rights reserved.
//

import UIKit

// this viewController Populates the main screen, the first screen you see whne the app loads!
class ViewController: UIViewController, UITableViewDataSource,
UITableViewDelegate {
    
    
   // these arrays populate the table
    var todayEx:[String] = []
    var todayExInfo:[String] = []
    
    // this is the dictionary that stores the date and the array
    var todayExDict: [String : String] = [:]
    
    // for the plist
    let exerciseKey = "TodaysExercises"
    var todayExItemValue: String?
    
    // for getting the current date
    let date = Date()
    let formatter = DateFormatter()
    var currentDate = ""

    // these combine the two arrays
    var workoutNamesCombine = ""
    var workoutInfoCombine = ""
    var workoutNamesAndInfoCombine = ""
   
    
    
    // this is the table for the Main screen.
    @IBOutlet weak var todayExTable: UITableView!
    
    let cellTableIdentifier = "CustomCell"
    
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        todayExTable.register(CustomCell.self, forCellReuseIdentifier: cellTableIdentifier)
        
        let xib = UINib(nibName: "CustomTableCell", bundle: nil)
        todayExTable.register(xib, forCellReuseIdentifier: cellTableIdentifier)
        
        todayExTable.rowHeight = 75
        
        
        
       
        
        // for the date formatting
        // had to call it in here otherwise it wouldn't load
        formatter.dateFormat = "MM/dd/YYYY"
        currentDate = formatter.string(from: date)
        
        
        // reloads the table data when the view loads
        todayExTable.reloadData()
        
        // to prevent erasing whats stored this only loads the save function if something is in the
        // todayEx array. Which is the array that loads the table
        if(!todayEx.isEmpty){
        storeDictionary()
        }
        
        //loadData()
    }

    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    
    // this stores info in a dictionary based on the date
    func storeDictionary(){
        
        workoutNamesCombine = todayEx.joined(separator: ":")
        workoutInfoCombine = todayExInfo.joined(separator: "*")
        workoutNamesAndInfoCombine = workoutNamesCombine + "/" + workoutInfoCombine
        
        // if a key has the current date overwrite that key
        if(todayExDict.keys.contains(currentDate)){
            todayExDict[currentDate] = workoutNamesAndInfoCombine
            
            // if a key doesn't have the current date then add the key and new data
        }else{
            todayExDict[currentDate] = workoutNamesAndInfoCombine
        }
        
        saveData(value: todayExDict)
        print("View Did Load dict: ", todayExDict)
    }
    
    
    
    
    // this loads the data from the plist
    func loadData(){
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as NSArray
        
        let documentDirectory = paths[0] as! String
        let path = documentDirectory.appending("TodayExLog.plist")
        let fileManager = FileManager.default
        if(!fileManager.fileExists(atPath: path)){
            if let bundlePath = Bundle.main.path(forResource: "TodayExLog", ofType: "plist"){
                let result = NSMutableDictionary(contentsOfFile: bundlePath)
                print("Bundle File ExerciseLog.plist is -> \(result?.description)")
                do{
                    try fileManager.copyItem(atPath: bundlePath, toPath: path)
                }catch{
                    print("copy failure.")
                }
            }else{
                print("file TodayExLog.plist not found.")
            }
        }else{
            print("file TodayExLog.plist already exits at path")
        }
        
        let resultDictionary = NSMutableDictionary(contentsOfFile: path)
        //print("load TodayExLog.plist is -> \(resultDictionary?.description)")
        
        let myDict = NSDictionary(contentsOfFile: path)
        
        if let dict = myDict{
            todayExDict = dict.object(forKey: exerciseKey) as! [String : String]
            
            
            // attempt to parse the dictionary
            workoutNamesAndInfoCombine = todayExDict[currentDate]!
            
            print("workoutNamesAndInfoComing: ", workoutNamesAndInfoCombine)
            
            var parseDictionaryArray:[String] = []
            parseDictionaryArray = workoutNamesCombine.components(separatedBy: "/")
            workoutNamesCombine = parseDictionaryArray[0]
            
            if(2 <= parseDictionaryArray.count){
                workoutInfoCombine = parseDictionaryArray[1]
            }else{
            workoutInfoCombine = ""
            }
            //print(exSelectVariable)
            // this parses the string into the array to load the data in the table
            todayEx = workoutNamesCombine.components(separatedBy: ":")
            todayExInfo = workoutInfoCombine.components(separatedBy: "*")
            
            //print("Workout Names: ",workoutNamesCombine)
            //print("workout Info: ", workoutInfoCombine)
            //print("todayExInfo array: ",todayExInfo)
            print("")
           // print("load Data function dict: ", todayExDict)
            
            print("the load data function just loaded")
        }else{
            print("load failure.")
        }
    }
    


    
    // this saves the data for the array into the dictionary
    func saveData(value: [String : String]){
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as NSArray
        let documentDirectory = paths.object(at: 0) as! String
        
        let path = documentDirectory.appending("TodayExLog.plist")
        
        let dict: NSMutableDictionary = [:]
        
        dict.setObject(value, forKey: exerciseKey as NSCopying)
        dict.write(toFile: path, atomically: false)
        print("saved.")
        
        print("The save data function just saved")
    }
    

    
    
    
    //MARK:-
    //MARK: TableView Data Source Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int)-> Int{
        return todayEx.count
    }
    
    // this populates the table
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)-> UITableViewCell{
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellTableIdentifier, for: indexPath) as! CustomCell
        
        
        /*// not sure if I need this
        var cell = tableView.dequeueReusableCell(withIdentifier: "SimpleTableIdentifier")
        
        
        // this checks to see if it the cell is nil and takes care of optional problem
        if(cell == nil){
            cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "SimpleTableIdentifier")
        }
        
        // this loads the table with the array after the = sign
        cell?.textLabel?.text = todayEx[indexPath.row]
        */
        //print(exercises[indexPath.row])
        
        
        //****************************************************************************************
        // title is the variable from the CustomCell class
        // .title refers to the title cell in custom class
        cell.title = todayEx[indexPath.row]
        
        // if the count of array todayExInfo is greater than the index row number
        //then the info is 0
        if(todayExInfo.count > indexPath.row){
            cell.info = todayExInfo[indexPath.row]
        }else{
            cell.exerciseInfo.text = ""
        }
       // print(currentDate)
        return cell
    }
    
    
    
    
    
    /*
     ************* this lets you click the cell and go to the view****** when I get this working I'll uncomment it if needed*******
    // this is the segue for clicking on a cell. When you click on a cell it loads the next view controller that will allow you to edit the sets reps and weights
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath as IndexPath)
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        
        selectedRow = indexPath.row
        while(selectedRow > indexPath.row){
            exerciseInfo.append([])
        }
        performSegue(withIdentifier: "toEditController", sender: cell)
    }
    */
    
    
    //prepare for segue
    // this checks the segue identifier and performs the segue and sends the information to the view controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if(segue.identifier == "exCreateNameSegue"){
            let nextViewController = segue.destination as! ExerciseSelectionScreen
            
            nextViewController.viewControllerExName = todayEx
        }
        
        /*if (segue.identifier == "toEditController"){
            let viewController2 = segue.destination as! editExerciseDetails
            viewController2.selectedRow = selectedRow
            viewController2.storeExercises = todaysExercises
            if(exerciseInfo.count > selectedRow){
                viewController2.storeInfo = exerciseInfo[selectedRow]
            }
 */
        }
    }




