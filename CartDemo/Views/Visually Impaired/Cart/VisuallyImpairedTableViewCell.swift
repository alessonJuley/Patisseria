//
//  VisuallyImpairedTableViewCell.swift
//  CartDemo
//
//  Created by Alesson Abao on 11/06/23.
//

import UIKit

class VisuallyImpairedTableViewCell: UITableViewCell {

    // MARK: Outlets
    @IBOutlet weak var visualCartProductName: UILabel!
    @IBOutlet weak var visualCartProductPrice: UILabel!
    @IBOutlet weak var visualCartProductQty: UILabel!
    @IBOutlet weak var visualCartProductImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
