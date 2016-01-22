//
//  StocktakeItemMO.swift
//  StockSwift
//
//  Created by andre trosky on 11/01/2016.
//  Copyright © 2016 andre trosky. All rights reserved.
//

import UIKit
import CoreData
import Foundation

class StocktakeItemMO: NSManagedObject {
    
    @NSManaged var invCode: Int
    @NSManaged var itemDescription: String
    @NSManaged var lastCost: Float
    @NSManaged var section: String
    @NSManaged var sectionOriginal: String
    @NSManaged var units: String
    @NSManaged var physicalAmount: Float
    
    //for the to-one relationship of a particular stock item to a
    //specific stocktake
    @NSManaged var singularStocktake:StocktakeMetaDataMO
    

}
