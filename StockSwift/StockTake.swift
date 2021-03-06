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
    var stocktakeMetaData: [String:String]
    let moc: NSManagedObjectContext
    
    init(metaData:[String:String]) {
    
        //in swift, all properties of the subclass must be 
        //initialized before calling super.
        stocktakeMetaData = metaData
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        moc = appDelegate.managedObjectContext
        
        super.init()
        
        //any method calls have to go here, below super.init()
    }
    
    
    func startup() {
        
        //1. DELETE OLD CURRENT ITEM PRICE ENTITIES.
        //delete all OLD current item prices as we will consider the 'stock_data' as being
        //the most up to date stuff.
        let currentFetch = NSFetchRequest(entityName: "CurrentItemPriceEntity")
        
        do {
        
            let allCurrentItems = try self.moc.executeFetchRequest(currentFetch) as! [CurrentItemPriceMO]
            
            if !allCurrentItems.isEmpty {
                for item in allCurrentItems {
                    self.moc.deleteObject(item)
                }
                //persistData("deleted all OLD CurrentItemPriceEntitiy items")
            }
            persistData("deleted all OLD CurrentItemPriceEntitiy items")
        }
        catch let error as NSError {
            fatalError("FAILURE to save context: \(error)")
        }
        
        
        
        //2. READ IN STOCK DATA CSV. CONSIDER THIS AS THE NEW STOCK PRICES
        let parser = Parser(stockDataAssetName: "stock_data")
        let stockContent = parser.parseStockDataCsv()
        let stockHeaders = stockContent.headers
        let stockContent_sorted = stockContent.data.sort{$0.description < $1.description}
        
        
        //3. RECREATE CURRENT PRICE ITEM ENTITIES
        
        for item in stockContent_sorted {
            //print("adding a CurrentItemPriceEntity row...")
            let currentItemPrice = NSEntityDescription.insertNewObjectForEntityForName("CurrentItemPriceEntity", inManagedObjectContext: moc) as! CurrentItemPriceMO
            
            currentItemPrice.invCode = item.inv_code!
            currentItemPrice.itemDescription = item.description
            currentItemPrice.lastCost = item.last_cost!
            currentItemPrice.section = item.stock_group_cleaned
            currentItemPrice.sectionOriginal = item.stock_group
            currentItemPrice.units = item.units
        }
        
        persistData("save all CurrentItemPriceEntity items")
        
        
        //xxx. IMAGES
        let imageFetch = NSFetchRequest(entityName: "StockImageEntity")
        
        do {
            
            print("feching all images in core data")
            let allImages = try self.moc.executeFetchRequest(imageFetch) as! [StockImageMO]
            
            if allImages.isEmpty {
                print("ZERO IMAGES IN CORE DATA. adding defaults")
                for item in stockContent_sorted {
                    let stockImage = NSEntityDescription.insertNewObjectForEntityForName("StockImageEntity", inManagedObjectContext: self.moc) as! StockImageMO
                    
                    stockImage.invCode = item.inv_code!
                    stockImage.photo = UIImagePNGRepresentation(UIImage(named:"defaultImage")!)
                    persistData("saved a default StockImageEntity item")
                }
            }
            else {
                print("ALREADY HAVE IMAGES. not deleting")
            }
        }
        catch let error as NSError {
            fatalError("FAILURE to save context: \(error)")
        }
        
        
        
        //xxx. CREATE THE STOCKTAKE METADATA ENTITY
        let metaData = NSEntityDescription.insertNewObjectForEntityForName("StocktakeMetaDataEntity", inManagedObjectContext: self.moc) as! StocktakeMetaDataMO
        metaData.personName = stocktakeMetaData[StocktakeNewSetupViewController.stocktakeMetadataStruct.personNameKey]!
        metaData.department = stocktakeMetaData[StocktakeNewSetupViewController.stocktakeMetadataStruct.departmentKey]!
        metaData.startDate = stocktakeMetaData[StocktakeNewSetupViewController.stocktakeMetadataStruct.startDateKey]!
        
        
        
        var _items: Set<StocktakeItemMO> = []
        
        for item in stockContent_sorted {
            let _item = NSEntityDescription.insertNewObjectForEntityForName("StocktakeItemEntity", inManagedObjectContext: self.moc) as! StocktakeItemMO
            
            _item.invCode = item.inv_code!
            _item.itemDescription = item.description
            _item.lastCost = item.last_cost!
            _item.section = item.stock_group_cleaned
            _item.sectionOriginal = item.stock_group
            _item.units = item.units
            _item.physicalAmount = 0
            
            //set the to-one relationship for a stock item to have a meta data entitiy
            _item.singularStocktake = metaData
            
            _items.insert(_item)
        }
        
        //set the to-many relationship for meta data to have many stock take items
        metaData.stocktakeItems = _items
        
        
        persistData("setup the current stocktake with StocktakeItemEntity entities")
    }
    
    
    func updateStocktakeMetaData(forKey key: String, forValue value:String) {
        
        //create fetch request with predicate
        //update finishDate value with value
        //IMPORTANT:
        //item has to be for this stocktake!!! so we match on singularStocktake prop
        let metaFetch = NSFetchRequest(entityName: "StocktakeMetaDataEntity")
        let formatString = "personName == %@ AND department == %@ AND startDate == %@"
        
        metaFetch.predicate = NSPredicate(format:formatString, stocktakeMetaData[StocktakeNewSetupViewController.stocktakeMetadataStruct.personNameKey]!, stocktakeMetaData[StocktakeNewSetupViewController.stocktakeMetadataStruct.departmentKey]!, stocktakeMetaData[StocktakeNewSetupViewController.stocktakeMetadataStruct.startDateKey]!)
    
        do {
            let fetchedItems = try self.moc.executeFetchRequest(metaFetch)
            
            if !fetchedItems.isEmpty && fetchedItems.count == 1 {
                let metaMO = fetchedItems[0] as? StocktakeMetaDataMO
                
                //print("metaMO is: \(metaMO)")
                metaMO?.finishDate = value
                persistData("update the StocktakeMetaDataMO entity")
            }
            else {
                print("ERROR: could not find the meta data item in CD")
            }
        }
        catch let error as NSError {
            fatalError("FAILURE to save context: \(error)")
        }
    
    
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
        print("in persist data")
        
        do {
            print("going to try and save for action: \(action)")
            try self.moc.save()
            print("SUCCESS: save to persistent store, action: \(action)")
        }
        catch let error as NSError {
            print("FAILIRE: to persist data")
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
            
            //TODO: FIX THIS AS SO WE CAN CHECK
            //FOR COUNT == 1
            //CURRENTLY WE'RE ACCIDENTALLY MAKING
            //MANY COPIES OF THE SAME STOCKTAKE
            //WEHN LOADING A PREVIOUS STOCKTAKE.
            if !fetchedItems.isEmpty && fetchedItems.count == 1 {
            //if !fetchedItems.isEmpty {
                print("fetched only 1")
                return fetchedItems[0] as? StocktakeItemMO
            }
            else {
                print("fetched zero or more")
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
}
