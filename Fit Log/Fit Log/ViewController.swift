//
//  ViewController.swift
//  Fit Log
//
//  Created by King Christopher on 10/17/17.
//  Copyright © 2017 Fontana Technologies. All rights reserved.
//

import UIKit
import CoreData

// this viewController Populates the main screen, the first screen you see whne the app loads!
class ViewController: UIViewController, UITableViewDataSource,
UITableViewDelegate {
    
    var test = ""
    
   // these arrays populate the table
    var todayEx:[String] = []
    var todayExInfo:[String] = []
    var todayExDate:[String] = []
    var todayExTime:[String] = []
    
    // this is for the tableView delegate/source methods
    var selectedRow = -1
    
    // for getting the current date
    let date = Date()
    let calendar = Calendar.current
    let formatter = DateFormatter()
    var currentDate = ""
    
    // initialize core data for save and load****
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
   
    
    
    // this is the table for the Main screen.
    @IBOutlet weak var todayExTable: UITableView!
    
    let cellTableIdentifier = "CustomCell"
    
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        todayExTable.register(CustomCell.self, forCellReuseIdentifier: cellTableIdentifier)
        
        let xib = UINib(nibName: "CustomTableCell", bundle: nil)
        todayExTable.register(xib, forCellReuseIdentifier: cellTableIdentifier)
        
        // this is just the code to set the height whatever you want
       // todayExTable.rowHeight = 75
        
        // Along with auto layout, these are the keys for enabling variable cell height
        // in the custom cell after setting auto layout constraints you MUST set "lines" to 0 this allows dynamic cell change
        todayExTable.estimatedRowHeight = 44.0
        todayExTable.rowHeight = UITableViewAutomaticDimension
        
        // for the date formatting
        // had to call it in here otherwise it wouldn't load
        formatter.dateFormat = "MM/dd/YYYY"
        currentDate = formatter.string(from: date)
 
    }

   /// this will reload the table data each time the view appears
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // clear arrays to load data
        todayEx.removeAll()
        todayExInfo.removeAll()
        todayExDate.removeAll()
        todayExTime.removeAll()
        
        loadData()
        todayExTable.reloadData()
        
    }
    
    
    func loadData(){
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "DailyWorkout")
        //request.returnsObjectsAsFaults = false
        
        // predicate searches for a specific attribute. date is the attribute name
        // currenDate is the varibale that predicate is uses to compare a search
        request.predicate = NSPredicate(format: "date == %@", currentDate)
        
        do{
            let results = try context.fetch(request)
            if(results.count > 0){
                for result in results as! [NSManagedObject]{
                    if let exerciseName = result.value(forKey: "exercisename") as? String{
                        todayEx.append(exerciseName)
                    }
                    if let exerciseInfo = result.value(forKey: "exerciseinfo") as? String{
                        todayExInfo.append(exerciseInfo)
                    }
                    if let date = result.value(forKey: "date") as? String{
                        todayExDate.append(date)
                    }
                    if let exTimeStamp = result.value(forKey: "timestamp") as? String{
                        todayExTime.append(exTimeStamp)
                    }
                }
            }
        }catch{
            print(error)
        }
    }
    
    
    //MARK:-
    //MARK: TableView Data Source Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int)-> Int{
        return todayEx.count
    }
    
    // this populates the table
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)-> UITableViewCell{
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellTableIdentifier, for: indexPath) as! CustomCell
        
        
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
        
        /*
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 75
 */
        return cell
    }
    

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath){
        
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "DailyWorkout")
        
        let predicateName = NSPredicate(format: "exercisename ==%@", todayEx[indexPath.row])
        let predicateTime = NSPredicate(format: "timestamp ==%@", todayExTime[indexPath.row])
        let multiPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicateName, predicateTime] )
        
        request.predicate = multiPredicate
        
        let result = try? context.fetch(request)
        let resultData = result as! [DailyWorkout]
        
        for object in resultData {
            context.delete(object)
        }
        todayEx.remove(at: indexPath.row)
        todayExInfo.remove(at: indexPath.row)
        todayExDate.remove(at: indexPath.row)
        todayExTime.remove(at: indexPath.row)
        do {
            try context.save()
            print("saved! after delete from initial view")
        } catch let error as NSError  {
            print("Could not save after Delete from Initial View \(error), \(error.userInfo)")
        }
        
        self.todayExTable.deleteRows(at: [indexPath], with: .fade)
    }
    
    
    
    
    
    
    // this is the segue for clicking on a cell. When you click on a cell it loads the next view controller that will allow you to edit the sets reps and weights
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath as IndexPath)
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        
        // gets the row index of what you selected
        selectedRow = indexPath.row
       
        performSegue(withIdentifier: "toExerciseInfoSegue", sender: cell)
    }
 
    
    //prepare for segue
    // this checks the segue identifier and performs the segue and sends the information to the view controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if(segue.identifier == "exCreateNameSegue"){
            let nextViewController = segue.destination as! ExerciseSelectionScreen
            
            // Since Core Data Works I don't really need this.
            nextViewController.viewControllerExName = todayEx
        }
        
        if (segue.identifier == "toExerciseInfoSegue"){
            let editInfoViewController = segue.destination as! ExerciseInfoController
            
            var exerciseNameToSend = todayEx[selectedRow]
            var exerciseDateToSend = todayExDate[selectedRow]
            var exerciseTimeToSend = todayExTime[selectedRow]
            
            
            editInfoViewController.selectedExName = exerciseNameToSend
            editInfoViewController.selectedExDate = exerciseDateToSend
            editInfoViewController.selectedExTime = exerciseTimeToSend
            
        }
    }
}

