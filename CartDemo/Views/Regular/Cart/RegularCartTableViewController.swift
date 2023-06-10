//
//  RegularCartTableViewController.swift
//  CartDemo
//
//  Created by Alesson Abao on 26/05/23.
//

import UIKit
import SQLite3

class RegularCartTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: Variables
    // object that will hold all the data
    var cartProduct = [CartProductHolder]() // dont delete this is for showing all the products in cart
    var selectedCartProductID: Int = 0      // dont delete this is for delete function
    var totalPriceInCart: Double = 0        // dont delete this is for total
    
    @IBOutlet weak var regularCartTableView: UITableView!
    @IBOutlet weak var cartProductTotal: UILabel!
    
    // MARK: DB variables
    let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // cartProductTotal.text = "$" + String(totalPriceInCart)
    }

    override func viewDidAppear(_ animated: Bool) {
        cartProduct.removeAll()
        
        regularCartTableView.dataSource = self
        regularCartTableView.delegate = self
        
        loadCartProducts()  // important if you want to keep state of cart
        
        cartProductTotal.text = "$" + String(totalPriceInCart)
        regularCartTableView.reloadData()
    }
    
    // MARK: Checkout Button
    @IBAction func checkoutButton(_ sender: UIButton) {
        // Function description:
        // If there's no object appended from the db, there's no product so you cannot checkout
        // else, delete the cartProduct rows and update the cart table's cartTotalPrice and state of isCheckedOut
        
        if(cartProduct.count == 0){
            showMessage(message: "Cannot checkout with empty cart.", buttonCaption: "Please put products in cart", controller: self)
        }
        else{
            let referenceNum = Int(arc4random_uniform(6) + 1)
            
            showMessage(message: "Your reference number is \(referenceNum). To pay: \(totalPriceInCart)", buttonCaption: "Close", controller: self)
            
            // =====================DELETE CART, CARTPRODUCT=====================
            let deleteCartProduct = sqlite3_exec(dbQueue, "DELETE FROM CartProduct", nil, nil, nil)
    
            if(deleteCartProduct != SQLITE_OK){
                print("[LoginViewController.swift>deleteCartProduct] Cannot delete CartProduct data 🙁")
            }
            else{
                print("[LoginViewController.swift>deleteCartProduct] CartProduct data deleted 🥳")
            }
            // =====================DELETE CART, CARTPRODUCT=====================
            
            // =====================UPDATE CART, CARTPRODUCT=====================
            let addFinalTotal = sqlite3_exec(dbQueue, "UPDATE Cart SET cartTotalPrice = \(totalPriceInCart) WHERE cartID = \(currentCartID)", nil, nil, nil)
            if(addFinalTotal != SQLITE_OK){
                print("[LoginViewController.swift>addFinalTotal] Cannot add cartTotalPrice in Cart Table 🙁")
            }
            else{
                print("[LoginViewController.swift>addFinalTotal] Added cartTotalPrice in Cart Table 🥳")
            }
            
            let updateCheckOutStatus = sqlite3_exec(dbQueue, "UPDATE Cart SET isCheckedOut = 'true'", nil, nil, nil)
            
            if(updateCheckOutStatus != SQLITE_OK){
                print("[LoginViewController.swift>updateCheckOutStatus] Cannot update CartProduct checkout status 🙁")
            }
            else{
                print("[LoginViewController.swift>updateCheckOutStatus] Updated CartProduct checkout status 🥳")
            }
            // =====================UPDATE CART, CARTPRODUCT=====================
            
            cartProduct.removeAll()                 // removes all the object
            regularCartTableView.reloadData()
            cartProductTotal.text = "$0.0"
        }
    }
    
    // ********************************CLEAR CODE****************************************
    // MARK: TableView Area
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cartProduct.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = regularCartTableView.dequeueReusableCell(withIdentifier: "regularCartCell", for: indexPath) as! RegularCartTableViewCell
        
        let thisCartProduct = cartProduct[indexPath.row]
        
        cell.regularCartProductQty.text = "x" + String(thisCartProduct.cartProductQty)
        cell.regularCartProductName.text = thisCartProduct.productName
        cell.regularCartProductPrice.text = "$" + (String)(thisCartProduct.productPrice)
        cell.regularCartProductPic.image = UIImage(named: thisCartProduct.productName)
        
        let urlText = thisCartProduct.productImage
        
        let imgURL = URL(string: urlText!)
        // make URL request object to send over the network
        let urlRequest = URLRequest(url: imgURL!)

        let task = URLSession.shared.dataTask(with: urlRequest)
        {
            (data,response,error)
            in
            if(error == nil)
            {
                do{
                    let picData = try Data(contentsOf: imgURL!)
                    let imageProd = UIImage(data: picData)

                    DispatchQueue.main.async { // [self] in
                        cell.regularCartProductPic.image = imageProd
                    }
                }
                catch{
                    showMessage(message: "There was an error in loading image", buttonCaption: "Close", controller: self)
                }
            }
        }
        task.resume()
        return cell
        // ****************************CLEAR CODE****************************************
    }

    // ****************************CLEAR CODE****************************************
    // MARK: Delete
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let selectedProduct = cartProduct[indexPath.row]
        selectedCartProductID = selectedProduct.cartProductID
        
        if editingStyle == .delete{
            // delete from sqlite
            let deleteProductStatementString = "DELETE FROM CartProduct WHERE cartProductID = \(selectedCartProductID)"
            var deleteStatementQuery: OpaquePointer?
            
            if sqlite3_prepare_v2(dbQueue, deleteProductStatementString, -1, &deleteStatementQuery, nil) == SQLITE_OK {
                
                if sqlite3_step(deleteStatementQuery) == SQLITE_DONE {
                    print("Successfully deleted product 🥳")
                    cartProduct.remove(at: indexPath.row) // Remove the product from the array after successful deletion from SQLite
                    tableView.deleteRows(at: [indexPath], with: .fade)
                    tableView.reloadData()                // Update the table view
                } else {
                    print("Failed deleting product 🙁")
                }
                
                sqlite3_finalize(deleteStatementQuery)
            }
        }
    }
    // ****************************CLEAR CODE****************************************
    
    // ****************************CLEAR CODE****************************************
    // MARK: loadCartProducts
    // ============================SQL LOAD SAVED PRODUCTS START=========================
    func loadCartProducts(){
        // ==========================FOR TESTING==========================
        var showData = ""
        // ==========================FOR TESTING==========================
        totalPriceInCart = 0.0
        let selectStatementString = "SELECT CartProduct.cartProductID, CartProduct.cartID, CartProduct.productID, CartProduct.cartProductQty, ProductList.productName, ProductList.productPrice, ProductList.productImage FROM CartProduct, ProductList WHERE CartProduct.productID = ProductList.productID AND CartProduct.cartID = \(currentCartID)"
        var selectStatementQuery: OpaquePointer?
        
        if sqlite3_prepare_v2(dbQueue, selectStatementString, -1, &selectStatementQuery, nil) == SQLITE_OK {// 1
            while sqlite3_step(selectStatementQuery) == SQLITE_ROW{ // 2
                
                let cartProductID = Int(sqlite3_column_int(selectStatementQuery, 0))
                let cartID = Int(sqlite3_column_int(selectStatementQuery, 1))
                let productID = Int(sqlite3_column_int(selectStatementQuery, 2))
                let cartProductQty = Int(sqlite3_column_int(selectStatementQuery, 3))
                let productName = String(cString: sqlite3_column_text(selectStatementQuery, 4))
                let productPrice = Double(sqlite3_column_double(selectStatementQuery, 5))
                let productImage = String(cString: sqlite3_column_text(selectStatementQuery, 6))
                
                let totalPerProduct = Double(cartProductQty) * productPrice
                totalPriceInCart += totalPerProduct
                print("[loadCartProducts] totalPriceInCart: \(totalPriceInCart)")
                
                let savedCartProduct = CartProductHolder(
                    cartProductID: cartProductID,
                    cartID: cartID,
                    productID: productID,
                    cartProductQty: cartProductQty,
                    cartTotalPrice: totalPerProduct,
                    productName: productName,
                    productPrice: productPrice,
                    productImage: productImage
                )
                // ==========================FOR TESTING==========================
                let rowData = "[RegularCartTableViewController>loadCartProducts] This is cartProductDetails\n" +
                    "cartProductID: \(cartProductID) \t\t" +
                    "cartID: \(cartID) \t\t" +
                    "productID: \(productID) \t\t" +
                    "cartProductQty: \(cartProductQty) \t\t" +
                    "productName: \(productName) \t\t" +
                    "productPrice: \(productPrice) \t\t" +
                    "productImage: \(productImage) \t\t\n" +
                    "===================================================================="
                    
                showData += rowData
                
                print(showData)
                cartProduct.append(savedCartProduct)
                // ==========================FOR TESTING==========================
            }
            sqlite3_finalize(selectStatementQuery)
        }
        
        regularCartTableView.reloadData()
    }
    // ============================SQL LOAD SAVED PRODUCTS END===========================
    // ****************************CLEAR CODE****************************************
}
