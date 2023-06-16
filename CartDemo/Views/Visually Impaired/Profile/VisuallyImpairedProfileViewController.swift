//
//  VisuallyImpairedProfileViewController.swift
//  CartDemo
//
//  Created by Alesson Abao on 11/06/23.
//

import UIKit
import SQLite3

class VisuallyImpairedProfileViewController: UIViewController {
    
    // MARK: Variables
    var firstNameHolder = ""
    var lastNameHolder = ""
    var emailHolder = ""
    
    // MARK: Outlets
    
    @IBOutlet weak var visualProfileFirstName: UILabel!
    @IBOutlet weak var visualProfileLastName: UILabel!
    @IBOutlet weak var visualProfileEmail: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(_ animated: Bool) {
        setupProfile()
    }
    
    func setupProfile(){
        let selectUser = "SELECT firstName, lastName, useremail FROM User WHERE userID = \(currentUserLoggedInID)"
        
        print("This is currenUserLoggedInID in setupProfile: \(currentUserLoggedInID)")
        var selectUserQuery: OpaquePointer?

        if sqlite3_prepare_v2(dbQueue, selectUser, -1, &selectUserQuery, nil) == SQLITE_OK{
            while sqlite3_step(selectUserQuery) == SQLITE_ROW{
                let firstNameDb = String(cString:sqlite3_column_text(selectUserQuery, 0))
                let lastNameDb = String(cString:sqlite3_column_text(selectUserQuery, 1))
                let emailDb = String(cString:sqlite3_column_text(selectUserQuery, 2))

                firstNameHolder = firstNameDb
                lastNameHolder = lastNameDb
                emailHolder = emailDb
            }
            sqlite3_finalize(selectUserQuery)
        }
    
        visualProfileFirstName.text = firstNameHolder
        visualProfileLastName.text = lastNameHolder
        visualProfileEmail.text = emailHolder
    }

    // MARK: Action
    @IBAction func visualLogoutButton(_ sender: UIButton) {
        navigationMessage(msg: "Are you sure you want to log out?", viewController: self)
    }
}

//function to navigate to home
func navigationMessage(msg: String, viewController:UIViewController){

    let alert = UIAlertController(title: "", message: msg , preferredStyle: .alert)
    let action = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "LoginNC") as! UINavigationController
        controller.modalPresentationStyle = .fullScreen
        controller.modalTransitionStyle = .coverVertical
        viewController.present(controller, animated: true, completion: nil)
                
        //Clear currentLoggedInUser
        currentUserLoggedInID = 0
            //for validation
        print("OK button tapped")
       
    })

    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            alert.dismiss(animated: true, completion: nil)
            
            // For validation
            print("Cancel button tapped")
        }
    //adding the buttons
    alert.addAction(action)
    alert.addAction(cancelAction)
    //presenting the alert message
    viewController.present(alert, animated: true, completion: nil)
}
