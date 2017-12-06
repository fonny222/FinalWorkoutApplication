//
//  ExerciseInfoController.swift
//  Fit Log
//
//  Created by King Christopher on 11/17/17.
//  Copyright © 2017 Fontana Technologies. All rights reserved.
//

import UIKit
import CoreData

class ExerciseInfoController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    

    // populates the tableview
    var editExInfo = [String]()
     var selectedExInfo = ""
    
    var repsWeightCombine = ""
    var exInfoArrayCombine = ""
    
    // from first view controller to here
    var selectedExName = ""
    var selectedExDate = ""
    var selectedExTime = ""
    
    // initialize core data for save and load****
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    // text field outlets
    
    @IBOutlet weak var setReps: UITextField!
    @IBOutlet weak var setWeight: UITextField!
    
    @IBOutlet weak var exInfoTable: UITableView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadData()
        
        // this is how to set the tile
        // the back button is set in the previous view controller
        self.navigationItem.title = selectedExName
    }

    
    
    
    @IBAction func addInfo(_ sender: UIButton) {
        
        var reps = setReps.text
        var weight = setWeight.text
        
        if(reps == ""){
            let title = "Required Info:"
            let alert = UIAlertController(title: title, message: "Please Input Reps", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
        }else{
            if(weight == ""){
                repsWeightCombine = ("\(reps!) x 0 lbs")
                
                editExInfo.append(repsWeightCombine)
            }else{
        repsWeightCombine = ("\(reps!) x \(weight!) lbs")
            
                editExInfo.append(repsWeightCombine)
            }
        }
        
        exInfoTable.reloadData()
        
        // resignfirstResponder makes keyboard go away
        setReps.resignFirstResponder()
        setWeight.resignFirstResponder()
        
        setReps.text = ""
        setWeight.text = ""
    }
    
    
    
    
    @IBAction func saveConfirm(_ sender: UIButton) {
        
        exInfoArrayCombine = editExInfo.joined(separator: "\n")
        
        // this calls the specific predicated entity/attribute
        // then changes its value and resaves the context
        do{
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "DailyWorkout")
            
            let predicateDate = NSPredicate(format: "date == %@", selectedExDate)
            let predicateName = NSPredicate(format: "exercisename == %@", selectedExName)
            let predicateTime = NSPredicate(format: "timestamp ==%@", selectedExTime)
            let multiPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicateDate, predicateName, predicateTime])
            
            request.predicate = multiPredicate
            
            let results = try context.fetch(request)
            if (results.count > 0){
                for result in results as! [NSManagedObject]{
                    if let exerciseInfo = result.value(forKey: "exerciseinfo") as? String{
                        result.setValue(exInfoArrayCombine, forKey: "exerciseinfo")
                        do{
                            try context.save()
                        }catch{
                            print("Could not save in do/ catch saveConfirm function: \(error)")
                        }
                    }
                }
            }
        }catch{
            print("Could not save outer do/catch function saveConfirm\(error)")
        }
        
        print(exInfoArrayCombine)
        navigationController?.popToRootViewController(animated: true)
    }
    
    
    func loadData(){
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "DailyWorkout")
        
        // this is to query using multipile search terms..
        let predicateDate = NSPredicate(format: "date == %@", selectedExDate)
        let predicateName = NSPredicate(format: "exercisename == %@", selectedExName)
        let predicateTime = NSPredicate(format: "timestamp ==%@", selectedExTime)
        let multiPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicateDate, predicateName, predicateTime] )
        
        request.predicate = multiPredicate
        
        do{
            let results = try context.fetch(request)
            
            if(results.count > 0 ){
                for result in results as! [NSManagedObject]{
                    if let exerciseInformation = result.value(forKey: "exerciseinfo") as? String{
                        if(exerciseInformation != ""){
                        editExInfo = exerciseInformation.components(separatedBy: "\n")
                        }else{
                            print("There is a blank entry in start of array")
                        }
                    }
                }
            }
        }catch{
            print("Could not loadDAta exercise info controller \(error)")
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return editExInfo.count
    }

    

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        var cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier")
        
        if(cell == nil){
            cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "reuseIdentifier")
        }
        // Configure the cell...
        cell?.textLabel?.text = editExInfo[indexPath.row]

        return cell!
    }


    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath){
        
        // remove from index path of array and table
        editExInfo.remove(at: indexPath.row)
        self.exInfoTable.deleteRows(at: [indexPath], with: .fade)
        
        // if you hit save it will apply the changes to the core data when it leaves the view
    }

}
