//
//  AppDelegate.swift
//  CartDemo
//
//  Created by Alesson Abao on 26/05/23.
//

import UIKit
// =====================ADDED FOR SQLITE=====================
import SQLite3
import Braintree

var dbQueue: OpaquePointer!
// db will be within the iOS device
var dbURL = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
// =====================ADDED FOR SQLITE=====================
@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        //FOR PAYPAL
        //Bundle Identifier/URL Scheme
        BTAppContextSwitcher.setReturnURLScheme("Manukau-Institute-of-Technology.CartDemo.payments")
        
        
        // =====================ADDED FOR SQLITE=====================
        // create and open db + set the pointer so it ends up finding db
        dbQueue = createAndOpenDb()
        
        if(createProductListTable() == false){
            print("[AppDelegate.swift>didFinishLaunchingWithOptions] Creating ProductList table failed 😔")
        }
        else if(insertDefaultProducts() == false){
            print("[AppDelegate.swift>didFinishLaunchingWithOptions] Inserting default products failed 😔")
        }
        else if(deleteDuplicateProduct() == false){
            print("[AppDelegate.swift>didFinishLaunchingWithOptions] Duplicate deletion failed 😔")
        }
        else if(createUserTable() == false){
            print("[AppDelegate.swift>didFinishLaunchingWithOptions] Creating User table failed 😔")
        }
        else if(insertDefaultAdmin() == false){
            print("[AppDelegate.swift>didFinishLaunchingWithOptions] Inserting default admin failed 😔")
        }
        else if(deleteDuplicateUser() == false){
            print("[AppDelegate.swift>didFinishLaunchingWithOptions] Duplicate deletion failed 😔")
        }
        else if(createCartTable() == false){
            print("[AppDelegate.swift>didFinishLaunchingWithOptions] Creating cart table failed 😔")
        }
        else if(createCartProductTable() == false){
            print("[AppDelegate.swift>didFinishLaunchingWithOptions] Creating cartProduct table failed 😔")
        }
        else if(createWishListTable() == false){
            print("[AppDelegate.swift>didFinishLaunchingWithOptions] Creating wishList table failed 😔")
        }
        // =====================ADDED FOR SQLITE=====================
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    // =====================ADDED FOR SQLITE=====================
    // MARK: createAndOpenDb
    func createAndOpenDb() -> OpaquePointer?{ // swift type for c pointers
        var db : OpaquePointer?
        
        let url = NSURL(fileURLWithPath: dbURL) // set up the url to db
        
        // name of db
        if let pathComponent = url.appendingPathComponent("Bakery.sqlite"){
            
            let filePath = pathComponent.path
            // open sqlite db
            if sqlite3_open(filePath, &db) == SQLITE_OK{
                print("[AppDelegate.swift>createAndOpenDb] Opened the DB. File Path of db: \(filePath)")
                return db
            }
            else{
                print("[AppDelegate.swift>createAndOpenDb] Couldn't open db ☹️")
            }
        }
        else{
            print("[AppDelegate.swift>createAndOpenDb] File path unavailable.")
        }
        
        return db
    }
    // MARK: createProductListTable
    func createProductListTable() -> Bool{
        var checkSuccess : Bool = false
        
        let productListTable = sqlite3_exec(dbQueue, "CREATE TABLE IF NOT EXISTS ProductList (productID INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, productName TEXT NOT NULL, productDescription TEXT NOT NULL, productCategory TEXT, productPrice REAL NOT NULL, productImage TEXT NOT NULL)", nil, nil, nil)
        
        if(productListTable != SQLITE_OK){
            print("[AppDelegate.swift>createProductListTable] Cannot create ProductList table 🙁")
            checkSuccess = false
        }
        else{
            print("[AppDelegate.swift>createProductListTable] ProductList table created 🥳")
            checkSuccess = true
        }
        
        return checkSuccess
    }
    
    // MARK: insertDefaultProducts
    func insertDefaultProducts() -> Bool{
        var checkSuccess : Bool = false
        
        let insertDefaultProductStatement = "INSERT INTO ProductList (productName, productDescription, productCategory, productPrice, productImage) VALUES ('Melon Pan', 'Melon pan is a Japanese sweet bread. This bread is super yummy but has no melon flavour, it is just named for its appearance!', 'Popular', 4.25, 'https://media.istockphoto.com/id/1187557449/photo/japanese-meron-pan-bread.jpg?s=612x612&w=0&k=20&c=MoMcvQ-tSSJGjvuifV-gFPnACN4IhfpplsDmVhGsrsE='),('Anpan', 'Anpan is Japanese Red Bean Bun, made of soft sweet bread stuffed with a sweet red bean paste filling. These make a delicious snack or on-the-go breakfast that will pair perfectly with a Matcha Latte.', '', 2.50, 'https://thumbs.dreamstime.com/b/anpan-cut-half-placed-white-background-japanese-sweet-bread-255569614.jpg'), ('Matcha Milk Bread', 'This swirl Matcha Milk Bread is so light, soft, and fluffy! Pull-apart milk bread swirled with beautiful green tea matcha colors and flavor!', 'New', 3.50, 'https://img.freepik.com/premium-photo/roti-tawar-greentea-marble-matcha-tea-marble-loaf-bread_581937-754.jpg?w=2000'), ('Loaf Bread', 'Introducing our freshly baked Loaf Bread, the epitome of simple, wholesome goodness. Handcrafted with love and expertise, our loaf bread is the perfect choice for those seeking a classic, versatile, and satisfying bakery staple.', '', 3.50, 'https://media.istockphoto.com/id/92206322/photo/sliced-loaf-of-bread-isolated-on-white.jpg?s=170667a&w=0&k=20&c=l7Cu0smMfaSh0ZZ8m6CLMtGtBG6kl_BqbLp280zAPb8='), ('Cream Cheese Garlic Bread', 'Cream cheese garlic bread is a popular Korean street food that takes garlic bread to a whole new level of deliciousness! Large rolls are cut into wedges, then filled with sweet cream cheese and topped off with an herby garlic butter custard.', 'New', 2.50, 'https://thumbs.dreamstime.com/b/korean-cream-cheese-garlic-bread-wooden-plate-isolated-korean-creamcheese-garlic-bread-190520209.jpg'), ('Chocolate Eclair', 'Introducing our delectable Chocolate Eclairs! Indulge your taste buds in a heavenly delight crafted with the finest ingredients and our passion for creating unforgettable pastry experiences. These luscious pastries feature a light and airy choux pastry shell, generously filled with a smooth, velvety chocolate cream, and elegantly finished with a rich, glossy chocolate ganache.', 'Popular', 3.50, 'https://www.tucanbakery.com/wp-content/uploads/2023/01/shutterstock_2169600635-600x400.jpg'), ('Kouign-amann', 'Introducing our Asian-inspired Kouign Amann! Prepare to embark on a delightful journey that merges the classic French pastry with the vibrant flavors of Asia. Imagine the delicate notes of matcha green tea, the subtle sweetness of black sesame, or the fragrant aroma of yuzu citrus dancing on your taste buds.', '', 5.50, 'https://previews.123rf.com/images/arancino/arancino1906/arancino190600304/124744115-kouign-amann-french-dessert-cake-on-plate-on-white-background.jpg'), ('Chocolate Crinkles', 'Introducing our delightful Chocolate Crinkles! These irresistible treats are the perfect combination of rich, fudgy chocolate and a beautiful crackled appearance that will entice both chocolate lovers and dessert enthusiasts alike. Each bite is a heavenly experience that will leave you craving for more.', 'New', 1.50, 'https://bowsessed.com/wp-content/uploads/2017/12/chocolate-crinkle-cookies15-1.jpg'), ('Pork Floss Bun', 'Introducing our mouthwatering Pork Floss Bun! Get ready to experience a delightful combination of fluffy, freshly baked bread and the savory goodness of flavorful pork floss. This delectable creation is a favorite among food enthusiasts who crave the perfect balance of textures and tastes.', '', 4.50, 'https://media.istockphoto.com/id/882667518/photo/pork-floss-bun-on-white-background.jpg?s=170667a&w=0&k=20&c=4Old-4DVpSh1FmmNlJrUgcrfrSZiQgUCFl58_pxvx9o='), ('Ube Cheese Pandesal', 'Introducing our delectable Ube Cheese Pandesal! Experience a delightful twist on the classic Filipino pandesal with the vibrant and irresistible flavor of cheese and ube, also known as purple yam. These soft and fluffy buns are a true delight for your taste buds and a celebration of the rich culinary traditions of the Philippines.', 'Gluten-free', 4.50, 'https://as1.ftcdn.net/v2/jpg/03/76/94/46/1000_F_376944647_BoLesiPeGzuYXhnrGaq3q70QP41jkIKl.jpg')"
        
        var insertDefaultProductStatementQuery: OpaquePointer?
        
        // ===================FOR TESTING===================
        var showData = ""
        // ===================FOR TESTING===================
        
        if sqlite3_prepare_v2(dbQueue, insertDefaultProductStatement, -1, &insertDefaultProductStatementQuery, nil) == SQLITE_OK {
            while sqlite3_step(insertDefaultProductStatementQuery) == SQLITE_ROW{
                let productID = Int(sqlite3_column_int(insertDefaultProductStatementQuery, 0))
                let productName = String(cString: sqlite3_column_text(insertDefaultProductStatementQuery, 1))
//                let productDescription = String(cString: sqlite3_column_text(insertDefaultProductStatementQuery, 2))
//                let productCategory = String(cString: sqlite3_column_text(insertDefaultProductStatementQuery, 3))
                let productPrice = Double(sqlite3_column_double(insertDefaultProductStatementQuery, 5))
                let productImage = String(cString: sqlite3_column_text(insertDefaultProductStatementQuery, 6))
                
                // ===================FOR TESTING===================
                let rowData = "[AppDelegate.swift>insertDefaultProducts] This is insertDefaultProducts function \n" + "ID: \(productID)\t\tname: \(productName)\t\tprice: \(productPrice)\t\turl: \(productImage)\n"
                showData += rowData
                
                print(showData)
                // ===================FOR TESTING===================
            }
            print("[AppDelegate.swift>insertDefaultProducts] Default products inserted successfully 🥳")
            checkSuccess = true
            sqlite3_finalize(insertDefaultProductStatementQuery)
        }
        else{
            print("[AppDelegate.swift>insertDefaultProducts] Cannot insert default products in ProductList table 🙁")
            checkSuccess = false
        }
        
        return checkSuccess
    }
    
    // MARK: deleteDuplicateProduct
    func deleteDuplicateProduct() -> Bool{
        var checkSuccess : Bool = false
        
        let deleteDuplicateProduct = sqlite3_exec(dbQueue, "DELETE FROM ProductList WHERE productID NOT IN (SELECT MIN(productID) FROM ProductList GROUP BY productName)", nil, nil, nil)
        
        if(deleteDuplicateProduct != SQLITE_OK){
            print("[AppDelegate.swift>deleteDuplicateProduct] Cannot delete duplicate in ProductList table 🙁")
            checkSuccess = false
        }
        else{
            print("[AppDelegate.swift>deleteDuplicateProduct] ProductList table duplicate deleted 🥳")
            checkSuccess = true
        }
        
        return checkSuccess
    }
    // MARK: createUserTable
    func createUserTable() -> Bool{
        var checkSuccess : Bool = false
        
        let createUserTable = sqlite3_exec(dbQueue, "CREATE TABLE IF NOT EXISTS User (userID INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, firstName TEXT NOT NULL, lastName TEXT NOT NULL, visuallyImpaired TEXT NOT NULL, useremail TEXT NOT NULL, userpass TEXT NOT NULL)", nil, nil, nil)
        
        if(createUserTable != SQLITE_OK){
            print("[AppDelegate.swift>createUserTable] Cannot create new user table :(")
            checkSuccess = false
        }
        else{
            checkSuccess = true
        }
        
        return checkSuccess
    }
    
    // MARK: insertDefaultAdmin
    func insertDefaultAdmin() -> Bool{
        var checkSuccess : Bool = false
        
        let insertDefaultAdminStatement = "INSERT INTO User (firstName, lastName, visuallyImpaired, useremail, userpass) VALUES ('Grant', 'Par', 'No', 'admin@test.com', 'admin1234'), ('Alesson', 'Abao', 'Yes', 'alesson@gmail.com', 'alesson1234'), ('Nicole', 'Fabian', 'No', 'nicole@gmail.com', 'nicole1234')"
        
        var insertDefaultAdminStatementQuery: OpaquePointer?
        
        // ===================FOR TESTING===================
        var showData = ""
        // ===================FOR TESTING===================
        
        if sqlite3_prepare_v2(dbQueue, insertDefaultAdminStatement, -1, &insertDefaultAdminStatementQuery, nil) == SQLITE_OK {
            while sqlite3_step(insertDefaultAdminStatementQuery) == SQLITE_ROW{
                let userFirstName = String(cString: sqlite3_column_text(insertDefaultAdminStatementQuery, 1))
                let userLastName = String(cString: sqlite3_column_text(insertDefaultAdminStatementQuery, 2))
                let userVisuallyImpaired = String(cString: sqlite3_column_text(insertDefaultAdminStatementQuery, 3))
                let userEmail = String(cString: sqlite3_column_text(insertDefaultAdminStatementQuery, 4))
                let userPassword = String(cString: sqlite3_column_text(insertDefaultAdminStatementQuery, 5))
                
                // ===================FOR TESTING===================
                let rowData = "[AppDelegate.swift>insertDefaultAdmin] This is insertDefaultAdmin function \n" + "First Name: \(userFirstName)\t\tLast Name: \(userLastName)\t\tVisually Impaired: \(userVisuallyImpaired)\t\temail: \(userEmail)\t\tpassword: \(userPassword)\n"
                showData += rowData
                
                print(showData)
                // ===================FOR TESTING===================
            }
            print("[AppDelegate.swift>insertDefaultAdmin] Default admin inserted successfully 🥳")
            checkSuccess = true
            sqlite3_finalize(insertDefaultAdminStatementQuery)
        }
        else{
            print("[AppDelegate.swift>insertDefaultAdmin] Cannot insert default admin in User table 🙁")
            checkSuccess = false
        }
        
        return checkSuccess
    }
    
    // MARK: deleteDuplicateUser
    func deleteDuplicateUser() -> Bool{
        var checkSuccess : Bool = false
        
        let deleteDuplicateUser = sqlite3_exec(dbQueue, "DELETE FROM User WHERE userID NOT IN (SELECT MIN(userID) FROM User GROUP BY useremail)", nil, nil, nil)
        
        if(deleteDuplicateUser != SQLITE_OK){
            print("[AppDelegate.swift>deleteDuplicateUser] Cannot delete duplicate in User table 🙁")
            checkSuccess = false
        }
        else{
            print("[AppDelegate.swift>deleteDuplicateUser] User table duplicate deleted 🥳")
            checkSuccess = true
        }
        
        return checkSuccess
    }
    // MARK: createCartTable
    func createCartTable() -> Bool{
        var checkSuccess : Bool = false
        
        let createCartTable = sqlite3_exec(dbQueue, "CREATE TABLE IF NOT EXISTS Cart (cartID INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, userID INTEGER NOT NULL, cartTotalPrice REAL NOT NULL, isCheckedOut TEXT NOT NULL, FOREIGN KEY (userID) REFERENCES User(userID))", nil, nil, nil)
        
        if(createCartTable != SQLITE_OK){
            print("[AppDelegate.swift>createCartTable] Cannot create cart table :(")
            checkSuccess = false
        }
        else{
            checkSuccess = true
        }
        
        return checkSuccess
    }
    // MARK: createCartProductTable
    func createCartProductTable() -> Bool{
        var checkSuccess: Bool = false
        
        let createCartProductTable = sqlite3_exec(dbQueue, "CREATE TABLE IF NOT EXISTS CartProduct (cartProductID INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, cartID INTEGER NOT NULL, productID INTEGER NOT NULL, cartProductQty INTEGER NOT NULL, FOREIGN KEY (cartID) REFERENCES Cart(cartID), FOREIGN KEY (productID) REFERENCES ProductList(productID))", nil, nil, nil)
        
        if(createCartProductTable != SQLITE_OK){
            print("[AppDelegate.swift>createCartTable] Cannot create cart table :(")
            checkSuccess = false
        }
        else{
            checkSuccess = true
        }
        
        return checkSuccess
    }
    // =====================ADDED FOR SQLITE=====================
    // MARK: createWishListTable
    func createWishListTable() -> Bool{
        var checkSuccess: Bool = false
        
        let createWishListTable = sqlite3_exec(dbQueue, "CREATE TABLE IF NOT EXISTS WishList (wishID INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, wishUserID INTEGER NOT NULL, wishProductName TEXT NOT NULL, wishProductDescription TEXT NOT NULL, wishProductCategory TEXT, wishProductPrice REAL NOT NULL, wishProductImage TEXT NOT NULL, FOREIGN KEY (wishUserID) REFERENCES User(usertID))", nil, nil, nil)
        
        if(createWishListTable != SQLITE_OK){
            print("[AppDelegate.swift>createWishListTable] Cannot create wishlist table 😔")
            checkSuccess = false
        }
        else{
            checkSuccess = true
        }
        return checkSuccess
    }
}

