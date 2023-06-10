//
//  RegularHomeTableViewCell.swift
//  CartDemo
//
//  Created by Alesson Abao on 26/05/23.
//

import UIKit

class RegularHomeTableViewCell: UITableViewCell {
    
    // MARK: Outlets
    @IBOutlet weak var regularHomeProductName: UILabel!
    @IBOutlet weak var regularHomeProductPrice: UILabel!
    @IBOutlet weak var regularHomeProductDescription: UILabel!
    @IBOutlet weak var regularHomeProductPic: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
