 //
//  RegularHomeTableViewController.swift
//  CartDemo
//
//  Created by Alesson Abao on 26/05/23.
//  this just shows all the products in home

import UIKit
import SQLite3

class RegularHomeTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate  {
    
    // MARK: Variables
    var products = [ProductHolder]()    // array to show all products
    
    // MARK: DB variables
    let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)

    // MARK: Outlets
    @IBOutlet weak var regularHomeTableView: UITableView!
    @IBOutlet weak var regularHomeSearchBarTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        regularHomeTableView.dataSource = self
        regularHomeTableView.delegate = self
        
        loadSavedProducts()
    }
    
    // MARK: Actions
    @IBAction func searchProduct(_ sender: UIButton) {
        
        let searchedProduct = regularHomeSearchBarTextField.text ?? ""
        
        if searchIsValid(){
            products = []
            
            // ==========================FOR TESTING==========================
            // var showData = ""
            // ==========================FOR TESTING==========================
            
            let selectSearchedProductStatementString = "SELECT * FROM ProductList WHERE productName LIKE '%\(searchedProduct)%'"
            var selectSearchedProductStatementQuery: OpaquePointer?

            if sqlite3_prepare_v2(dbQueue, selectSearchedProductStatementString, -1, &selectSearchedProductStatementQuery, nil) == SQLITE_OK {
                while sqlite3_step(selectSearchedProductStatementQuery) == SQLITE_ROW{
                    
                    let productID = Int(sqlite3_column_int(selectSearchedProductStatementQuery, 0))
                    let productName = String(cString: sqlite3_column_text(selectSearchedProductStatementQuery, 1))
                    let productDescription = String(cString: sqlite3_column_text(selectSearchedProductStatementQuery, 2))
                    let productCategory = String(cString: sqlite3_column_text(selectSearchedProductStatementQuery, 3))
                    let productPrice = Double(sqlite3_column_double(selectSearchedProductStatementQuery, 4))
                    let productImage = String(cString: sqlite3_column_text(selectSearchedProductStatementQuery, 5))
                    
                    let savedProduct = ProductHolder(
                        productID: productID,
                        productName: productName,
                        productDescription: productDescription,
                        productCategory: productCategory,
                        productPrice: productPrice,
                        productImage: productImage
                    )
                    
                    products.append(savedProduct)
                // ==========================FOR TESTING==========================
//                let rowData = "======THIS IS PRODUCT TABLE CONTROLLER LOAD SAVED PRODUCTS======\n" +
//                    "ID: \(productID)\t\t" +
//                    "name: \(productName)\t\t" +
//                    "price: \(productPrice)\t\t" +
//                    "url: \(productImage)\n"
//                showData += rowData
//
//                print(showData)
                // ==========================FOR TESTING==========================
                }
                sqlite3_finalize(selectSearchedProductStatementQuery)
                regularHomeTableView.reloadData()
            }
        }
        else{
            showMessage(message: "Search bar is empty. Try searching for a product name.", buttonCaption: "Try again", controller: self)
        }
    }
    
    @IBAction func allProductSort(_ sender: UIButton) {
        loadSavedProducts()
    }
    
    @IBAction func popularSort(_ sender: UIButton) {
        popularSort()
    }
    
    @IBAction func newSort(_ sender: UIButton) {
        newSort()
    }
    
    @IBAction func glutenFreeSort(_ sender: UIButton) {
        glutenFreeSort()
    }
    
    // MARK: TableView Area
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = regularHomeTableView.dequeueReusableCell(withIdentifier: "regularHomeCell", for: indexPath) as! RegularHomeTableViewCell
        
        let thisProduct = products[indexPath.row]
        
        cell.regularHomeProductName.text = thisProduct.productName
        cell.regularHomeProductPrice.text = "$" + (String)(thisProduct.productPrice)
        cell.regularHomeProductDescription.text = thisProduct.productDescription
        
        // *****************************LOAD PRODUCT IMG URL*****************************
        let urlText = thisProduct.productImage
        let imgURL = URL(string: urlText!)
        let urlRequest = URLRequest(url: imgURL!)   // make URL request object to send over the network
        
        let task = URLSession.shared.dataTask(with: urlRequest){
            (data,response,error)
            in
            if(error == nil){
                do{
                    let picData = try Data(contentsOf: imgURL!)
                    let imageProd = UIImage(data: picData)
                    
                    DispatchQueue.main.async { // [self] in
                        cell.regularHomeProductPic.image = imageProd
                    }
                }
                catch{
                    showMessage(message: "There was an error in loading image", buttonCaption: "Close", controller: self)
                }
            }
        }
        task.resume()
        // *****************************LOAD PRODUCT IMG URL*****************************
        
        return cell
    }
    
    // MARK: Product Detail Segue
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "regularHomeSegueCell", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "regularHomeSegueCell"){
            let indexPath = self.regularHomeTableView.indexPathForSelectedRow!
            let tableViewDetail = segue.destination as? RegularHomeProductDetailViewController

            let selectedProduct = products[indexPath.row]
            tableViewDetail!.selectedProduct = selectedProduct
            self.regularHomeTableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    // MARK: loadSavedProducts
    // ===============================SQL LOAD SAVED PRODUCTS START=========================
    func loadSavedProducts(){
        products = []
        // ==========================FOR TESTING==========================
        // var showData = ""
        // ==========================FOR TESTING==========================
        
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
                products.append(savedProduct)
                // ==========================FOR TESTING==========================
//                let rowData = "======THIS IS PRODUCT TABLE CONTROLLER LOAD SAVED PRODUCTS======\n" +
//                    "ID: \(productID)\t\t" +
//                    "name: \(productName)\t\t" +
//                    "price: \(productPrice)\t\t" +
//                    "url: \(productImage)\n"
//                showData += rowData
//
//                print(showData)
                // ==========================FOR TESTING==========================
            }
            sqlite3_finalize(selectStatementQuery)
        }
        regularHomeTableView.reloadData()
    }
    // ===============================SQL LOAD SAVED PRODUCTS END===========================
    
    // MARK: searchIsValid
    func searchIsValid() -> Bool{
        // if search textfield is empty
        guard let searchedProduct = regularHomeSearchBarTextField.text, !searchedProduct.isEmpty else {
            return false
        }
        
        if !containsOnlyLetters(str: searchedProduct){
            showMessage(message: "Product name should only contain letters.", buttonCaption: "Close", controller: self)
            print("Product should only contain letters")
            return false
        }
        return true
    }
    
    func containsOnlyLetters(str: String) -> Bool {
      let letterCharacterSet = CharacterSet.letters
      return str.rangeOfCharacter(from: letterCharacterSet) != nil
    }
    
    // MARK: popularSort
    // ===============================SQL popularSort START=================================
    func popularSort(){
        
        products = []
        
        let popularSortStringQuery = "SELECT * FROM ProductList WHERE productCategory == 'Popular' ORDER BY productCategory ASC"
        var popularSortStatementQuery: OpaquePointer?
        
        if sqlite3_prepare_v2(dbQueue, popularSortStringQuery, -1, &popularSortStatementQuery, nil) == SQLITE_OK {
            while sqlite3_step(popularSortStatementQuery) == SQLITE_ROW {
                let productID = Int(sqlite3_column_int(popularSortStatementQuery, 0))
                let productName = String(cString: sqlite3_column_text(popularSortStatementQuery, 1))
                let productDescription = String(cString: sqlite3_column_text(popularSortStatementQuery, 2))
                let productCategory = String(cString: sqlite3_column_text(popularSortStatementQuery, 3))
                let productPrice = Double(sqlite3_column_double(popularSortStatementQuery, 4))
                let productImage = String(cString: sqlite3_column_text(popularSortStatementQuery, 5))
                
                let popularProduct = ProductHolder(
                    productID: productID,
                    productName: productName,
                    productDescription: productDescription,
                    productCategory: productCategory,
                    productPrice: productPrice,
                    productImage: productImage
                )
                products.append(popularProduct)
            }
            sqlite3_finalize(popularSortStatementQuery)
        }
        regularHomeTableView.reloadData()
    }
    // ===============================SQL popularSort END===================================
    
    // MARK: newSort
    // ===============================SQL newSort START=====================================
    func newSort(){
        
        products = []
        
        let newSortStringQuery = "SELECT * FROM ProductList WHERE productCategory == 'New' ORDER BY productCategory ASC"
        var newSortStatementQuery: OpaquePointer?
        
        if sqlite3_prepare_v2(dbQueue, newSortStringQuery, -1, &newSortStatementQuery, nil) == SQLITE_OK {
            while sqlite3_step(newSortStatementQuery) == SQLITE_ROW {
                let productID = Int(sqlite3_column_int(newSortStatementQuery, 0))
                let productName = String(cString: sqlite3_column_text(newSortStatementQuery, 1))
                let productDescription = String(cString: sqlite3_column_text(newSortStatementQuery, 2))
                let productCategory = String(cString: sqlite3_column_text(newSortStatementQuery, 3))
                let productPrice = Double(sqlite3_column_double(newSortStatementQuery, 4))
                let productImage = String(cString: sqlite3_column_text(newSortStatementQuery, 5))
                
                let newProduct = ProductHolder(
                    productID: productID,
                    productName: productName,
                    productDescription: productDescription,
                    productCategory: productCategory,
                    productPrice: productPrice,
                    productImage: productImage
                )
                products.append(newProduct)
            }
            sqlite3_finalize(newSortStatementQuery)
        }
        regularHomeTableView.reloadData()
    }
    // ===============================SQL newSort END=======================================
    // MARK: glutenFreeSort
    // ===============================SQL glutenFreeSort START==============================
    
    func glutenFreeSort(){
        
        products = []
        
        let glutenFreeSortStringQuery = "SELECT * FROM ProductList WHERE productCategory == 'Gluten-free' ORDER BY productCategory ASC"
        var glutenFreeSortStatementQuery: OpaquePointer?
        
        if sqlite3_prepare_v2(dbQueue, glutenFreeSortStringQuery, -1, &glutenFreeSortStatementQuery, nil) == SQLITE_OK {
            while sqlite3_step(glutenFreeSortStatementQuery) == SQLITE_ROW {
                let productID = Int(sqlite3_column_int(glutenFreeSortStatementQuery, 0))
                let productName = String(cString: sqlite3_column_text(glutenFreeSortStatementQuery, 1))
                let productDescription = String(cString: sqlite3_column_text(glutenFreeSortStatementQuery, 2))
                let productCategory = String(cString: sqlite3_column_text(glutenFreeSortStatementQuery, 3))
                let productPrice = Double(sqlite3_column_double(glutenFreeSortStatementQuery, 4))
                let productImage = String(cString: sqlite3_column_text(glutenFreeSortStatementQuery, 5))
                
                let glutenFreeProduct = ProductHolder(
                    productID: productID,
                    productName: productName,
                    productDescription: productDescription,
                    productCategory: productCategory,
                    productPrice: productPrice,
                    productImage: productImage
                )
                products.append(glutenFreeProduct)
            }
            sqlite3_finalize(glutenFreeSortStatementQuery)
        }
        regularHomeTableView.reloadData()
    }
    // ===============================SQL glutenFreeSort END================================
}

// MARK: Constraint problem extension solution
// this is to find error in the constraints dont remove
extension NSLayoutConstraint {

    override public var description: String {
        let id = identifier ?? ""
        return "id: \(id), constant: \(constant)" //you may print whatever you want here
    }
}
