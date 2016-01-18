//
//  StocktakeSummaryViewController.swift
//  StockSwift
//
//  Created by andre trosky on 18/01/2016.
//  Copyright © 2016 andre trosky. All rights reserved.
//

import UIKit
import MessageUI

class StocktakeSummaryViewController: UIViewController, MFMailComposeViewControllerDelegate {
    
    //MARK: Properties
    var stocktake: Stocktake?
    @IBOutlet weak var emailButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        print("StocktakeSummaryViewController, viewDidLoad func")
        print(stocktake)
        print(stocktake?.stocktakeMetaData)
        //print(stocktake?.stocktake)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func emailStocktake(sender: UIButton) {
        print("emailStocktake")
        
        if MFMailComposeViewController.canSendMail() {
            print("canSendMail is true")
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["andretrosky@gmail.com"])
            
            
            
            let sep = " // "
            let sub0 = "StockSwift: "
            let sub1 = (stocktake?.stocktakeMetaData[StocktakeNewSetupViewController.stocktakeMetadataStruct.departmentKey])!.uppercaseString
            let sub2 = (stocktake?.stocktakeMetaData[StocktakeNewSetupViewController.stocktakeMetadataStruct.personNameKey])!
            let sub3 = (stocktake?.stocktakeMetaData[StocktakeNewSetupViewController.stocktakeMetadataStruct.startDateKey])!
            let subject = sub0 + sub1 + sep + sub2 + sep + sub3
            
            mail.setSubject(subject)
            mail.setMessageBody("yadda yadda yadda.", isHTML: false)
            //mail.addAttachmentData(<#T##attachment: NSData##NSData#>, mimeType: <#T##String#>, fileName: <#T##String#>)
            
            presentViewController(mail, animated: true, completion: nil)
        }
        else {
            print("ERROR: device cannot send email")
        }
    }
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }

    // MARK: - Navigation

    /*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}
