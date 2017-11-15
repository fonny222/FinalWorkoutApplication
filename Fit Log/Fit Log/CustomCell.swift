//
//  CustomCell.swift
//  Fit Log
//
//  Created by King Christopher on 11/7/17.
//  Copyright © 2017 Fontana Technologies. All rights reserved.
//

import UIKit

class CustomCell: UITableViewCell {
    
    // outlets for the title and info labels
    @IBOutlet var exerciseTitle: UILabel!
    @IBOutlet var exerciseInfo: UILabel!
    
    
    
    var title: String = ""{
        didSet{
            
            if(title != oldValue){
                exerciseTitle.text = title
            }
        }
    }
    
    var info: String = ""{
        didSet{
            if(info != oldValue){
                exerciseInfo.text = info
            }
        }
    }
    
}
