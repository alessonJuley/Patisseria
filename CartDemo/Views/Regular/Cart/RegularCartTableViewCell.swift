//
//  RegularCartTableViewCell.swift
//  CartDemo
//
//  Created by Alesson Abao on 26/05/23.
//

import UIKit
import SQLite3

var cartProductQtyFromCell: Int = 0

class RegularCartTableViewCell: UITableViewCell {
    
    // MARK: Outlets
    @IBOutlet weak var regularCartProductName: UILabel!
    @IBOutlet weak var regularCartProductPrice: UILabel!
    @IBOutlet weak var regularCartProductQty: UILabel!
    @IBOutlet weak var regularCartProductPic: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
