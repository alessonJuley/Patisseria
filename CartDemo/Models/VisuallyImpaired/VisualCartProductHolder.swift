//
//  VisualCartProductHolder.swift
//  CartDemo
//
//  Created by Alesson Abao on 11/06/23.
//

import Foundation

class VisualCartProductHolder{
    
    var visualCartProductID: Int!
    var visualCartID: Int!
    var visualProductID: Int!
    var visualCartProductQty: Int!
    var visualCartTotalPrice: Double!
    var visualProductName: String!
    var visualProductPrice: Double!
    var visualProductImage: String!
    
    public init(visualCartProductID: Int!, visualCartID: Int!, visualProductID: Int!, visualCartProductQty: Int!, visualCartTotalPrice: Double!, visualProductName: String!, visualProductPrice: Double!, visualProductImage: String!) {
        self.visualCartProductID = visualCartProductID
        self.visualCartID = visualCartID
        self.visualProductID = visualProductID
        self.visualCartProductQty = visualCartProductQty
        self.visualCartTotalPrice = visualCartTotalPrice
        self.visualProductName = visualProductName
        self.visualProductPrice = visualProductPrice
        self.visualProductImage = visualProductImage
    }
}
