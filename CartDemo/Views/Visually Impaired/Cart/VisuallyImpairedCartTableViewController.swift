//
//  VisuallyImpairedCartTableViewController.swift
//  CartDemo
//
//  Created by Alesson Abao on 11/06/23.
//

import UIKit
import SQLite3
import Braintree
import BraintreeDropIn

class VisuallyImpairedCartTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, BTDropInControllerDelegate {
    
    
    // MARK: Variables
    // object that will hold all the data
    var visualCartProduct = [VisualCartProductHolder]() // dont delete this is for showing all the products in cart
    var visualSelectedCartProductID: Int = 0      // dont delete this is for delete function
    var visualTotalPriceInCart: Double = 0        // dont delete this is for total
    let braintreeClient = BTAPIClient(authorization: "sandbox_bnq4zk5x_j42yvqb3fdx5n6ny")
    
    // MARK: Outlets
    @IBOutlet weak var visualCartTableView: UITableView!
    @IBOutlet weak var visualCartProductTotal: UILabel!
    
    // MARK: DB variables
    let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        visualCartProduct.removeAll()
        
        visualCartTableView.dataSource = self
        visualCartTableView.delegate = self
        
        loadCartProducts()  // important if you want to keep state of cart
        
        visualCartProductTotal.text = "$" + String(visualTotalPriceInCart)
        visualCartTableView.reloadData()
    }
    
    @IBAction func visualCheckout(_ sender: UIButton) {
        // Function description:
        // If there's no object appended from the db, there's no product so you cannot checkout
        // else, delete the cartProduct rows and update the cart table's cartTotalPrice and state of isCheckedOut
        
        if(visualCartProduct.count == 0){
            showMessage(message: "Cannot checkout with empty cart.", buttonCaption: "Please put products in cart", controller: self)
        }
        else{
            paymentModal(clientTokenOrTokenizationKey: "sandbox_bnq4zk5x_j42yvqb3fdx5n6ny")
        }
    }
    
    func paymentModal(clientTokenOrTokenizationKey: String) {
        let request = BTDropInRequest()
        let dropIn = BTDropInController(authorization: clientTokenOrTokenizationKey, request: request) { [weak self] (controller, result, error) in
            guard let self = self else { return }
            
            if let error = error {
                print("Error: \(error.localizedDescription)")
            } else if let result = result {
                if result.isCanceled {
                    print("Payment Cancelled")
                } else if (result.paymentMethod?.nonce) != nil {
                    // Payment succeeded, post the payment method nonce to server
                    if let paymentMethodNonce = result.paymentMethod?.nonce {
                        // Retrieve the payment amount
                        let paymentAmount = totalPriceInCart
                        
                        // Post the payment method nonce and amount to server
                        postNonceToServer(paymentMethodNonce: paymentMethodNonce, amount: paymentAmount)
                    }
                }
                
                //                let paymentMethodType = result.paymentMethodType
                //                let paymentMethod = result.paymentMethod
                //                let paymentDescription = result.paymentDescription
                //
                
            }
            controller.dismiss(animated: true, completion: nil)
        }
        self.present(dropIn!, animated: true)
    }
    
    
    func postNonceToServer(paymentMethodNonce: String, amount: Double) {
        // Attempted server URL
        let paymentURLString = "https://patisserie-new-zealand.glitch.me/process-payment"
        
        let requestBody = "payment_method_nonce=\(paymentMethodNonce)&amount=\(amount)"
        
        guard let paymentURL = URL(string: paymentURLString) else {
            print("Invalid server URL")
            return
        }
        
        var request = URLRequest(url: paymentURL)
        request.httpBody = requestBody.data(using: .utf8)
        request.httpMethod = "POST"
        
        URLSession.shared.dataTask(with: request) { [weak self] (data, response, error) in
            guard self != nil else { return }
            
            if let error = error {
                print("Error in URL: \(error.localizedDescription)")
                return
            }
            
            if let response = response as? HTTPURLResponse {
                //                if response.statusCode == 200 {
                //                    print("Payment success")
                //                } else {
                //                    //print("Payment failed in URL. Status code: \(response.statusCode)")
                //                }
                let referenceNum = Int(arc4random_uniform(6) + 1)
                DispatchQueue.main.async {
                    showMessage(message: "Your reference number is \(referenceNum). To pay: $ \(self!.visualTotalPriceInCart). Complete Paypal integration will be integrated in the future.", buttonCaption: "Close", controller: self!)
                }
            }
        }.resume()
        // removes all the object
        visualCartProduct.removeAll()
        visualCartTableView.reloadData()
        visualCartProductTotal.text = "$0.0"
    }
    
    // ********************************CLEAR CODE****************************************
    // MARK: TableView Area
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return visualCartProduct.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = visualCartTableView.dequeueReusableCell(withIdentifier: "visualCartCell", for: indexPath) as! VisuallyImpairedTableViewCell
        
        let thisCartProduct = visualCartProduct[indexPath.row]
        
        cell.visualCartProductQty.text = "x" + String(thisCartProduct.visualCartProductQty)
        cell.visualCartProductName.text = thisCartProduct.visualProductName
        cell.visualCartProductPrice.text = "$" + (String)(thisCartProduct.visualProductPrice)
        cell.visualCartProductImage.image = UIImage(named: thisCartProduct.visualProductImage)
        
        let urlText = thisCartProduct.visualProductImage
        
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
                        cell.visualCartProductImage.image = imageProd
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
        let selectedProduct = visualCartProduct[indexPath.row]
        visualSelectedCartProductID = selectedProduct.visualCartProductID
        
        if editingStyle == .delete{
            // delete from sqlite
            let deleteProductStatementString = "DELETE FROM CartProduct WHERE cartProductID = \(visualSelectedCartProductID)"
            var deleteStatementQuery: OpaquePointer?
            
            if sqlite3_prepare_v2(dbQueue, deleteProductStatementString, -1, &deleteStatementQuery, nil) == SQLITE_OK {
                
                if sqlite3_step(deleteStatementQuery) == SQLITE_DONE {
                    print("Successfully deleted product 🥳")
                    visualCartProduct.remove(at: indexPath.row) // Remove the product from the array after successful deletion from SQLite
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
        visualTotalPriceInCart = 0.0
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
                visualTotalPriceInCart += totalPerProduct
                print("[loadCartProducts] totalPriceInCart: \(visualTotalPriceInCart)")
                
                let savedCartProduct = VisualCartProductHolder(
                    visualCartProductID: cartProductID,
                    visualCartID: cartID,
                    visualProductID: productID,
                    visualCartProductQty: cartProductQty,
                    visualCartTotalPrice: totalPerProduct,
                    visualProductName: productName,
                    visualProductPrice: productPrice,
                    visualProductImage: productImage
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
                visualCartProduct.append(savedCartProduct)
                // ==========================FOR TESTING==========================
            }
            sqlite3_finalize(selectStatementQuery)
        }
        
        visualCartTableView.reloadData()
    }
    
    
    //For paypal delegates
    func reloadDropInData() {
        print("Reload Drop-In data")
    }
    
    func editPaymentMethods(_ sender: Any) {
        print("Edit Drop-In data")
    }
    // ============================SQL LOAD SAVED PRODUCTS END===========================
    // ****************************CLEAR CODE****************************************
}
