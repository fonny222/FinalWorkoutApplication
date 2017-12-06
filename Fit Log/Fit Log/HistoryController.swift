//
//  HistoryController.swift
//  Fit Log
//
//  Created by King Christopher on 12/5/17.
//  Copyright © 2017 Fontana Technologies. All rights reserved.
//

import UIKit
import CoreData


class HistoryController: UIViewController, UITableViewDataSource, UITableViewDelegate {
   
    //populate the table
    var historyExercise:[String] = []
    var historyExInfo:[String] = []
    
    // date to get
    var historyDate = ""
    
    //initialize core data
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    let cellTableIdentifier = "CustomCell"
    
    // tableview outlet
    @IBOutlet weak var historyTable: UITableView!
    
    // picker outlet
    @IBOutlet weak var pickADate: UIDatePicker!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        // this sets the maximum date to whatever the current date is in the picker
        pickADate.maximumDate = Date()
        
        // for the custom cells
        historyTable.register(CustomCell.self, forCellReuseIdentifier: cellTableIdentifier)
        let xib = UINib(nibName: "CustomTableCell", bundle: nil)
        historyTable.register(xib, forCellReuseIdentifier: cellTableIdentifier)
        
        // for the dynamically changing cells
        historyTable.estimatedRowHeight = 44.0
        historyTable.rowHeight = UITableViewAutomaticDimension
        
        // loads data on start
        loadData()
    }
   
    
    
    @IBAction func dateChanged(_ sender: UIDatePicker) {
        print("print \(sender.date)")
        
        historyExercise.removeAll()
        historyExInfo.removeAll()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/YYYY"
        historyDate = dateFormatter.string(from: sender.date)
        loadData()
        
        historyTable.reloadData()
        print(historyDate)  // "historyDate" is your string date
        print()
        print(historyExercise)
        print(historyExInfo)
        print()
    }
    
    
    
    func loadData(){
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "DailyWorkout")
        request.predicate = NSPredicate(format: "date == %@", historyDate)
        
        do{
            let results = try context.fetch(request)
            if(results.count > 0){
                for result in results as! [NSManagedObject]{
                    if let exerciseName = result.value(forKey: "exercisename") as? String{
                        historyExercise.append(exerciseName)
                    }
                    if let exerciseInfo = result.value(forKey: "exerciseinfo") as? String{
                        historyExInfo.append(exerciseInfo)
                    }
                }
            }
        }catch{
            print("failed to load data in history table: \(error)")
        }
    }
    

    
    //MARK: -- Table Data Source Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int)-> Int{
        return historyExercise.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let cell = tableView.dequeueReusableCell(withIdentifier: cellTableIdentifier, for: indexPath) as! CustomCell
        
        cell.title = historyExercise[indexPath.row]
        
        if(historyExInfo.count > indexPath.row){
            cell.info = historyExInfo[indexPath.row]
        }else{
            cell.exerciseInfo.text = ""
        }
        
        return cell
    }
    

}
