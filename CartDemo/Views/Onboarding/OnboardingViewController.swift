//
//  OnboardingViewController.swift
//  CartDemo
//
//  Created by Alesson Abao on 10/06/23.
//

import UIKit

class OnboardingViewController: UIViewController {

    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var pageControl: UIPageControl!
    
    var slides: [OnboardingSlide] = []
    var currentSlide = 0 {
        didSet{
            // update the page control when button is clicked
            pageControl.currentPage = currentSlide
            if currentSlide == slides.count - 1{
                nextButton.setTitle("Get Started", for: .normal)
            }
            else{
                nextButton.setTitle("Next", for: .normal)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.delegate = self
        collectionView.dataSource = self
        // this is all the slide items
        slides = [
            OnboardingSlide(title: "Abao & Fabian", description: "This is a requirement for Hot Topic in Software.", image: UIImage(named: "Slide1") ?? UIImage()),
            OnboardingSlide(title: "Notice to users", description: "Products are not real.", image: UIImage(named: "Slide2") ?? UIImage()),
            OnboardingSlide(title: "ABC Bakery", description: "Order yummy breads.", image: UIImage(named: "Slide3") ?? UIImage())]
        // page controller adapt to slide items
        pageControl.numberOfPages = slides.count
    }
    
    @IBAction func nextButtonClicked(_ sender: UIButton) {
        
        if currentSlide == slides.count - 1{
            let controller = storyboard?.instantiateViewController(withIdentifier: "LoginNC") as! UINavigationController
            controller.modalPresentationStyle = .fullScreen
            controller.modalTransitionStyle = .coverVertical
            present(controller, animated: true, completion: nil)
        }
        else{
            currentSlide += 1
            let indexPathSlide = IndexPath(item: currentSlide, section: 0)
            collectionView.scrollToItem(at: indexPathSlide, at: .centeredHorizontally, animated: true)
        }
    }
}


extension OnboardingViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    // this is shows all the slides
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return slides.count
    }
    // this populates the collection view items
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OnboardingCollectionViewCell.identifier, for: indexPath) as! OnboardingCollectionViewCell
        // this will populate the slides
        cell.setUp(slides[indexPath.row])
        
        return cell
    }
    // this sizes the collection view items properly
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    // specifies size for item at indexpath
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let widthScroll = scrollView.frame.width
        currentSlide = Int(scrollView.contentOffset.x / widthScroll)
    }
}
