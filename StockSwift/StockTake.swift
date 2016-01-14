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
    var stocktake: [Int: [Float]] = [:]
    var stocktakeMetaData: [String:String]
    let moc: NSManagedObjectContext
    
    init(metaData:[String:String]) {
    
        //in swift, all properties of the subclass must be 
        //initialized before calling super.
        stocktakeMetaData = metaData
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        moc = appDelegate.managedObjectContext
        
        //let's initialize the stocktake dict with all the stock items with invCodes
        super.init()
        
        
        //this has to go below the call to super.init() because
        //super initializes self
        //
        setupStocktakeDict()
    }
    
    
    func setupStocktakeDict() {
        
        //save the stocktake meta details first
        let metaData = NSEntityDescription.insertNewObjectForEntityForName("StocktakeMetaDataEntity", inManagedObjectContext: self.moc) as! StocktakeMetaDataMO
        metaData.personName = stocktakeMetaData["person_name"]!
        metaData.department = stocktakeMetaData["department"]!
        metaData.startDate = stocktakeMetaData["start_date"]!
        
        //fetch all CurrentItemPriceMO items
        let itemsFetch = NSFetchRequest(entityName: "CurrentItemPriceEntity")
        
        do {
            let fetchedItems = try self.moc.executeFetchRequest(itemsFetch) as! [CurrentItemPriceMO]
            
            if !fetchedItems.isEmpty {
                
                addItemsToCoreData(fetchedItems, metaData: metaData)
                
                //now persist the new stocktake = meta data + all items with zero amounts
                persistData("make new stocktake = metaData + all items with zero amount")
            }
        }
        catch let error as NSError {
            fatalError("FAILURE to save context: \(error)")
        }
    }
    
    
    func addItemsToCoreData(cItems: [CurrentItemPriceMO], metaData: StocktakeMetaDataMO) {
        
        var _items: Set<StocktakeItemMO> = []
        
        for cItem in cItems {
            let _item = NSEntityDescription.insertNewObjectForEntityForName("StocktakeItemEntity", inManagedObjectContext: self.moc) as! StocktakeItemMO
            
            _item.invCode = cItem.invCode
            _item.itemDescription = cItem.itemDescription
            _item.lastCost = cItem.lastCost
            _item.section = cItem.section
            _item.units = cItem.units
            _item.physicalAmount = 0
            
            //set the to-one relationship for a stock item to have a meta data entitiy
            _item.singularStocktake = metaData
            
            _items.insert(_item)
            
        
            //also setup the in memory stocktake dict for this item
            stocktake[cItem.invCode] = []
        }
        
        //set the to-many relationship for meta data to have many stock take items
        metaData.stocktakeItems = _items
    }
    
    
    func persistData(action: String) {
        do {
            try self.moc.save()
            print("SUCCESS: save to persistent store, action: \(action)")
        }
        catch let error as NSError {
            fatalError("FAILURE to save context: \(error)")
        }
    }
    
    
    func getSingularStockItem(invCode: Int) -> StocktakeItemMO? {
        
        let itemFetch = NSFetchRequest(entityName: "StocktakeItemEntity")
        
        //item has to be for this stocktake!!! so we match on singularStocktake prop
        let formatString = "invCode == %d AND singularStocktake.personName == %@ AND singularStocktake.department == %@ AND singularStocktake.startDate == %@"
        
        itemFetch.predicate = NSPredicate(format:formatString,
            invCode ,stocktakeMetaData["person_name"]!, stocktakeMetaData["department"]!, stocktakeMetaData["start_date"]!)
    
        do {
            let fetchedItems = try self.moc.executeFetchRequest(itemFetch)
            
            if !fetchedItems.isEmpty && fetchedItems.count == 1 {
                return fetchedItems[0] as? StocktakeItemMO
            }
            else {
                return nil
            }
        }
        catch let error as NSError {
            fatalError("FAILURE to save context: \(error)")
        }
    }
    
    
    func getStockItemPhoto(invCode: Int) -> UIImage? {
        let photoFetch = NSFetchRequest(entityName: "StockImageEntity")
        photoFetch.predicate = NSPredicate(format: "invCode == %d", invCode)
        
        do {
            let fetchedPhotos = try moc.executeFetchRequest(photoFetch) as! [StockImageMO]
            
            if !fetchedPhotos.isEmpty && fetchedPhotos.count == 1 {
                return UIImage(data: fetchedPhotos[0].photo!)
            }
            else {
                return nil
            }
        }
        catch let error as NSError {
            fatalError("FAILURE to save context: \(error)")
        }
    }
    
    
    func updateStockItem(invCode: Int, amount: Float) {
    
        let item = getSingularStockItem(invCode)
        item?.physicalAmount += amount
        persistData("updateStockItem")
    }
    
    
    
    //TODO: properly flesh this stuff out...think about use cases of finishing a stocktake
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
        
        
        //we only want the invCode field returned from db
        let itemsFetch = NSFetchRequest(entityName: "CurrentItemPriceEntity")
        itemsFetch.propertiesToFetch = ["invCode"]
        
        do {
            let fetchedCurrentItemsInvCode = try self.moc.executeFetchRequest(itemsFetch) as! [CurrentItemPriceMO]
            
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
        let metaData = NSEntityDescription.insertNewObjectForEntityForName("StocktakeMetaDataEntity", inManagedObjectContext: self.moc) as! StocktakeMetaDataMO
        metaData.personName = stocktakeMetaData["person_name"]!
        metaData.department = stocktakeMetaData["department"]!
        metaData.startDate = stocktakeMetaData["start_date"]!
        
        
        
        //need to:
        //1. create a StockTakeItemMO instance for all items
        //2. add to metaData managed object property (as a set)
        //for the to-many relationship
        
        //lets create a dummy StocktakeItemMO object and
        //add it the the stocktakeItems set.
        let dummyStockItem = NSEntityDescription.insertNewObjectForEntityForName("StocktakeItemEntity", inManagedObjectContext: self.moc) as! StocktakeItemMO
        dummyStockItem.invCode = 123456
        dummyStockItem.itemDescription = "blah blah blah"
        dummyStockItem.lastCost = 12.3
        dummyStockItem.section = "BEEF"
        dummyStockItem.units = "Kilogram"
        dummyStockItem.physicalAmount = 1.2
        
        dummyStockItem.singularStocktake = metaData
        
        
        let dummyStockItem1 = NSEntityDescription.insertNewObjectForEntityForName("StocktakeItemEntity", inManagedObjectContext: self.moc) as! StocktakeItemMO
        dummyStockItem1.invCode = 123456
        dummyStockItem1.itemDescription = "blah blah blah"
        dummyStockItem1.lastCost = 12.3
        dummyStockItem1.section = "BEEF"
        dummyStockItem1.units = "Kilogram"
        dummyStockItem1.physicalAmount = 1.2
        
        dummyStockItem1.singularStocktake = metaData
        
        
        
        let aSet: Set = [dummyStockItem, dummyStockItem1]
        metaData.stocktakeItems = aSet
        
        
        //
        //3. add metaData to each StockTakeItemMO instance
        //for the to-one relationship
        //
        //may have to rethink how the "stocktake" data stucture is. mayber it shouldn't 
        //just be [invCode: physicalAmount], but richer with all the typical features 
        //that an item has: description, units, etc etc.
        //because if we don't then we have to query for every invCode inorder to get
        //these extra features needed for a StockTakeItemMO instance.
        
        do {
            try self.moc.save()
            print("SUCCESS: save stocktakeMetaData to persistent store")
        }
        catch let error as NSError {
            fatalError("FAILURE to save context: \(error)")
        }
    }
}
