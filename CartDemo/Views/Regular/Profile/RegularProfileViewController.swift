//
//  RegularProfileViewController.swift
//  CartDemo
//
//  Created by Alesson Abao on 10/06/23.
//

import UIKit
import SQLite3

class RegularProfileViewController: UIViewController {
    
    // MARK: Variables
    var firstNameHolder = ""
    var lastNameHolder = ""
    var emailHolder = ""
    
    // MARK: Outlets
    @IBOutlet weak var regularProfileFirstName: UILabel!
    @IBOutlet weak var regularProfileLastName: UILabel!
    @IBOutlet weak var regularProfileEmail: UILabel!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // setupProfile()
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
    
        regularProfileFirstName.text = firstNameHolder
        regularProfileLastName.text = lastNameHolder
        regularProfileEmail.text = emailHolder
    }
    
    // MARK: Action
    @IBAction func regularProfileLogoutButton(_ sender: UIButton) {
        // maybe change the status of session here
        let controller = storyboard?.instantiateViewController(withIdentifier: "LoginNC") as! UINavigationController
        controller.modalPresentationStyle = .fullScreen
        controller.modalTransitionStyle = .coverVertical
        present(controller, animated: true, completion: nil)
        
        //Clear currentLoggedInUser
        currentUserLoggedInID = 0
    }
}
