//
//  AdminLandingViewController.swift
//  CartDemo
//
//  Created by Alesson Abao on 10/06/23.
//

import UIKit

class AdminLandingViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func adminLogoutButton(_ sender: UIButton) {
        let controller = storyboard?.instantiateViewController(withIdentifier: "LoginNC") as! UINavigationController
        controller.modalPresentationStyle = .fullScreen
        controller.modalTransitionStyle = .coverVertical
        present(controller, animated: true, completion: nil)
        
        //Clear currentLoggedInUser
        currentUserLoggedInID = 0
    }
}
