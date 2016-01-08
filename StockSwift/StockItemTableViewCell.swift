//
//  StockItemTableViewCell.swift
//  StockSwift
//
//  Created by andre trosky on 27/12/2015.
//  Copyright © 2015 andre trosky. All rights reserved.
//

import UIKit

class StockItemTableViewCell: UITableViewCell {
    
    // MARK: Properties
    @IBOutlet weak var stockPhotoImageView: UIImageView!
    @IBOutlet weak var stockDescriptionLabel: UILabel!
    @IBOutlet weak var stockFineDetailsLabel: UILabel!
    @IBOutlet weak var stockRunningAmountLabel: UILabel!
    @IBOutlet weak var stockRunningCostLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
