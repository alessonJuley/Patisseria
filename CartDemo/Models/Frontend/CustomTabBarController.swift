//
//  CustomTabBarController.swift
//  CartDemo
//
//  Created by Alesson Abao on 11/06/23.
//

import UIKit

class CustomTabBarController: UITabBarController{
    @IBInspectable var initialIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        selectedIndex = initialIndex
    }
}
