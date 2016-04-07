//
//  GoogleImagesCollectionViewController.swift
//  SkillCloud
//
//  Created by Andrzej Michnia on 06/04/16.
//  Copyright © 2016 amichnia. All rights reserved.
//

import UIKit
import PromiseKit

class GoogleImagesCollectionViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var confirmActionButton: UIBarButtonItem!
    
    // MARK: - Properties
    var fullfillHandler: ((GoogleImage)->())?
    var rejectHandler: ((ErrorType)->())?
    var searchTerm : String = "swift icon"
    var lastPage : GoogleImagePage?
    var images: [GoogleImage] = []
    var selectedIndexPath : NSIndexPath?
    var selectedImage : GoogleImage?
    var isFetching = false
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.confirmActionButton.title = NSLocalizedString("Cancel", comment: "Cancel")
        self.fetchNextPage()
    }
    
    // MARK: - Actions
    func fetchNextPage(){
        guard !self.isFetching else {
            return
        }
        
        self.isFetching = true
        
        guard let page = lastPage else {
            ImagesAPI.Search(query: self.searchTerm, page: 1).promiseImages()
            .then { [weak self] page -> Void in
                self?.addPage(page)
            }
            .always {
                self.isFetching = false
                self.scrollViewDidScroll(self.collectionView as UIScrollView)
            }
            return
        }
        
        page.promiseNextPage?
        .then { [weak self] page -> Void in
            self?.addPage(page)
        }
        .always {
            self.isFetching = false
            self.scrollViewDidScroll(self.collectionView as UIScrollView)
        }
    }

    func addPage(page: GoogleImagePage) {
        self.lastPage = page
        let indexPaths = (0..<page.images.count).map{
            return NSIndexPath(forItem: self.images.count + $0, inSection: 0)
        }
        self.images += page.images
        self.collectionView?.insertItemsAtIndexPaths(indexPaths)
    }
    
    @IBAction func confirmImageSelection(sender: AnyObject) {
        self.presentingViewController?.dismissViewControllerAnimated(true) {
            if let image = self.selectedImage {
                self.fullfillHandler?(image)
            }
            else {
                self.rejectHandler?(ImageSelectError.NoImageSelected)
            }
        }
    }
    
}

enum ImageSelectError : ErrorType {
    case NoImageSelected
    case CannotCreateSelectionView
}

// MARK: - UICollectionViewDataSource
extension GoogleImagesCollectionViewController : UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.images.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(GoogleImageCellIdentifier, forIndexPath: indexPath) as! GoogleImageCollectionViewCell
        
        cell.configureWithGoogleImage(self.images[indexPath.row])
        if let selectedIndexPath = self.selectedIndexPath where cell.selected != (indexPath == selectedIndexPath) {
            cell.selected = (indexPath == selectedIndexPath)
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        self.selectedIndexPath = nil
        self.selectedImage = nil
        self.confirmActionButton.title = NSLocalizedString("Cancel", comment: "Cancel")
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.selectedIndexPath = indexPath
        self.selectedImage = self.images[indexPath.row]
        self.confirmActionButton.title = NSLocalizedString("OK", comment: "OK")
    }
    
    func collectionView(collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: floor(self.collectionView.bounds.width/3), height: floor(self.collectionView.bounds.width/3))
    }
}

// MARK: - UIScrollViewDelegate
extension GoogleImagesCollectionViewController : UIScrollViewDelegate {
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let delta = scrollView.contentSize.height - (scrollView.contentOffset.y + scrollView.bounds.height)
        
        if delta < 180 || scrollView.contentSize.height < scrollView.bounds.height {
            self.fetchNextPage()
        }
    }
    
}

extension UIViewController {
    
    func promiseGoogleImageForSearchTerm(term: String) throws -> Promise<GoogleImage> {
        guard let selectViewController = UIStoryboard(name: "GoogleImages", bundle: NSBundle.mainBundle()).instantiateInitialViewController() as? GoogleImagesCollectionViewController else {
            throw ImageSelectError.CannotCreateSelectionView
        }
        
        return Promise<GoogleImage>(resolvers: { (fulfill, reject) in
            selectViewController.searchTerm = term
            selectViewController.fullfillHandler = fulfill
            selectViewController.rejectHandler = reject
            
            self.presentViewController(selectViewController, animated: true, completion: nil)
        })
    }
    
}
