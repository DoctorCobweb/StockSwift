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
        //
        setupStocktake()
    }
    
    
    func setupStocktake() {
        
        //1. save the stocktake meta details first
        let metaData = NSEntityDescription.insertNewObjectForEntityForName("StocktakeMetaDataEntity", inManagedObjectContext: self.moc) as! StocktakeMetaDataMO
        metaData.personName = stocktakeMetaData["person_name"]!
        metaData.department = stocktakeMetaData["department"]!
        metaData.startDate = stocktakeMetaData["start_date"]!
        
        
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
        let stockContent = parseStockDataCSV()
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
            print("adding a StockImageEntity row...")
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
            print("adding a CurrentItemPriceEntity row...")
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
        print("getSingularStockItem func")
        print(stocktakeMetaData["person_name"])
        print(stocktakeMetaData["department"])
        print(stocktakeMetaData["start_date"])
        
        let itemFetch = NSFetchRequest(entityName: "StocktakeItemEntity")
        
        //item has to be for this stocktake!!! so we match on singularStocktake prop
        let formatString = "invCode == %d AND singularStocktake.personName == %@ AND singularStocktake.department == %@ AND singularStocktake.startDate == %@"
        //let formatString = "invCode == %d"
        
        itemFetch.predicate = NSPredicate(format:formatString, invCode,stocktakeMetaData["person_name"]!, stocktakeMetaData["department"]!, stocktakeMetaData["start_date"]!)
        //itemFetch.predicate = NSPredicate(format:formatString, invCode)
    
        do {
            let fetchedItems = try self.moc.executeFetchRequest(itemFetch)
            
            print("fetchedItems.count: \(fetchedItems.count)")
            
            if !fetchedItems.isEmpty && fetchedItems.count == 1 {
                print("TOTOTO")
                return fetchedItems[0] as? StocktakeItemMO
            }
            else {
                print("BADBADBABD")
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
    
    
    
    func parseStockDataCSV () ->  (headers:[String]?,
                                   data:[(stock_group:String,
                                   stock_group_cleaned:String,
                                   inv_code:Int?,
                                   description:String,
                                   units:String,
                                   last_cost:Float?,
                                   barcode:String)]) {
                                
        // Load the CSV file and parse it
        let delimiter = ","
        var headers: [String]?
        var items = [(stock_group:String,
                     stock_group_cleaned:String,
                     inv_code:Int?,
                     description:String,
                     units:String,
                     last_cost:Float?,
                     barcode:String)]()
        
        //get the stock_data from the assests folder
        let stock_data = NSDataAsset(name:"stock_data")
        
        //stock_data!.data is raw byte data so we must convert it to String using the following initializer
        if let content = String(data:stock_data!.data, encoding:NSUTF8StringEncoding) {
            //items = []
            let lines:[String] = content.componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet()) as [String]
            
            for (index,line) in lines.enumerate() {
                //print(index)
                var values:[String] = []
                if line != "" {
                    // For a line with double quotes
                    // we use NSScanner to perform the parsing
                    if line.rangeOfString("\"") != nil {
                        var textToScan:String = line
                        var value:NSString?
                        var textScanner:NSScanner = NSScanner(string: textToScan)
                        while textScanner.string != "" {
                            
                            if (textScanner.string as NSString).substringToIndex(1) == "\"" {
                                textScanner.scanLocation += 1
                                textScanner.scanUpToString("\"", intoString: &value)
                                textScanner.scanLocation += 1
                            } else {
                                textScanner.scanUpToString(delimiter, intoString: &value)
                            }
                            
                            // Store the value into the values array
                            values.append(value as! String)
                            
                            // Retrieve the unscanned remainder of the string
                            if textScanner.scanLocation < textScanner.string.characters.count {
                                textToScan = (textScanner.string as NSString).substringFromIndex(textScanner.scanLocation + 1)
                            } else {
                                textToScan = ""
                            }
                            
                            textScanner = NSScanner(string: textToScan)
                        }
                    }
                    else  {
                        // For a line without double quotes, we can simply separate the string
                        // by using the delimiter (e.g. comma)
                        values = line.componentsSeparatedByString(delimiter)
                    }
                    
                    if index == 0 {
                        //we have the header line
                        headers = values
                    }
                    else {
                        
                        //trim whitespace and newlines from strings
                        let stock_group_tmp = values[0].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                        var stock_group_cleaned_tmp = values[1].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                        let description_tmp = values[3].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                        let units_tmp = values[4].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                        let barcode_tmp = values[6].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                        
                        
                        //change stock group categories to make a smaller number of categories.
                        //need to do this so the search bar scope terms are not too many and hence display bad/small
                        let meat_set: Set = ["POULTRY", "BEEF", "PORK", "LAMB", "SEAFODD"]
                        let other_set: Set = ["DESSERT", "BEVERAGE"]
                        stock_group_cleaned_tmp = meat_set.contains(stock_group_cleaned_tmp) ? "MEAT" : stock_group_cleaned_tmp
                        stock_group_cleaned_tmp = other_set.contains(stock_group_cleaned_tmp) ? "OTHER" : stock_group_cleaned_tmp
                        
                        
                        // Put the values into the tuple and add it to the items array
                        let item = (stock_group: stock_group_tmp ,
                                    stock_group_cleaned: stock_group_cleaned_tmp,
                                    inv_code: Int(values[2]),
                                    description: description_tmp,
                                    units: units_tmp,
                                    last_cost: Float(values[5]),
                                    barcode: barcode_tmp)
                        
                        items.append(item)
                    }
                }
            }
        }
        else {
            print("ERROR: unable to read stock_data")
        }
        return (headers, items)
    }
    
    
    
}
