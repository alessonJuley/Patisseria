//
//  ProductListTableViewCell.swift
//  CartDemo
//
//  Created by Alesson Abao on 10/06/23.
//

import UIKit

class ProductListTableViewCell: UITableViewCell {

    // MARK: Outlets
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var productPriceLabel: UILabel!
    @IBOutlet weak var productPic: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

