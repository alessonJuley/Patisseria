//
//  VisuallyImpairedDetailViewController.swift
//  CartDemo
//
//  Created by Alesson Abao on 11/06/23.
//

import UIKit

class VisuallyImpairedDetailViewController: UIViewController {

    // MARK: Variable
    var visualSelectedWishProduct: VisualWishProductHolder!
    
    // MARK: Outlets
    @IBOutlet weak var visualWishListProductImage: UIImageView!
    @IBOutlet weak var visualWishListProductName: UILabel!
    @IBOutlet weak var visualWishListProductPrice: UILabel!
    @IBOutlet weak var visualWishListProductCategory: UILabel!
    @IBOutlet weak var visualWishListProductDescription: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // make image autoload
        let productImageURL = visualSelectedWishProduct.visualWishProductImage
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
                    self.visualWishListProductImage.image = imageProd
                }
            }
        }
        task.resume()
        
        visualWishListProductName.text = visualSelectedWishProduct.visualWishProductName
        visualWishListProductPrice.text = "$" + (String)(visualSelectedWishProduct.visualWishProductPrice)
        visualWishListProductCategory.text = visualSelectedWishProduct.visualWishProductCategory
        visualWishListProductDescription.text = visualSelectedWishProduct.visualWishProductDescription
    }

}
