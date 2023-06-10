//
//  RegularHomeProductDetailViewController.swift
//  CartDemo
//
//  Created by Alesson Abao on 26/05/23.
//  important view controller and this connects to cart page

import UIKit
import SQLite3

var currentCartID: Int32 = 0        // don't remove this
var cartProductID: Int32 = 0        // don't remove this

class RegularHomeProductDetailViewController: UIViewController {
    
    // MARK: DB variables
    let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
    
    // MARK: Outlets
    @IBOutlet weak var regularHomeProductImage: UIImageView!
    @IBOutlet weak var regularHomeProductName: UILabel!
    @IBOutlet weak var regularHomeProductPrice: UILabel!
    @IBOutlet weak var regularHomeProductCategory: UILabel!
    @IBOutlet weak var regularHomeProductDescription: UILabel!
    @IBOutlet weak var regularHomeProductQty: UILabel!
    @IBOutlet weak var addProductButton: UIButton!
    @IBOutlet weak var wishlistButton: UIButton!
    
    // MARK: Variables
    var selectedProduct : ProductHolder!
    var selectedProductID: Int = 0
    
    var regularHomeProductQtyCount: Int = 0
    var productPriceHolder: Double = 0          // don't remove: for total
    // var totalProductButton: Double = 1.00       // if you want add to cart button to show subtotal
    
    // ================WISHLIST================
    var wishButtonIsPressed: Bool = false       // uncomment when you need to do wishlist
    // ================WISHLIST================
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set outlet values to selectedProduct info
        // regularHomeProductImage.image = UIImage(named: selectedProduct.productImage)
        
        // make image autoload
        let productImageURL = selectedProduct.productImage
        let urlText = productImageURL!
        
        let imgURL = URL(string: urlText)
        // make URL request object to send over the network
        let urlRequest = URLRequest(url: imgURL!)
        
        let task = URLSession.shared.dataTask(with: urlRequest)
        {
            (data,response,error)
            in
            if(error == nil)
            {
                let picData = try! Data(contentsOf: imgURL!)
                let imageProd = UIImage(data: picData)
                
                DispatchQueue.main.async { // [self] in
                    self.regularHomeProductImage.image = imageProd
                }
            }
        }
        task.resume()
        
        regularHomeProductName.text = selectedProduct.productName
        regularHomeProductPrice.text = "$" + (String)(selectedProduct.productPrice)
        regularHomeProductCategory.text = selectedProduct.productCategory
        regularHomeProductDescription.text = selectedProduct.productDescription
        
        // for insert to cart variables
        selectedProductID = selectedProduct.productID
        productPriceHolder = selectedProduct.productPrice
        
        regularHomeProductQtyCount = 0
    }
    
    // MARK: Actions
    @IBAction func addProductToCartButton(_ sender: UIButton) {
        // Once user clicks the add to cart button from productdetails:
        // 1. Check if the current user has a cart (when user just logged in)
        //          if usertHasCart == false
        //              startCartForUser        (this creates a row inside Cart table where the userID == currentUserLoggedIn)
        //              insert product to cart  (products that will show up in Cart page)
        // 2. When user has a cart, we should check if the product is already in the cart
        //          if productIsInCart == false
        //              insert CartProduct
        //          else
        //              update CartProduct
        
        // ===================FOR TESTING===================
        print("=================")
        print("=================")
        print("=================")
        print("addProductToCartButton PRESSED")
        print("=================")
        print("=================")
        print("=================")
        // ===================FOR TESTING===================
        // check if user has cart
        if (userHasCart() == false){
            startCartForUser()
            currentCartID = getCartID()     // transfer value of cartID to currentCartID
            
            // ===================FOR TESTING===================
            // user doesn't have cart
            print("userHasCart == false")
            print("=================")
            print("=================")
            print("=================")
            print("this is currentCartID in addProductToCartButton inside userHasCart() == false: \(currentCartID)")
            print("=================")
            print("=================")
            print("=================")
            // ===================FOR TESTING===================
            // if qty 0 dont insert, else insert
            
            if(Int(regularHomeProductQty.text!) == 0){
                showMessage(message: "Quantity is 0. Increase quantity to add to cart.", buttonCaption: "Close", controller: self)
            }
            else{
                let insertCartProductString = "INSERT INTO CartProduct (cartID, productID, cartProductQty) VALUES (?,?,?)"
                var insertCartProductStatementQuery: OpaquePointer?

                if sqlite3_prepare_v2(dbQueue, insertCartProductString, -1, &insertCartProductStatementQuery, nil) == SQLITE_OK {
                    // bind values here
                    sqlite3_bind_int(insertCartProductStatementQuery, 1, currentCartID)
                    sqlite3_bind_int(insertCartProductStatementQuery, 2, Int32(selectedProductID))
                    sqlite3_bind_int(insertCartProductStatementQuery, 3, Int32(regularHomeProductQtyCount))


                    if(sqlite3_step(insertCartProductStatementQuery)) == SQLITE_DONE{
                        print("[RegularHomeProductDetailViewController.swift>INSERT INTO CartProduct] CartProduct added 🥳")
                    }
                    else{
                        print("[RegularHomeProductDetailViewController.swift>INSERT INTO CartProduct] Failed adding CartProduct 🙁")
                    }
                    sqlite3_finalize(insertCartProductStatementQuery)
                }
            }
            // =================TEST PASS DATA BETWEEN TAB BAR CONTROLLERS=================
        }
        else{
            // ===================FOR TESTING===================
            // user has cart
            print("userHasCart == true")
            // ===================FOR TESTING===================
            if(Int(regularHomeProductQty.text!) == 0){
                showMessage(message: "Quantity is 0. Increase quantity to add to cart.", buttonCaption: "Close", controller: self)
            }
            else{
                // check if the product you are adding in the currentCartID is in CartProductTable
                if (productIsInCart() == false){
                    currentCartID = getCartID()     // transfer cartID to currentCartID
                    
                    // ===================FOR TESTING===================
                    print("this is currentCartID in userHasCart == true && productIsInCart() == false: \(currentCartID)")
                    // INSERT INTO CartProduct
                    print("productIsInCart() == false")
                    // ===================FOR TESTING===================
                    
                    // if product is not present in cart, insert product to CartProduct table
                    let insertCartProductString = "INSERT INTO CartProduct (cartID, productID, cartProductQty) VALUES (?,?,?)"
                    var insertCartProductStatementQuery: OpaquePointer?
                    
                    if sqlite3_prepare_v2(dbQueue, insertCartProductString, -1, &insertCartProductStatementQuery, nil) == SQLITE_OK {
                        
                        // bind values here
                        sqlite3_bind_int(insertCartProductStatementQuery, 1, currentCartID)
                        sqlite3_bind_int(insertCartProductStatementQuery, 2, Int32(selectedProductID))
                        sqlite3_bind_int(insertCartProductStatementQuery, 3, Int32(regularHomeProductQtyCount))
                        
                        if(sqlite3_step(insertCartProductStatementQuery)) == SQLITE_DONE{
                            print("[RegularHomeProductDetailViewController.swift>INSERT INTO CartProduct && productIsInCart() == false] CartProduct added 🥳")
                        }
                        else{
                            print("[RegularHomeProductDetailViewController.swift>INSERT INTO CartProduct && productIsInCart() == false] Failed adding CartProduct 🙁")
                        }
                        sqlite3_finalize(insertCartProductStatementQuery)
                    }
                }
                else{
                    currentCartID = getCartID()     // transfer cartID to currentCartID
                    
                    // ===================FOR TESTING===================
                    print("this is currentCartID in userHasCart == true && productIsInCart() == true: \(currentCartID)")
                    // UPDATE CartProduct
                    print("productIsInCart() == true")
                    // ===================FOR TESTING===================
                    // UPDATE INTO CartProduct
                    // "CartProduct (cartProductID, cartID, productID, cartProductQty)"
                    let updateCartProductString = "UPDATE CartProduct SET cartProductQty = \(regularHomeProductQtyCount) WHERE cartID = \(currentCartID) AND productID = \(selectedProductID)"
                    var updateCartProductStatementQuery: OpaquePointer?
                    // ===================FOR TESTING===================
                    // var showCartIDData = ""
                    // ===================FOR TESTING===================
                    if sqlite3_prepare_v2(dbQueue, updateCartProductString, -1, &updateCartProductStatementQuery, nil) == SQLITE_OK {
                        
                        if(sqlite3_step(updateCartProductStatementQuery)) == SQLITE_DONE{
                            print("[RegularHomeProductDetailViewController.swift>UPDATE CartProduct] CartProduct updated 🥳")
                        }
                        else{
                            print("[RegularHomeProductDetailViewController.swift>UPDATE CartProduct] Failed updating CartProduct 🙁")
                        }
                        sqlite3_finalize(updateCartProductStatementQuery)
                    }
                }
            }
        }
    }
    
    // MARK: getCartProductID
    func getCartProductID() -> Int32{
        
        print("=================")
        print("=================")
        print("=================")
        print("this is cartProductID in getCartProductID: \(cartProductID)")
        print("=================")
        print("=================")
        print("=================")
        
        // SELECT Cart
        let selectCartString = "SELECT cartproductID, cartID, productID, cartProductQty FROM CartProduct WHERE cartproductID = \(cartProductID) AND cartID = \(currentCartID)"
        var selecrCartStatementQuery: OpaquePointer?
        var cartID: Int32 = 0
        
        if sqlite3_prepare_v2(dbQueue, selectCartString, -1, &selecrCartStatementQuery, nil) == SQLITE_OK {
            while sqlite3_step(selecrCartStatementQuery) == SQLITE_ROW{
                cartID = Int32(sqlite3_column_int(selecrCartStatementQuery, 0))
            }
        }
        return cartID
    }
    
    // MARK: getCartID()
    func getCartID() -> Int32{
        
        print("=================")
        print("=================")
        print("=================")
        print("this is currentUserLoggedInID in getCartID: \(currentUserLoggedInID)")
        print("=================")
        print("=================")
        print("=================")
        
        // SELECT Cart
        let selectCartString = "SELECT cartID, userID, isCheckedOut FROM Cart WHERE userID = \(currentUserLoggedInID) AND isCheckedOut = 'false'"
        var selecrCartStatementQuery: OpaquePointer?
        var cartID: Int32 = 0
        
        if sqlite3_prepare_v2(dbQueue, selectCartString, -1, &selecrCartStatementQuery, nil) == SQLITE_OK {
            while sqlite3_step(selecrCartStatementQuery) == SQLITE_ROW{
                cartID = Int32(sqlite3_column_int(selecrCartStatementQuery, 0))
            }
        }
        return cartID
    }
    
    // MARK: startCartForUser
    func startCartForUser(){
        // INSERT INTO Cart
        let startCartForUserString = "INSERT INTO Cart (userID, cartTotalPrice, isCheckedOut) VALUES (?,?,?)"
        var startCartForUserStatementQuery: OpaquePointer?
        // ===================FOR TESTING===================
        // var showCartIDData = ""
        // ===================FOR TESTING===================
        if sqlite3_prepare_v2(dbQueue, startCartForUserString, -1, &startCartForUserStatementQuery, nil) == SQLITE_OK {
            // bind values here
            let userID = currentUserLoggedInID
            let cartTotalPriceInit = Double(0.00)
            let isCheckedOutInit = "false"
            
            sqlite3_bind_int(startCartForUserStatementQuery, 1, userID)
            sqlite3_bind_double(startCartForUserStatementQuery, 2, cartTotalPriceInit)
            sqlite3_bind_text(startCartForUserStatementQuery, 3, isCheckedOutInit, -1, SQLITE_TRANSIENT)
            
            if(sqlite3_step(startCartForUserStatementQuery)) == SQLITE_DONE{
                print("[RegularHomeProductDetailViewController.swift>startCartForUser] Cart added for user 🥳")
            }
            else{
                print("[RegularHomeProductDetailViewController.swift>startCartForUser] Failed adding cart for user 🙁")
            }
            sqlite3_finalize(startCartForUserStatementQuery)
        }
    }
    
    // MARK: productIsInCart
    func productIsInCart() -> Bool{
        var checkStatus : Bool = false
        
        print("=================")
        print("=================")
        print("=================")
        print("this is selectedProductID in productIsInCart: \(selectedProductID)")
        print("this is currentCartID in productIsInCart: \(currentCartID)")
        print("=================")
        print("=================")
        print("=================")
        
        let getCartProductTableRowsString = "SELECT count(cartProductID) FROM CartProduct WHERE productID = \(selectedProductID) AND cartID = \(currentCartID)"
        
        var getCartProductTableRowsStatementQuery: OpaquePointer?
        var cartProductRowCount: Int32 = 0
        // ===================FOR TESTING===================
        var showProductIsInCartData = ""
        // ===================FOR TESTING===================
        
        if sqlite3_prepare_v2(dbQueue, getCartProductTableRowsString, -1, &getCartProductTableRowsStatementQuery, nil) == SQLITE_OK {
            while sqlite3_step(getCartProductTableRowsStatementQuery) == SQLITE_ROW{
                cartProductRowCount = Int32(sqlite3_column_int(getCartProductTableRowsStatementQuery, 0))
                
                // ===================FOR TESTING===================
                let numberOfRowsInCartProduct = "This is cartProductRowCount productIsInCart: \(cartProductRowCount)"
                showProductIsInCartData += numberOfRowsInCartProduct
                print(showProductIsInCartData)
                // ===================FOR TESTING===================
                
                if cartProductRowCount == 0{
                    print("[RegularHomeProductDetailViewController.swift>productIsInCart] Product isn't in CartProduct 🙁")
                    checkStatus = false
                }
                else{
                    print("[RegularHomeProductDetailViewController.swift>productIsInCart] Product is in CartProduct 🥳")
                    checkStatus = true
                }
            }
            sqlite3_finalize(getCartProductTableRowsStatementQuery)
        }
        else{
            print("[RegularHomeProductDetailViewController.swift>productIsInCart] getCartProductTableRowsString failed 🙁")
            checkStatus = false
        }
        
        return checkStatus
    }
    
    // MARK: userHasCart
    func userHasCart() -> Bool{
        var checkStatus : Bool = false
        
        print("=================")
        print("=================")
        print("=================")
        print("this is currentUserLoggedInID in userHasCart [userID for cart table]: \(currentUserLoggedInID)")
        print("=================")
        print("=================")
        print("=================")
        
        let getCartTableRowsString = "SELECT count(cartID) FROM Cart WHERE userID = \(currentUserLoggedInID) AND isCheckedOut = 'false'"
        var getCartTableRowsStatementQuery: OpaquePointer?
        var cartRowCount: Int32 = 0
        // ===================FOR TESTING===================
        var showUserHasCartData = ""
        // ===================FOR TESTING===================
        
        if sqlite3_prepare_v2(dbQueue, getCartTableRowsString, -1, &getCartTableRowsStatementQuery, nil) == SQLITE_OK {
            while sqlite3_step(getCartTableRowsStatementQuery) == SQLITE_ROW{
                cartRowCount = Int32(sqlite3_column_int(getCartTableRowsStatementQuery, 0))
                
                // ===================FOR TESTING===================
                let numberOfRowsInCart = "This is cartRowCount: \(cartRowCount)"
                showUserHasCartData += numberOfRowsInCart
                print(showUserHasCartData)
                // ===================FOR TESTING===================
                
                if cartRowCount == 0{
                    print("[RegularHomeProductDetailViewController.swift>userHasCart] User doesn't have current Cart🥳")
                    checkStatus = false
                }
                else{
                    print("[RegularHomeProductDetailViewController.swift>userHasCart] User has current Cart 🙁")
                    checkStatus = true
                }
            }
            sqlite3_finalize(getCartTableRowsStatementQuery)
        }
        else{
            print("[RegularHomeProductDetailViewController.swift>userHasCart] getCartTableRowsString failed 🙁")
            checkStatus = false
        }
        
        return checkStatus
    }
    
    // MARK: Wishlist
    @IBAction func addProductWishlistButton(_ sender: UIButton) {
        // Function description:
        //  When user press the button the setImage will be changed to heart.fill
        //  Then the product info will be inserted to WishList table with the connection of who the user is
        print("================================")
        print("================================")
        print("================================")
        print("addProductWishlistButton PRESEED")
        wishlistButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        
        if(checkProductIsInWishList() == false){
            let insertWishProduct = "INSERT INTO WishList (wishUserID, wishProductName, wishProductDescription, wishProductCategory, wishProductPrice, wishProductImage) VALUES (?, ?, ?, ?, ?, ?)"
            var insertWishProductQuery: OpaquePointer?
            
            if sqlite3_prepare_v2(dbQueue, insertWishProduct, -1, &insertWishProductQuery, nil) == SQLITE_OK {

                let wishUserID = currentUserLoggedInID
                let wishProductName = regularHomeProductName.text!
                let wishProductDescription = regularHomeProductDescription.text!
                let wishProductCategory = regularHomeProductCategory.text!
                let wishProductPrice = selectedProduct.productPrice!
                let wishProductImage = selectedProduct.productImage!
                
                print("this is inside if values:\n wishUserID: \(wishUserID)\n wishProductName: \(wishProductName)\n wishProductDescription: \(wishProductDescription)\n wishProductCategory:\(wishProductCategory)\n wishProductPrice: \(wishProductPrice)\n wishProductImage:\(String(describing: wishProductImage))")
                
                // bind values here
                sqlite3_bind_int(insertWishProductQuery, 1, wishUserID)
                sqlite3_bind_text(insertWishProductQuery, 2, wishProductName, -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(insertWishProductQuery, 3, wishProductDescription, -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(insertWishProductQuery, 4, wishProductCategory, -1, SQLITE_TRANSIENT)
                sqlite3_bind_double(insertWishProductQuery, 5, wishProductPrice)
                sqlite3_bind_text(insertWishProductQuery, 6, wishProductImage, -1, SQLITE_TRANSIENT)
                
                if(sqlite3_step(insertWishProductQuery)) == SQLITE_DONE{
                    // ====================FOR TESTING====================
                    print("wishUserID: \(wishUserID) \n wishProductName: \(wishProductName)\n wishProductDescription:\(wishProductDescription)\n wishProductCategory:\(wishProductCategory)\n wishProductPrice: \(wishProductPrice)")
                    // ====================FOR TESTING====================
                    print("[RegularHomeProductDetailViewController.swift>addProductWishlistButton] Product added to wishlist 🥳")
                }
                else{
                    print("[RegularHomeProductDetailViewController.swift>addProductWishlistButton] Product not added to wishlist 😔")
                }
                
                sqlite3_finalize(insertWishProductQuery)
            }
        }
        else{
            showMessage(message: "Product is already in Wish list", buttonCaption: "Visit wish list page", controller: self)
        }
    }
    
    func checkProductIsInWishList() -> Bool{
        var checkStatus: Bool = false
        
        let wishProductName = regularHomeProductName.text!
        
        print("This is wishProductName in checkProductIsInWishList: \(wishProductName)")
        
        let getWishListTableRowsString = "SELECT count(wishID) FROM WishList WHERE wishUserID = \(currentUserLoggedInID) AND wishProductName = '\(wishProductName)'"
        var getWishListTableRowsStatementQuery: OpaquePointer?
        
        var wishRowCount: Int32 = 0
        // ===================FOR TESTING===================
        var showUserHasCartData = ""
        // ===================FOR TESTING===================
        
        if sqlite3_prepare_v2(dbQueue, getWishListTableRowsString, -1, &getWishListTableRowsStatementQuery, nil) == SQLITE_OK {
            while sqlite3_step(getWishListTableRowsStatementQuery) == SQLITE_ROW{
                wishRowCount = Int32(sqlite3_column_int(getWishListTableRowsStatementQuery, 0))
                
                // ===================FOR TESTING===================
                let numberOfRowsInCart = "This is cartRowCount: \(wishRowCount)"
                showUserHasCartData += numberOfRowsInCart
                print(showUserHasCartData)
                // ===================FOR TESTING===================
                
                if wishRowCount == 0{
                    print("[RegularHomeProductDetailViewController.swift>checkProductIsInWishList] Product isn't in WishList🥳")
                    checkStatus = false
                }
                else{
                    print("[RegularHomeProductDetailViewController.swift>checkProductIsInWishList] Product is in WishList🙁")
                    checkStatus = true
                }
            }
            sqlite3_finalize(getWishListTableRowsStatementQuery)
        }
        else{
            print("[RegularHomeProductDetailViewController.swift>checkProductIsInWishList] getWishListTableRowsString failed 🙁")
            checkStatus = false
        }
        
        return checkStatus
    }
    
    @IBAction func regularHomeProductQtyDecrement(_ sender: UIButton) {
        if regularHomeProductQtyCount != 0{
            regularHomeProductQtyCount -= 1
            self.regularHomeProductQty.text = (String)(regularHomeProductQtyCount)
        }
        else{
            regularHomeProductQtyCount = 0
            self.regularHomeProductQty.text = (String)(regularHomeProductQtyCount)
        }
        
        // update button title based on qty
        addProductButton.setTitle("Add \(regularHomeProductQtyCount) to cart", for: .normal)
        
    }
    
    @IBAction func regularHomeProductQtyIncrement(_ sender: UIButton) {
        if regularHomeProductQtyCount == 0{
            regularHomeProductQtyCount += 1
            self.regularHomeProductQty.text = (String)(regularHomeProductQtyCount)
        }
        else{
            regularHomeProductQtyCount += 1
            self.regularHomeProductQty.text = (String)(regularHomeProductQtyCount)
        }
        
        // update button title based on qty
        addProductButton.setTitle("Add \(regularHomeProductQtyCount) to cart", for: .normal)
    }
}
