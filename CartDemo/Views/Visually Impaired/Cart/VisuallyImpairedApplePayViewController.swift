//
//  TestingViewController.swift
//  CartDemo
//
//  Created by Nicole  on 7/06/23.
//

import UIKit
import SQLite3

class VisuallyImpairedApplePayViewController: UIViewController {

    // MARK: Outlets
    @IBOutlet weak var visualEmail: UILabel!
    @IBOutlet weak var visualTotalPrice: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        //setting the price label to the value of totalPriceInCart
        visualTotalPrice.text = "$" + String(totalPriceInCart)
        //setting the email
        visualEmail.text = userEmail
    }
    
    @IBAction func visualCancelButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func visualPayButton(_ sender: UIButton) {
        // add apple pay frontend
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
    }
}
