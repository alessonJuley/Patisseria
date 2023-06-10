//
//  WishListViewController.swift
//  CartDemo
//
//  Created by Alesson Abao on 1/06/23.
//

import UIKit
import SQLite3

class WishListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: Variables
    var addedWishProducts = [WishProductHolder]()
    var selectedWishID: Int = 0
    
    // MARK: Outlet
    @IBOutlet weak var wishProductTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        wishProductTableView.dataSource = self
        wishProductTableView.delegate = self
        
        loadWishList()
        
        wishProductTableView.reloadData()
    }
    
    // MARK: Table View Area
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return addedWishProducts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = wishProductTableView.dequeueReusableCell(withIdentifier: "wishCell", for: indexPath) as! WishListTableViewCell
        
        let thisWish = addedWishProducts[indexPath.row]
        
        cell.wishProductName.text = thisWish.wishProductName
        cell.wishProductPrice.text = "$" + String(thisWish.wishProductPrice)
        cell.wishProductCategory.text = thisWish.wishProductCategory
        
        // make image autoload
        let productImageURL = thisWish.wishProductImage
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
                    cell.wishProductImage.image = imageProd
                }
            }
        }
        task.resume()
        
        return cell
    }
    
    // MARK: loadWishList
    func loadWishList(){
        addedWishProducts = []
        
        // ==========================FOR TESTING==========================
        var showWishListData = ""
        // ==========================FOR TESTING==========================
        
        let selectWishString = "SELECT * FROM WishList WHERE wishUserID = \(currentUserLoggedInID)"
        var selectWishQuery: OpaquePointer?
        
        if sqlite3_prepare_v2(dbQueue, selectWishString, -1, &selectWishQuery, nil) == SQLITE_OK {
            while sqlite3_step(selectWishQuery) == SQLITE_ROW{
                let wishID = Int(sqlite3_column_int(selectWishQuery, 0))
                let wishUserID = Int(sqlite3_column_int(selectWishQuery, 1))
                let wishProductName = String(cString: sqlite3_column_text(selectWishQuery, 2))
                let wishProductDescription = String(cString: sqlite3_column_text(selectWishQuery, 3))
                let wishProductCategory = String(cString: sqlite3_column_text(selectWishQuery, 4))
                let wishProductPrice = Double(sqlite3_column_double(selectWishQuery, 5))
                let wishProductImage = String(cString: sqlite3_column_text(selectWishQuery, 6))
                
                let savedWishProduct = WishProductHolder(
                    wishID: wishID,
                    wishUserID: wishUserID,
                    wishProductName: wishProductName,
                    wishProductDescription: wishProductDescription,
                    wishProductCategory: wishProductCategory,
                    wishProductPrice: wishProductPrice,
                    wishProductImage: wishProductImage
                )
                // ==========================FOR TESTING==========================
                let rowData = "[WishListViewController>loadWishList] This is loadWishList\n" +
                    "wishID: \(wishID) \t\t" +
                    "wishUserID: \(wishUserID) \t\t" +
                    "wishProductName: \(wishProductName) \t\t" +
                    "wishProductDescription: \(wishProductDescription) \t\t" +
                    "wishProductCategory: \(wishProductCategory) \t\t" +
                    "wishProductPrice: \(wishProductPrice) \t\t" +
                    "wishProductImage: \(wishProductImage) \t\t\n" +
                    "===================================================================="
                    
                showWishListData += rowData
                
                print(showWishListData)
                addedWishProducts.append(savedWishProduct)
                // ==========================FOR TESTING==========================
            }
            sqlite3_finalize(selectWishQuery)
        }
        wishProductTableView.reloadData()
    }
    
    // MARK: Product Detail Segue
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "regularWishListSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "regularWishListSegue"){
            let indexPath = self.wishProductTableView.indexPathForSelectedRow!
            let tableViewDetail = segue.destination as? WishListDetailViewController

            let selectedWishProduct = addedWishProducts[indexPath.row]
            tableViewDetail!.selectedWishProduct = selectedWishProduct
            self.wishProductTableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    // ****************************CLEAR CODE****************************************
    // MARK: Delete
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let selectedWishProduct = addedWishProducts[indexPath.row]
        selectedWishID = selectedWishProduct.wishID
        
        if editingStyle == .delete{
            // delete from sqlite
            let deleteProductStatementString = "DELETE FROM WishList WHERE wishID = \(selectedWishID)"
            var deleteStatementQuery: OpaquePointer?
            
            if sqlite3_prepare_v2(dbQueue, deleteProductStatementString, -1, &deleteStatementQuery, nil) == SQLITE_OK {
                
                if sqlite3_step(deleteStatementQuery) == SQLITE_DONE {
                    print("Successfully deleted product 🥳")
                    addedWishProducts.remove(at: indexPath.row) // Remove the product from the array after successful deletion from SQLite
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
}
