//
//  VisualWishProductHolder.swift
//  CartDemo
//
//  Created by Alesson Abao on 11/06/23.
//

import Foundation
import UIKit

class VisualWishProductHolder{
    
    var visualWishID: Int!
    var visualWishUserID: Int!
    var visualWishProductName: String!
    var visualWishProductDescription: String!
    var visualWishProductCategory: String?
    var visualWishProductPrice: Double!
    var visualWishProductImage: String!
    
    public init(visualWishID: Int!, visualWishUserID: Int!, visualWishProductName: String!, visualWishProductDescription: String!, visualWishProductCategory: String? = nil, visualWishProductPrice: Double!, visualWishProductImage: String!) {
        self.visualWishID = visualWishID
        self.visualWishUserID = visualWishUserID
        self.visualWishProductName = visualWishProductName
        self.visualWishProductDescription = visualWishProductDescription
        self.visualWishProductCategory = visualWishProductCategory
        self.visualWishProductPrice = visualWishProductPrice
        self.visualWishProductImage = visualWishProductImage
    }
}
