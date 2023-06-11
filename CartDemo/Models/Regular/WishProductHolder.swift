//
//  WishProductHolder.swift
//  CartDemo
//
//  Created by Alesson Abao on 1/06/23.
//

import Foundation
import UIKit

class WishProductHolder{
    
    var wishID: Int!
    var wishUserID: Int!
    var wishProductName: String!
    var wishProductDescription: String!
    var wishProductCategory: String?
    var wishProductPrice: Double!
    var wishProductImage: String!
    
    public init(wishID: Int!, wishUserID: Int!, wishProductName: String!, wishProductDescription: String!, wishProductCategory: String? = nil, wishProductPrice: Double!, wishProductImage: String!) {
        self.wishID = wishID
        self.wishUserID = wishUserID
        self.wishProductName = wishProductName
        self.wishProductDescription = wishProductDescription
        self.wishProductCategory = wishProductCategory
        self.wishProductPrice = wishProductPrice
        self.wishProductImage = wishProductImage
    }
}
