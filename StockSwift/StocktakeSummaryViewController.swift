//
//  StocktakeSummaryViewController.swift
//  StockSwift
//
//  Created by andre trosky on 18/01/2016.
//  Copyright © 2016 andre trosky. All rights reserved.
//

import UIKit
import MessageUI
import CoreData
import SwiftCharts

class StocktakeSummaryViewController: UIViewController, MFMailComposeViewControllerDelegate {
    
    //MARK: Properties
    var stocktake: Stocktake?
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var emailButton: UIButton!
    
    @IBOutlet weak var personNameLabel: UILabel!
    @IBOutlet weak var departmentLabel: UILabel!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var finishDateLabel: UILabel!
    
    var chart: Chart? //arc
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        print("StocktakeSummaryViewController, viewDidLoad func")
        print(stocktake)
        print(stocktake?.stocktakeMetaData)
        
        navigationItem.title = "Stocktake Summary"
        
        if let stocktake = stocktake {
            personNameLabel.text = stocktake.stocktakeMetaData["person_name"]
            departmentLabel.text = stocktake.stocktakeMetaData["department"]
            startDateLabel.text = stocktake.stocktakeMetaData["start_date"]
            finishDateLabel.text = stocktake.stocktakeMetaData["finish_date"]
        }
        
        chartDemo1()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func chartDemo() {
        let chartConfig = ChartConfigXY(
            xAxisConfig: ChartAxisConfig(from: 2, to: 14, by: 2),
            yAxisConfig: ChartAxisConfig(from: 0, to: 14, by: 2)
        )
        
        let chart = LineChart(
            frame: CGRectMake(0, 70, 300, 500),
            chartConfig: chartConfig,
            xTitle: "X axis",
            yTitle: "Y axis",
            lines: [
                (chartPoints: [(2.0, 10.6), (4.2, 5.1), (7.3, 3.0), (8.1, 5.5), (14.0, 8.0)], color: UIColor.redColor()),
                (chartPoints: [(2.0, 2.6), (4.2, 4.1), (7.3, 1.0), (8.1, 11.5), (14.0, 3.0)], color: UIColor.blueColor())
            ]
        )
        
        //self.view.addSubview(chart.view)
        self.emailButton.addSubview(chart.view)
    }
    
    func chartDemo1() {
        let chartConfig = BarsChartConfig(
            valsAxisConfig: ChartAxisConfig(from: 0, to: 8, by: 2)
        )
        
        let chart = BarsChart(
            frame: CGRectMake(0, 70, 300, 500),
            chartConfig: chartConfig,
            xTitle: "X axis",
            yTitle: "Y axis",
            bars: [
                ("A", 2),
                ("B", 4.5),
                ("C", 3),
                ("D", 5.4),
                ("E", 6.8),
                ("F", 0.5)
            ],
            color: UIColor.redColor(),
            barWidth: 20
        )
        
        self.view.addSubview(chart.view)
        //self.emailButton.addSubview(chart.view)
        self.chart = chart
    }
    
    
    @IBAction func emailStocktake(sender: UIButton) {
        print("emailStocktake")
        
        if MFMailComposeViewController.canSendMail() {
            print("canSendMail is true")
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["andretrosky@gmail.com"])
            
            let sub0 = "StockSwift: "
            let sub1 = (stocktake?.stocktakeMetaData[StocktakeNewSetupViewController.stocktakeMetadataStruct.departmentKey])!.uppercaseString
            let personName = (stocktake?.stocktakeMetaData[StocktakeNewSetupViewController.stocktakeMetadataStruct.personNameKey])!
            
            let personNameArray = personName.characters.split {$0 == " "}.map{String($0)}
            var fixedPersonName = ""
            
            for name in personNameArray {
                fixedPersonName += name
            }
            
            let startDateString = (stocktake?.stocktakeMetaData[StocktakeNewSetupViewController.stocktakeMetadataStruct.startDateKey])!
            let finishDateString = (stocktake?.stocktakeMetaData[StocktakeNewSetupViewController.stocktakeMetadataStruct.finishDateKey])!
            
            let dateArray = startDateString.characters.split {$0 == " "}.map{String($0)} //no spaces
            let fixedDate = dateArray[0] + "-" + dateArray[1]
            let sub3 = ".csv"
            
            
            let subject = sub0 + sub1
            let stocktakeFileName = sub1 + "_" + fixedPersonName + "_" + fixedDate + sub3
            
            
            mail.setSubject(subject)
            let body1 = "Hi,\n\n"
            let body2 = "Please find attached the stocktake file called:\n\n\"\(stocktakeFileName)\".\n\n"
            let body3 = "Start time: \(startDateString)\n"
            let body4 = "Finish time: \(finishDateString)\n\n"
            let body5 = "Regards,\n"
            let body6 = "StockSwift"
            
            let body = body1 + body2 + body3 + body4 + body5 + body6
            
            mail.setMessageBody(body, isHTML: false)
            
            let actualStocktakeData = stocktakeData()
            
            var output:String = ""
            
            for item in actualStocktakeData! {
                let sep = ","
                let _item = item as! StocktakeItemMO
                let _invCode = String(_item.invCode)
                let _itemDescription = _item.itemDescription
                let _lastCost = String(_item.lastCost)
                let _section = _item.section
                let _units = _item.units
                let _physicalAmount = String(_item.physicalAmount)
                
                let line = _invCode + sep + _itemDescription + sep + _lastCost + sep + _section + sep + _units + sep + _physicalAmount + "\n"
                
                output += line
            }
            
            print(output)
            let theData = output.dataUsingEncoding(NSUTF8StringEncoding)
            
            mail.addAttachmentData(theData!, mimeType: "text/csv", fileName: stocktakeFileName)
            
            presentViewController(mail, animated: true, completion: nil)
        }
        else {
            print("ERROR: device cannot send email")
        }
    }
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func stocktakeData() -> NSSet? {
        print("stocktakeData func")
        
        let theStock: NSSet?
        
        let sFetch = NSFetchRequest(entityName: "StocktakeMetaDataEntity")
        let formatString = "personName == %@ AND department == %@ AND startDate == %@"
        
        let personKey = StocktakeNewSetupViewController.stocktakeMetadataStruct.personNameKey
        let depKey = StocktakeNewSetupViewController.stocktakeMetadataStruct.departmentKey
        let startKey = StocktakeNewSetupViewController.stocktakeMetadataStruct.startDateKey
        
        let personName = (stocktake?.stocktakeMetaData[personKey])!
        let department = (stocktake?.stocktakeMetaData[depKey])!
        let start = (stocktake?.stocktakeMetaData[startKey])!
        
        sFetch.predicate = NSPredicate(format: formatString, personName, department, start)
        
        do {
            let fetchedItems = try self.stocktake?.moc.executeFetchRequest(sFetch) as! [StocktakeMetaDataMO]
            
            if !fetchedItems.isEmpty && fetchedItems.count == 1 {
                print("fetchItems is not empty and count is ==1")
                let fStocktake = fetchedItems[0]
                
                theStock = fStocktake.stocktakeItems
            }
            else {
                return nil
            }
        }
        catch let error as NSError {
            fatalError("ERROR: \(error)")
        }
        
        return theStock
    }

    // MARK: - Navigation

    @IBAction func backToStocktake(sender: UIBarButtonItem) {
        print("backToStocktake")
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    
    
    
    /*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}
