//
//  customCellClass.swift
//  Fit Log
//
//  Created by King Christopher on 10/17/17.
//  Copyright © 2017 Fontana Technologies. All rights reserved.
//

import UIKit

class customCellClass: UITableViewCell {
    
    // this class handles the custom cell labels
    
    
    @IBOutlet var exTitle: UILabel!
    @IBOutlet var exInfo: UILabel!
   
    
    var title: String = ""{
        didSet{
            if(title != oldValue){
                exTitle.text = title
            }
        }
    }
    
    var info: String = ""{
        didSet{
            if(info != oldValue){
                exInfo.text = info
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
