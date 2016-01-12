//
//  StocktakeMetaDataMO.swift
//  StockSwift
//
//  Created by andre trosky on 11/01/2016.
//  Copyright © 2016 andre trosky. All rights reserved.
//

import UIKit
import CoreData
import Foundation

class StocktakeMetaDataMO: NSManagedObject {
    @NSManaged var personName: String
    @NSManaged var department: String
    @NSManaged var startDate: String
    
    //for the to-many relationship of a stocktake (represented by the
    //metaData) to the many stock items
    @NSManaged var stocktakeItems: NSSet
}
