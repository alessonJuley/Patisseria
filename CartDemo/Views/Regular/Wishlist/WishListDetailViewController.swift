//
//  WishListDetailViewController.swift
//  CartDemo
//
//  Created by Alesson Abao on 11/06/23.
//

import UIKit

class WishListDetailViewController: UIViewController {
    
    // MARK: Variables
    var selectedWishProduct: WishProductHolder!

    // MARK: Outlets
    @IBOutlet weak var wishListProductImage: UIImageView!
    @IBOutlet weak var wishListProductName: UILabel!
    @IBOutlet weak var wishListProductPrice: UILabel!
    @IBOutlet weak var wishListProductCategory: UILabel!
    @IBOutlet weak var wishListProductDescription: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // make image autoload
        let productImageURL = selectedWishProduct.wishProductImage
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
                    self.wishListProductImage.image = imageProd
                }
            }
        }
        task.resume()
        
        wishListProductName.text = selectedWishProduct.wishProductName
        wishListProductPrice.text = "$" + (String)(selectedWishProduct.wishProductPrice)
        wishListProductCategory.text = selectedWishProduct.wishProductCategory
        wishListProductDescription.text = selectedWishProduct.wishProductDescription
    }
    


}
