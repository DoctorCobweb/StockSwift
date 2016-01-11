//
//  StockTake.swift
//  StockSwift
//
//  Created by andre trosky on 11/01/2016.
//  Copyright © 2016 andre trosky. All rights reserved.
//

import UIKit
import CoreData

class Stocktake: NSObject {
    
    // MARK: Properties
    var stocktake: [Int: [Float]]
    var stocktakeMetaData: [String:String]
    
    init(metaData:[String:String]) {
    
        self.stocktake = [:]
        self.stocktakeMetaData = metaData
    }
    
    
    func createFinalStocktake() {
    
        //here you want to add all zero amout items to stocktake dict because we want
        //to save a complete stocktake 'scene'. as so when user revisits/reloads a
        //previous stocktake, it looks exactly like it was when they left it.
        //previouse stocktakes keep a snapshot of the all current item prices as they
        //were when the stocktake was done. this is done to avoid problems in the future
        //when the current item prices list changes and doesn't match up to the old 
        //stocktake item prices. e.g. the new stock list items have some items deleted, 
        //and a previous stocktake has some of those deleted stocks => when reloading
        //previous stocktake there's no information on those items. bummer.
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let moc = appDelegate.managedObjectContext
        
        
        //we only want to return the invCode field
        let itemsFetch = NSFetchRequest(entityName: "CurrentItemPriceEntity")
        itemsFetch.propertiesToFetch = ["invCode"]
        
        do {
            let fetchedCurrentItemsInvCode = try moc.executeFetchRequest(itemsFetch) as! [CurrentItemPriceMO]
            
            if !fetchedCurrentItemsInvCode.isEmpty {
                let allInvCodesList = fetchedCurrentItemsInvCode.reduce([], combine: {(run, item) in
                    run + [item.invCode]
                })
                
                let allInvCodesSet =  Set(allInvCodesList)
                let nonZeroStockItemsSet = Set(stocktake.keys)
                let actualZeroItemsSet = allInvCodesSet.subtract(nonZeroStockItemsSet)
                let yadda = Array(actualZeroItemsSet).sort({(i1: Int, i2:Int) -> Bool in
                    return i1 < i2
                })
                
                print(nonZeroStockItemsSet)
                print("\n\n\n------------\n\n\n")
                print(yadda)
                
                //this is how you do type inference
                //let blahMirror = Mirror(reflecting: allInvCodesList)
                //String.self == blahMirror.subjectType etc
                //print(blahMirror.subjectType)
            }
        }
        catch let error as NSError {
            fatalError("FAILURE to save context: \(error)")
        }
        
        
        //save the stocktake meta details first
        let metaData = NSEntityDescription.insertNewObjectForEntityForName("StocktakeMetaDataEntity", inManagedObjectContext: moc) as! StocktakeMetaDataMO
        metaData.personName = stocktakeMetaData["person_name"]!
        metaData.department = stocktakeMetaData["department"]!
        metaData.startDate = stocktakeMetaData["start_date"]!
        
        do {
            try moc.save()
            print("SUCCESS: save stocktakeMetaData to persistent store")
        }
        catch let error as NSError {
            fatalError("FAILURE to save context: \(error)")
        }
    }
}
