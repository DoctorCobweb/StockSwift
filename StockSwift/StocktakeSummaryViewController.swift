//
//  StocktakeSummaryViewController.swift
//  StockSwift
//
//  Created by andre trosky on 18/01/2016.
//  Copyright © 2016 andre trosky. All rights reserved.
//

import UIKit

class StocktakeSummaryViewController: UIViewController {
    
    //MARK: Properties
    var stocktake: Stocktake?

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
    

    // MARK: - Navigation

    /*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}
