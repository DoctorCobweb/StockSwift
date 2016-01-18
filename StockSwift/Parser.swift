//
//  Parser.swift
//  StockSwift
//
//  Created by andre trosky on 15/01/2016.
//  Copyright © 2016 andre trosky. All rights reserved.
//

import Foundation

class Parser {
    let stockDataAssetName: String


    init(stockDataAssetName assetName: String) {
        self.stockDataAssetName = assetName
    }
    
    func parseStockDataCsv () ->  (headers:[String]?,
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
        let stock_data = NSDataAsset(name:stockDataAssetName)
        
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
                        let meat_set: Set = ["POULTRY", "BEEF", "PORK", "LAMB", "SEAFOOD"]
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
