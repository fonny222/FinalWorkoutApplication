//
//  ExerciseSelectionScreen.swift
//  Fit Log
//
//  Created by King Christopher on 11/1/17.
//  Copyright © 2017 Fontana Technologies. All rights reserved.
//

import UIKit
import CoreData

class ExerciseSelectionScreen: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    
    // this is a global var to be used to store the value of the cell you click on in the table
    var valueToPass:String!
    var exInfoFromSelectionScreen = ""
    
    // for getting the current date
    let date = Date()
    let calendar = Calendar.current
    let formatter = DateFormatter()
    var currentDate = ""
    var timeStamp = ""

    
    //array to load data into table
    var exSelection:[String] = []
    
    // this array holds data from the previous view controller
    var viewControllerExName:[String] = []
    
    // use this to parse the string variable from the plist
    var exSelectVariable = ""
    
    // this is the outlet for the tableview
    @IBOutlet weak var exSelectionTable: UITableView!
    
    // initialize core data for save and load****
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadData()
        
        // for the date formatting
        // had to call it in here otherwise it wouldn't load
        formatter.dateFormat = "MM/dd/YYYY"
        currentDate = formatter.string(from: date)
        let hours = calendar.component(.hour, from: date)
        let minutes = calendar.component(.minute, from: date)
        let seconds = calendar.component(.second, from: date)
        print("\(hours), \(minutes), \(seconds)")
        var timeCombine = (((hours * 60) * 60) + (minutes * 60) + seconds)
        
        timeStamp = "\(timeCombine)"
    }
    
    
    // this removes the text entry and has a pop up to add an exercise to the list
    @IBAction func addExercise(_ sender: Any) {
        
        let alert = UIAlertController(title: "New Exercise!", message: "Add a New Exercise: ", preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .default) {
            [unowned self] action in
            guard let textField = alert.textFields?.first,
                let exToSave = textField.text else {
                    return
            }
            
            // adds exercise saved to array that populates list
            // appends the array that feeds the tableview
            self.exSelection.append(exToSave)
            self.saveData(exerciseValue: exToSave)
            self.exSelectionTable.reloadData()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default)
        alert.addTextField()
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    
    
  
 
 
    // this function creates a context of the entity then creates the object and stores a version of that object
    func saveData(exerciseValue: String){
        //Core Data*********
        let context = appDelegate.persistentContainer.viewContext
        // create a new object of the entity ExerciseList Core DAta*******
        let newExercise = NSEntityDescription.insertNewObject(forEntityName: "ExerciseList", into: context)
        newExercise.setValue(exerciseValue.self, forKey: "name")
        
        do {
            try context.save()
        } catch {
            print("saveData could not be saved \(error)")
        }
    }
    
    
    // this save function will save the name of the exercise we create to the Daily Workout Entity
    func saveExNameData(exNames: String, exInfos: String){
    //Core Data*********
    let context = appDelegate.persistentContainer.viewContext
    // create a new object of the entity ExerciseList Core DAta*******
    let newDailyEx = NSEntityDescription.insertNewObject(forEntityName: "DailyWorkout", into: context)
    
    do {
    newDailyEx.setValue(exNames.self, forKey: "exercisename")
    newDailyEx.setValue(exInfos.self, forKey: "exerciseinfo")
    newDailyEx.setValue(currentDate, forKey: "date")
    newDailyEx.setValue(timeStamp, forKey: "timestamp")
    
    try context.save()
    print("Saved Exercise Name and Info and Date")
    } catch {
    print("saveExNameData could not be saved\(error)")
    }
    }
    
    
    // this calls context then a fetch request for the entity
    // then it looks for the entity by username or whatever the attribute you select.
    func loadData(){
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "ExerciseList")
        request.returnsObjectsAsFaults = false
        
        do{
            let results = try context.fetch(request)
        if(results.count > 0){
            for result in results as! [NSManagedObject]{
                if let exName = result.value(forKey: "name") as? String{
                    
                   exSelection.append(exName)
                }
            }
        }

    }
    catch{
    print("Could not load data in Exercise Selection Screen\(error)")
    }
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
        
        return cell!
    }
    
    
    
    // this grabs the string that was at the index path you select in the table
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        valueToPass = exSelection[indexPath.row]
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath){
        
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "ExerciseList")
        request.predicate = NSPredicate(format: "name == %@", exSelection[indexPath.row])
        
        let result = try? context.fetch(request)
        let resultData = result as! [ExerciseList]
        
        for object in resultData {
            context.delete(object)
        }
        exSelection.remove(at: indexPath.row)
        do {
            try context.save()
            print("saved! after delte Exercise Selection Screen")
        } catch let error as NSError  {
            print("Could not save after Delete \(error), \(error.userInfo)")
        }
        
        self.exSelectionTable.deleteRows(at: [indexPath], with: .fade)
    }
    
    
    
    @IBAction func addToRootView(_ sender: UIButton) {
    
        if(valueToPass == nil){
            let title = "No Selection Made!"
            let alert = UIAlertController(title: title, message: "Please Select an Exercise", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
        }else{
            
            saveExNameData(exNames: valueToPass, exInfos: exInfoFromSelectionScreen)
            
            // this works to pop back to original
            navigationController?.popToRootViewController(animated: true)
        }
        
    }
}


