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
            if(weight == nil){
                repsWeightCombine = ("\(reps!) Reps")
                
                editExInfo.append(repsWeightCombine)
            }else{
        repsWeightCombine = ("\(reps!) X \(weight!) lbs")
            
                editExInfo.append(repsWeightCombine)
            }
        }
        
        exInfoTable.reloadData()
        
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
                            print(error)
                        }
                    }
                }
            }
        }catch{
            print(error)
        }
        
        
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
            print(error)
        }
        
    }
    
    
    

    // MARK: - Table view data source**********************************
    // delegate methods
/*
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }
*/
    
    
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


    
    
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
