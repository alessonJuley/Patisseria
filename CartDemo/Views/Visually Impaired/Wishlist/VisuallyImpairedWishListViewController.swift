//
//  VisuallyImpairedWishListViewController.swift
//  CartDemo
//
//  Created by Alesson Abao on 11/06/23.
//

import UIKit
import SQLite3

class VisuallyImpairedWishListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    // MARK: Variables
    var visualAddedWishProducts = [VisualWishProductHolder]()
    var visualSelectedWishID: Int = 0
    
    // MARK: Outlets
    @IBOutlet weak var visualWishTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        visualWishTableView.dataSource = self
        visualWishTableView.delegate = self
        
        loadWishList()
        
        visualWishTableView.reloadData()
    }
    
    // MARK: Table View Area
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return visualAddedWishProducts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = visualWishTableView.dequeueReusableCell(withIdentifier: "visualWishCell", for: indexPath) as! VisuallyImpairedWishListTableViewCell
        
        let thisWish = visualAddedWishProducts[indexPath.row]
        
        cell.visualWishProductName.text = thisWish.visualWishProductName
        cell.visualWishProductPrice.text = "$" + String(thisWish.visualWishProductPrice)
        cell.visualWishProductCategory.text = thisWish.visualWishProductCategory
        
        // make image autoload
        let productImageURL = thisWish.visualWishProductImage
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
                    cell.visualWishProductImage.image = imageProd
                }
            }
        }
        task.resume()
        
        return cell
    }
    
    // MARK: loadWishList
    func loadWishList(){
        visualAddedWishProducts = []
        
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
                
                let savedWishProduct = VisualWishProductHolder(
                    visualWishID: wishID,
                    visualWishUserID: wishUserID,
                    visualWishProductName: wishProductName,
                    visualWishProductDescription: wishProductDescription,
                    visualWishProductCategory: wishProductCategory,
                    visualWishProductPrice: wishProductPrice,
                    visualWishProductImage: wishProductImage
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
                visualAddedWishProducts.append(savedWishProduct)
                // ==========================FOR TESTING==========================
            }
            sqlite3_finalize(selectWishQuery)
        }
        visualWishTableView.reloadData()
    }
    
    // MARK: Product Detail Segue
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "visualWishSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "visualWishSegue"){
            let indexPath = self.visualWishTableView.indexPathForSelectedRow!
            let tableViewDetail = segue.destination as? VisuallyImpairedDetailViewController

            let selectedWishProduct = visualAddedWishProducts[indexPath.row]
            tableViewDetail!.visualSelectedWishProduct = selectedWishProduct
            self.visualWishTableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    // ****************************CLEAR CODE****************************************
    // MARK: Delete
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let selectedWishProduct = visualAddedWishProducts[indexPath.row]
        visualSelectedWishID = selectedWishProduct.visualWishID
        
        if editingStyle == .delete{
            // delete from sqlite
            let deleteProductStatementString = "DELETE FROM WishList WHERE wishID = \(visualSelectedWishID)"
            var deleteStatementQuery: OpaquePointer?
            
            if sqlite3_prepare_v2(dbQueue, deleteProductStatementString, -1, &deleteStatementQuery, nil) == SQLITE_OK {
                
                if sqlite3_step(deleteStatementQuery) == SQLITE_DONE {
                    print("Successfully deleted product 🥳")
                    visualAddedWishProducts.remove(at: indexPath.row) // Remove the product from the array after successful deletion from SQLite
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
