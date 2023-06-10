//
//  WishListTableViewCell.swift
//  CartDemo
//
//  Created by Alesson Abao on 1/06/23.
//

import UIKit

class WishListTableViewCell: UITableViewCell {

    // MARK: Outlets
    @IBOutlet weak var wishProductName: UILabel!
    @IBOutlet weak var wishProductPrice: UILabel!
    @IBOutlet weak var wishProductCategory: UILabel!
    @IBOutlet weak var wishProductImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
