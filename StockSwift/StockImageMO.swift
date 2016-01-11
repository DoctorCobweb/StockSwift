//
//  StockImageMO.swift
//  StockSwift
//
//  Created by andre trosky on 11/01/2016.
//  Copyright © 2016 andre trosky. All rights reserved.
//

import UIKit
import CoreData
import Foundation

class StockImageMO: NSManagedObject {
    
    @NSManaged var invCode: Int
    @NSManaged var photo: NSData?
}
