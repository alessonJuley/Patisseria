//
//  VisuallyImpairedWishListTableViewCell.swift
//  CartDemo
//
//  Created by Alesson Abao on 11/06/23.
//

import UIKit

class VisuallyImpairedWishListTableViewCell: UITableViewCell {

    // MARK: Outlets
    @IBOutlet weak var visualWishProductName: UILabel!
    @IBOutlet weak var visualWishProductPrice: UILabel!
    @IBOutlet weak var visualWishProductCategory: UILabel!
    @IBOutlet weak var visualWishProductImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
