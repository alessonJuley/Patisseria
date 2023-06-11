//
//  VisuallyImpairedHomeTableViewCell.swift
//  CartDemo
//
//  Created by Alesson Abao on 11/06/23.
//

import UIKit

class VisuallyImpairedHomeTableViewCell: UITableViewCell {
    
    // MARK: Outlets
    @IBOutlet weak var visualProductName: UILabel!
    @IBOutlet weak var visualProductPrice: UILabel!
    @IBOutlet weak var visualProductImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
