//
//  StockItemDetailsViewController.swift
//  StockSwift
//
//  Created by andre trosky on 28/12/2015.
//  Copyright © 2015 andre trosky. All rights reserved.
//

import UIKit

class StockItemDetailsViewController: UIViewController {
    
    // MARK: Properties
    
    @IBOutlet weak var stockDescriptionLabel: UILabel!
    @IBOutlet weak var stockFineDetailLabel: UILabel!
    @IBOutlet weak var stockPhysicalAmountLabel: UILabel!
    @IBOutlet weak var stockMoneyAmountLabel: UILabel!
    
    var stockItem:StockItem?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        print(stockItem!.description)
        
        if let item = stockItem {
          stockDescriptionLabel.text = item.description
          stockFineDetailLabel.text = "ID: " + String(item.invCode) + " /// $" + String(item.lastCost) + " per " + item.units
        
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
