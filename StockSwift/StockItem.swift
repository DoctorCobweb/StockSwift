//
//  StockItem.swift
//  StockSwift
//
//  Created by andre trosky on 27/12/2015.
//  Copyright © 2015 andre trosky. All rights reserved.
//

import UIKit

class StockItem {
    
    // MARK: Properties
    var photo: UIImage?
    var description: String
    var invCode: Int
    var lastCost: Float
    var units: String
    var physicalAmount: Float?
    var moneyAmount: Float?
    
    
    
    // should this be an failable initializer??
    init(photo: UIImage?,
        description: String,
        invCode: Int,
        lastCost: Float,
        units: String,
        physicalAmount: Float?,
        moneyAmount: Float?) {
        
        self.photo = photo
        self.description = description
        self.invCode = invCode
        self.lastCost = lastCost
        self.units = units
        self.physicalAmount = physicalAmount
        self.moneyAmount = moneyAmount
        
            
        
    }
}