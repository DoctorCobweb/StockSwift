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
        
        //IMPORTANT
        //this has to go below the call to super.init() because
        //super initializes self
        setupStocktake()
    }
    
    
    func setupStocktake() {
        
        //1. save the stocktake meta details first
        let metaData = NSEntityDescription.insertNewObjectForEntityForName("StocktakeMetaDataEntity", inManagedObjectContext: self.moc) as! StocktakeMetaDataMO
        metaData.personName = stocktakeMetaData[StocktakeNewSetupViewController.stocktakeMetadataStruct.personNameKey]!
        metaData.department = stocktakeMetaData[StocktakeNewSetupViewController.stocktakeMetadataStruct.departmentKey]!
        metaData.startDate = stocktakeMetaData[StocktakeNewSetupViewController.stocktakeMetadataStruct.startDateKey]!
        
        
        //2.
        bootstrapCoreData()
        
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
    
    
    func bootstrapCoreData() {
        
        var stockItems = [StockItem]()
        
        //first load and parse the csv data file, "stock_data", then sort it alphabettically
        //using description field
        //stockContent is (headers, data) structure
        let parser = Parser(stockDataAssetName: "stock_data")
        let stockContent = parser.parseStockDataCsv()
        let stockHeaders = stockContent.headers
        let stockContent_sorted = stockContent.data.sort{$0.description < $1.description}
        
        
        //instantiate a stock item for each item in stockContent.data
        for (index, item) in stockContent_sorted.enumerate() {
            
            let photo:UIImage?
            
            //just playing around with different images
            if index % 3 == 0 {
                photo = UIImage(named:"stock3")!
            }
            else if index % 5 == 0 {
                photo = UIImage(named:"stock2")!
            }
            else if index % 7 == 0 {
                photo = UIImage(named:"snow")!
            }
            else {
                photo = UIImage(named: "stock1")!
            }
            
            let stockItem = StockItem(
                photo: photo,
                description: item.description,
                invCode: item.inv_code!,
                lastCost: item.last_cost!,
                units: item.units,
                section: item.stock_group_cleaned)
            
            stockItems += [stockItem]
        }
        
        setupImageEntities(stockItems)
        setupCurrentItemPriceEntities(stockItems)
    }
    
    
    func setupImageEntities(stockItems: [StockItem]) {
        
        //for now, delete all the old images (THIS IS BAD) and put in new ones.
        //eventually when we will be able to use the camera to take photos of each item
        //and when that is we should NOT delete any old pics.
        let imageFetch = NSFetchRequest(entityName: "StockImageEntity")
        
        do {
        
            let allImages = try self.moc.executeFetchRequest(imageFetch) as! [StockImageMO]
            
            if !allImages.isEmpty {
                for item in allImages {
                    self.moc.deleteObject(item)
                }
                persistData("deleted all OLD StockImageEntity items")
            }
        }
        catch let error as NSError {
            fatalError("FAILURE to save context: \(error)")
        }
        
        
        //now add in NEW ones
        for item in stockItems {
            //print("adding a StockImageEntity row...")
            let stockImage = NSEntityDescription.insertNewObjectForEntityForName("StockImageEntity", inManagedObjectContext: self.moc) as! StockImageMO
            
            stockImage.invCode = item.invCode
            stockImage.photo = UIImagePNGRepresentation(item.photo!)
        }
        
        persistData("save all NEW StockImageEntity items")
    }
    
    
    func setupCurrentItemPriceEntities(stockItems: [StockItem]) {
        
        //delete all OLD current item prices as we will consider the 'stock_data' as being
        //the most up to date stuff.
        let currentFetch = NSFetchRequest(entityName: "CurrentItemPriceEntity")
        
        do {
        
            let allCurrentItems = try self.moc.executeFetchRequest(currentFetch) as! [CurrentItemPriceMO]
            
            if !allCurrentItems.isEmpty {
                for item in allCurrentItems {
                    self.moc.deleteObject(item)
                }
                persistData("deleted all OLD CurrentItemPriceEntitiy items")
            }
        }
        catch let error as NSError {
            fatalError("FAILURE to save context: \(error)")
        }
        
        
        //if there are current item entities already in core data then consider them
        //old. delete them all and remake them using the newest data, which has come
        //from the 'stock_data' asset csv file from management.
        
        for item in stockItems {
            //print("adding a CurrentItemPriceEntity row...")
            let currentItemPrice = NSEntityDescription.insertNewObjectForEntityForName("CurrentItemPriceEntity", inManagedObjectContext: moc) as! CurrentItemPriceMO
            
            currentItemPrice.invCode = item.invCode
            currentItemPrice.itemDescription = item.description
            currentItemPrice.lastCost = item.lastCost
            currentItemPrice.section = item.section
            currentItemPrice.units = item.units
        }
        
        persistData("save all CurrentItemPriceEntity items")
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
    
    
    func loadStockItemsFromCoreData() -> [StockItem]? {
        
        let itemsFetch = NSFetchRequest(entityName: "CurrentItemPriceEntity")
        let descriptionSort = NSSortDescriptor(key: "itemDescription", ascending: true)
        itemsFetch.sortDescriptors = [descriptionSort]
        
        var stockItems = [StockItem]()
        
        do {
        
            let fetchedCurrentItems = try moc.executeFetchRequest(itemsFetch) as! [CurrentItemPriceMO]
            
            if !fetchedCurrentItems.isEmpty {
                for item in fetchedCurrentItems {
                    let aPhoto: UIImage?
                    
                    aPhoto = self.getStockItemPhoto(item.invCode)
                
                    let stockItem = StockItem(photo: aPhoto, description: item.itemDescription, invCode: item.invCode, lastCost: item.lastCost, units: item.units, section: item.section)
                    
                    stockItems += [stockItem]
                }
                return stockItems
            }
            else {
                return nil
            }
        }
        catch let error as NSError {
            fatalError("FAILURE to save context: \(error)")
        }
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
        
        //IMPORTANT:
        //item has to be for this stocktake!!! so we match on singularStocktake prop
        let formatString = "invCode == %d AND singularStocktake.personName == %@ AND singularStocktake.department == %@ AND singularStocktake.startDate == %@"
        
        itemFetch.predicate = NSPredicate(format:formatString, invCode, stocktakeMetaData[StocktakeNewSetupViewController.stocktakeMetadataStruct.personNameKey]!, stocktakeMetaData[StocktakeNewSetupViewController.stocktakeMetadataStruct.departmentKey]!, stocktakeMetaData[StocktakeNewSetupViewController.stocktakeMetadataStruct.startDateKey]!)
    
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
    
    
    func createFinalStocktake() {
        
        //should we be saving again?
        print("createFinalStocktake called")
    }
}
