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
        // maybe change the status of session here
        let controller = storyboard?.instantiateViewController(withIdentifier: "LoginNC") as! UINavigationController
        controller.modalPresentationStyle = .fullScreen
        controller.modalTransitionStyle = .coverVertical
        present(controller, animated: true, completion: nil)
    }
    
}
