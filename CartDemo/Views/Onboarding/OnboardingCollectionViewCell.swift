//
//  OnboardingCollectionViewCell.swift
//  CartDemo
//
//  Created by Alesson Abao on 10/06/23.
//

import UIKit

class OnboardingCollectionViewCell: UICollectionViewCell {
    
    static let identifier = String(describing: OnboardingCollectionViewCell.self)
    
    // MARK: Outlets
    @IBOutlet weak var slideImageView: UIImageView!
    @IBOutlet weak var slideTitleLabel: UILabel!
    @IBOutlet weak var slideDescriptionLabel: UILabel!
    
    
    
    // this is connected to OnboardingSlide.swift
    func setUp(_ slide: OnboardingSlide){
        // populate the fields
        slideImageView.image = slide.image
        slideTitleLabel.text = slide.title
        slideDescriptionLabel.text = slide.description
    }
}
