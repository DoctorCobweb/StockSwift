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
    var section: String
    
    
    
    // should this be an failable initializer??
    init(photo: UIImage?,
        description: String,
        invCode: Int,
        lastCost: Float,
        units: String,
        section: String) {
        
        self.photo = photo
        self.description = description
        self.invCode = invCode
        self.lastCost = lastCost
        self.units = units
        self.section = section
    }
}