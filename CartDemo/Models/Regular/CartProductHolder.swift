//
//  CartProductHolder.swift
//  CartDemo
//
//  Created by Alesson Abao on 27/05/23.
//  used in regular carttable

import Foundation

class CartProductHolder{
    
    var cartProductID: Int!
    var cartID: Int!
    var productID: Int!
    var cartProductQty: Int!
    var cartTotalPrice: Double!
    var productName: String!
    var productPrice: Double!
    var productImage: String!
    
    public init(cartProductID: Int!, cartID: Int!, productID: Int!, cartProductQty: Int!, cartTotalPrice: Double!, productName: String!, productPrice: Double!, productImage: String!) {
        self.cartProductID = cartProductID
        self.cartID = cartID
        self.productID = productID
        self.cartProductQty = cartProductQty
        self.cartTotalPrice = cartTotalPrice
        self.productName = productName
        self.productPrice = productPrice
        self.productImage = productImage
    }
}
