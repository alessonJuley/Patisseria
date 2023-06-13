//
//  RegularCartTableViewController.swift
//  CartDemo
//
//  Created by Alesson Abao on 26/05/23.
//

import UIKit
import SQLite3
import Braintree
import BraintreeDropIn

//MARK: MODIFIED --------
var totalPriceInCart: Double = 0        // dont delete this is for total

class RegularCartTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, BTDropInControllerDelegate  {
    
    
    // MARK: Variables
    // object that will hold all the data
    var cartProduct = [CartProductHolder]() // dont delete this is for showing all the products in cart
    var selectedCartProductID: Int = 0      // dont delete this is for delete function
    let braintreeClient = BTAPIClient(authorization: "sandbox_bnq4zk5x_j42yvqb3fdx5n6ny")
    
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
            paymentModal(clientTokenOrTokenizationKey: "sandbox_bnq4zk5x_j42yvqb3fdx5n6ny")
            
            //MARK: MODIFIED --------
            //            if let vc = self.storyboard?.instantiateViewController(withIdentifier: "ApplePay") as? ApplePayViewController{
            //                //present the ApplePayViewController as a bottomsheet
            //                if let sheet = vc.sheetPresentationController {
            //                    //sets the height on how much you can extend it
            //                    sheet.detents = [.medium(), .medium()]
            //                    //size will remain and will not expand
            //                    sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            //                    sheet.preferredCornerRadius = 24
            //                    //horizontal line on the top
            //                    sheet.prefersGrabberVisible = true
            //                }
            //                //present the ViewController
            //                self.navigationController?.present(vc, animated: true)
            //            }
            //
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
                    showMessage(message: "Your reference number is \(referenceNum). To pay: $ \(totalPriceInCart). Complete Paypal integration will be integrated in the future.", buttonCaption: "Close", controller: self!)
                    
                }
            }
        }.resume()
        // removes all the object
        cartProduct.removeAll()
        regularCartTableView.reloadData()
        cartProductTotal.text = "$0.0"
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
    
    //For paypal delegates
    func reloadDropInData() {
        print("Reload Drop-In data")
    }
    
    func editPaymentMethods(_ sender: Any) {
        print("Edit Drop-In data")
    }
    
}
