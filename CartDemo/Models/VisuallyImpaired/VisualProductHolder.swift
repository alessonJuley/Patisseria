//
//  VisualProductHolder.swift
//  CartDemo
//
//  Created by Alesson Abao on 11/06/23.
//

import Foundation
import UIKit

class VisualProductHolder{
    var visualProductID: Int!
    var visualProductName: String!
    var visualProductDescription: String!
    var visualProductCategory: String?
    var visualProductPrice: Double!
    var visualProductImage: String!
    
    public init(visualProductID: Int!, visualProductName: String!, visualProductDescription: String!, visualProductCategory: String? = nil, visualProductPrice: Double!, visualProductImage: String!) {
        self.visualProductID = visualProductID
        self.visualProductName = visualProductName
        self.visualProductDescription = visualProductDescription
        self.visualProductCategory = visualProductCategory
        self.visualProductPrice = visualProductPrice
        self.visualProductImage = visualProductImage
    }
}
