//
//  LoginViewController.swift
//  FinalUserComponent
//
//  Created by Alesson Abao on 23/05/23.
//

import UIKit
import SQLite3

var currentUserLoggedInID: Int32 = 0        // don't remove: for cart table

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: Outlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let customColor = hexStringToUIColor(hex: "#60390f")
        
        super.viewWillAppear(animated)
        self.emailTextField.addBottomBorderWithColor1(color: customColor, textWidth: 1.0)
        self.passwordTextField.addBottomBorderWithColor1(color: customColor, textWidth: 1.0)
    }
    
    // MARK: Action Button
    @IBAction func loginButton(_ sender: UIButton) {
        let loginEmail = emailTextField.text!
        let loginPass = passwordTextField.text!
        
        var loginSuccessful = false
        
        if validateForm(){
            let selectStatementString = "SELECT userID, useremail, userpass, visuallyImpaired FROM User"
            var selectStatementQuery: OpaquePointer?
            
            // ===========================FOR TESTING===========================
            // get data
            var showData: String!
            showData = ""
            // ===========================FOR TESTING===========================
            
            if sqlite3_prepare_v2(dbQueue, selectStatementString, -1, &selectStatementQuery, nil) == SQLITE_OK {
                // this will loop through all the rows in Users table until email and pass match in the users table
                while sqlite3_step(selectStatementQuery) == SQLITE_ROW{
                    
                    // =================================FOR TESTING=================================
                    showData += "ID: " + String(cString: sqlite3_column_text(selectStatementQuery, 0)) + "\t\t" + "email: " + String(cString: sqlite3_column_text(selectStatementQuery, 1)) + "\t\t" +
                        "password: " + String(cString: sqlite3_column_text(selectStatementQuery, 2)) + "\n"
                    print(showData ?? "This is showData")
                    // =================================FOR TESTING=================================
                    
                    if(loginEmail == String(cString: sqlite3_column_text(selectStatementQuery, 1)) && loginPass == String(cString: sqlite3_column_text(selectStatementQuery, 2))){
                        // ==========================FOR TESTING==========================
                        print("===================")
                        print("===================")
                        print("===================")
                        print("this is after correct email and password")
                        // ==========================FOR TESTING==========================
                        loginSuccessful = true
                        
                        // =====================DELETE CART, CARTPRODUCT=====================
                        let deleteCartProduct = sqlite3_exec(dbQueue, "DELETE FROM CartProduct", nil, nil, nil)
                        
                        if(deleteCartProduct != SQLITE_OK){
                            print("[LoginViewController.swift>deleteCartProduct] Cannot delete CartProduct data 🙁")
                        }
                        else{
                            print("[LoginViewController.swift>deleteCartProduct] CartProduct data deleted 🥳")
                        }
                        
                        let deleteCart = sqlite3_exec(dbQueue, "DELETE FROM Cart", nil, nil, nil)
                        
                        if(deleteCart != SQLITE_OK){
                            print("[LoginViewController.swift>deleteCartProduct] Cannot delete Cart data 🙁")
                        }
                        else{
                            print("[LoginViewController.swift>deleteCartProduct] Cart data deleted 🥳")
                        }
                        
                        // reset cartID to initial so id doesn't increment everytime
                        let resetCartID = sqlite3_exec(dbQueue, "UPDATE SQLITE_SEQUENCE SET SEQ=0 WHERE NAME='Cart';", nil, nil, nil)
                        
                        if(resetCartID != SQLITE_OK){
                            print("[LoginViewController.swift>resetCartID] Cart ID unable to reset")
                        }
                        else{
                            print("[LoginViewController.swift>resetCartID] Cart ID reset")
                        }
                        
                        let resetCartProductID = sqlite3_exec(dbQueue, "UPDATE SQLITE_SEQUENCE SET SEQ=0 WHERE NAME='CartProduct';", nil, nil, nil)
                        
                        if(resetCartProductID != SQLITE_OK){
                            print("[LoginViewController.swift>resetCartID] CartProduct ID unable to reset")
                        }
                        else{
                            print("[LoginViewController.swift>resetCartID] CartProduct ID reset")
                        }
                        // =====================DELETE CART, CARTPRODUCT=====================
                        // ===========================CLEAR WISHLIST=========================
                        let resetWishList = sqlite3_exec(dbQueue, "DELETE FROM WishList", nil, nil, nil)
                        
                        if(resetWishList != SQLITE_OK){
                            print("[LoginViewController.swift>resetWishList] Cannot clear Wishlist data 🙁")
                        }
                        else{
                            print("[LoginViewController.swift>resetWishList] Wishlist data deleted 🥳")
                        }
                        // ===========================CLEAR WISHLIST=========================
                        
                        
                        // =================================ADD THIS=================================
                        if String(cString: sqlite3_column_text(selectStatementQuery, 1)) == "admin@test.com" && String(cString: sqlite3_column_text(selectStatementQuery, 2)) == "admin1234" {

                            // User is an admin, navigate to admin view controller
                            let adminViewController = storyboard?.instantiateViewController(withIdentifier: "AdminNC") as! UINavigationController
                            adminViewController.modalPresentationStyle = .fullScreen
                            adminViewController.modalTransitionStyle = .coverVertical
                            present(adminViewController, animated: true, completion: nil)

                            // Hide the back button in the regular view controller
                            navigationController?.setNavigationBarHidden(true, animated: false)
                        }
//                        else if String(cString: sqlite3_column_text(selectStatementQuery, 3)) == "Yes"{
//                            // User is an admin, navigate to admin view controller
//                            let visuallyImpairedViewController = storyboard?.instantiateViewController(withIdentifier: "VisualImpairedViewController") as! VisuallyImpairedHomeViewController
//                            navigationController?.pushViewController(visuallyImpairedViewController, animated: true)
//
//                            // Hide the back button in the regular view controller
//                            navigationController?.setNavigationBarHidden(true, animated: false)
//                        }
                        else if String(cString: sqlite3_column_text(selectStatementQuery, 3)) == "No"{
                            
                            currentUserLoggedInID += Int32(Int(sqlite3_column_int(selectStatementQuery, 0)))
                            
                            // User is not an admin, navigate to regular view controller
                            let regularViewController = self.storyboard?.instantiateViewController(withIdentifier: "RegularViewController")
                            self.navigationController?.pushViewController(regularViewController!, animated: true)

                            // Hide the back button in the regular view controller
                            navigationController?.setNavigationBarHidden(true, animated: false)
                        }
                        // =================================ADD THIS=================================
                        break
                    }
                }
                
                if(loginSuccessful){
                    // howMessage(message: "Login success", buttonCaption: "Close", controller: self)
                }
                else{
                    showMessage(message: "Login failed", buttonCaption: "Try again", controller: self)
                }
                sqlite3_finalize(selectStatementQuery)
            }
            else{
                print("============================")
                print("============================")
                print("============================")
                print("============================")
                print("[LoginViewController>loginButton] something failed. !SQLITE_OK")
            }
        }
        else{
            showMessage(message: "Email and password should not be empty.", buttonCaption: "Try again", controller: self)
        }
    }
    
    // MARK: HEX COLOR
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }

        if ((cString.count) != 6) {
            return UIColor.gray
        }

        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    // MARK: Form validation
    func validateForm() -> Bool{
        guard let email = emailTextField.text, !email.isEmpty else {
                return false
            }
        guard let password = passwordTextField.text, !password.isEmpty else{
            return false
        }
        return true // form is valid
    }
    
    // MARK: Frontend functions
    // dismiss keyboard when user clicks outside textbox
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // dismiss keyboard when user clicks return in keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        textField.resignFirstResponder()
        return true
    }
    

}
