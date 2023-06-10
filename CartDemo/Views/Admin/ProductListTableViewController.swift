//
//  ProductListTableViewController.swift
//  CartDemo
//
//  Created by Alesson Abao on 10/06/23.
//

import UIKit
import SQLite3

class ProductListTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // object that will hold all the data
    var products = [ProductHolder]()
    var selectedProductID: Int = 0
    
    // MARK: Outlets
    @IBOutlet weak var productTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        productTableView.dataSource = self
        productTableView.delegate = self
        
        loadSavedProducts()
    }
    
    // MARK: Action Buttons
    @IBAction func reloadProductsButton(_ sender: UIButton) {
        loadSavedProducts()
    }
    
    @IBAction func alphabeticalSortButton(_ sender: UIButton) {
        loadAlphabeticalProducts()
    }
    
    // MARK: TableView Area
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = productTableView.dequeueReusableCell(withIdentifier: "productCell", for: indexPath) as! ProductListTableViewCell
        
        let thisProduct = products[indexPath.row]
        
        cell.productNameLabel.text = thisProduct.productName
        cell.productPriceLabel.text = "Price: $" + (String)(thisProduct.productPrice)
        
        cell.productPic.image = UIImage(named: thisProduct.productImage)
        
        let urlText = thisProduct.productImage

        let imgURL = URL(string: urlText!)
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
                    cell.productPic.image = imageProd
                }
            }
        }
        task.resume()
        
        return cell
    }
    
    // MARK: Product Detail Segue
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "productUpdate", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "productUpdate"){
            let indexPath = self.productTableView.indexPathForSelectedRow!
            let tableViewDetail = segue.destination as? UpdateProductViewController

            let selectedProduct = products[indexPath.row]
            tableViewDetail!.selectedProduct = selectedProduct
            self.productTableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    // MARK: Delete Product
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            // delete from sqlite
            let deleteProductStatementString = "DELETE FROM ProductList WHERE productID = ?"
            var deleteStatementQuery: OpaquePointer?
            
            if sqlite3_prepare_v2(dbQueue, deleteProductStatementString, -1, &deleteStatementQuery, nil) == SQLITE_OK {
                let selectedProduct = products[indexPath.row]
                selectedProductID = selectedProduct.productID
                
                sqlite3_bind_int(deleteStatementQuery, 1, Int32(selectedProductID))
                
                if sqlite3_step(deleteStatementQuery) == SQLITE_DONE {
                    print("Successfully deleted product 🥳")
                    products.remove(at: indexPath.row) // Remove the product from the array after successful deletion from SQLite
                    tableView.deleteRows(at: [indexPath], with: .fade)
                    tableView.reloadData() // Update the table view
                } else {
                    print("Failed deleting product 🙁")
                }
                
                sqlite3_finalize(deleteStatementQuery)
            }
        }
    }
    
    // MARK: loadSavedProducts
    // ===============================SQL LOAD SAVED PRODUCTS START===============================
    let selectStatementString = "SELECT productID, productName, productPrice, productImage FROM ProductList"
    
    var selectStatementQuery: OpaquePointer?
    var showData = ""
    
    func loadSavedProducts(){
        products = []
        
        let selectStatementString = "SELECT productID, productName, productDescription, productCategory, productPrice, productImage FROM ProductList"
        var selectStatementQuery: OpaquePointer?

        if sqlite3_prepare_v2(dbQueue, selectStatementString, -1, &selectStatementQuery, nil) == SQLITE_OK {
            while sqlite3_step(selectStatementQuery) == SQLITE_ROW{
                let productID = Int(sqlite3_column_int(selectStatementQuery, 0))
                let productName = String(cString: sqlite3_column_text(selectStatementQuery, 1))
                let productDescription = String(cString: sqlite3_column_text(selectStatementQuery, 2))
                let productCategory = String(cString: sqlite3_column_text(selectStatementQuery, 3))
                let productPrice = Double(sqlite3_column_double(selectStatementQuery, 4))
                let productImage = String(cString: sqlite3_column_text(selectStatementQuery, 5))
                
                let savedProduct = ProductHolder(
                    productID: productID,
                    productName: productName,
                    productDescription: productDescription,
                    productCategory: productCategory,
                    productPrice: productPrice,
                    productImage: productImage
                )
                
                let rowData = "THIS IS PRODUCT TABLE CONTROLLER LOAD SAVED PRODUCTS " + "ID: \(productID)\t\tname: \(productName)\t\tprice: \(productPrice)\t\turl: \(productImage)\n"
                showData += rowData
                
                print(showData)
                products.append(savedProduct)
            }
        }
        productTableView.reloadData()
    }
    // ===============================SQL LOAD SAVED PRODUCTS END=================================
    
    // MARK: loadAlphabeticalProducts
    // ===============================SQL LOAD ALPHABETICAL PRODUCTS START========================
    let selectProductNameQuery = "SELECT * FROM ProductList ORDER BY productName ASC"
    var selectProductNameStatementQuery: OpaquePointer?
    
    func loadAlphabeticalProducts(){
        
        products = []
        
        if sqlite3_prepare_v2(dbQueue, selectProductNameQuery, -1, &selectProductNameStatementQuery, nil) == SQLITE_OK {
            while sqlite3_step(selectProductNameStatementQuery) == SQLITE_ROW {
                let productID = Int(sqlite3_column_int(selectProductNameStatementQuery, 0))
                let productName = String(cString: sqlite3_column_text(selectProductNameStatementQuery, 1))
                let productDescription = String(cString: sqlite3_column_text(selectProductNameStatementQuery, 2))
                let productCategory = String(cString: sqlite3_column_text(selectProductNameStatementQuery, 3))
                let productPrice = Double(sqlite3_column_double(selectProductNameStatementQuery, 4))
                let productImage = String(cString: sqlite3_column_text(selectProductNameStatementQuery, 5))
                
                let alphabeticalProduct = ProductHolder(
                    productID: productID,
                    productName: productName,
                    productDescription: productDescription,
                    productCategory: productCategory,
                    productPrice: productPrice,
                    productImage: productImage
                )
                products.append(alphabeticalProduct)
            }
            sqlite3_finalize(selectProductNameStatementQuery)
        }
        productTableView.reloadData()
    }
    // ===============================SQL LOAD ALPHABETICAL PRODUCTS END===========================
}
