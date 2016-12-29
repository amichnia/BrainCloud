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
    var rejectHandler: ((Error)->())?
    var searchTerm : String = "swift icon"
    var lastPage : GoogleImagePage?
    var images: [GoogleImage] = []
    var selectedIndexPath : IndexPath?
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
            _ = ImagesAPI.search(query: self.searchTerm, page: 1).promiseImages()
            .then { [weak self] page -> Void in
                self?.addPage(page)
            }
            .always {
                self.isFetching = false
                self.scrollViewDidScroll(self.collectionView as UIScrollView)
            }
            return
        }
        
        _ = page.promiseNextPage?
        .then { [weak self] page -> Void in
            self?.addPage(page)
        }
        .always {
            self.isFetching = false
            self.scrollViewDidScroll(self.collectionView as UIScrollView)
        }
    }

    func addPage(_ page: GoogleImagePage) {
        self.lastPage = page
        let indexPaths = (0..<page.images.count).map{
            return IndexPath(item: self.images.count + $0, section: 0)
        }
        self.images += page.images
        self.collectionView?.insertItems(at: indexPaths)
    }
    
    @IBAction func confirmImageSelection(_ sender: AnyObject) {
        self.presentingViewController?.dismiss(animated: true) {
            if let image = self.selectedImage {
                self.fullfillHandler?(image)
            }
            else {
                self.rejectHandler?(ImageSelectError.noImageSelected)
            }
        }
    }
    
}

enum ImageSelectError : Error {
    case noImageSelected
    case cannotCreateSelectionView
}

// MARK: - UICollectionViewDataSource
extension GoogleImagesCollectionViewController : UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GoogleImageCellIdentifier, for: indexPath) as! GoogleImageCollectionViewCell
        
        cell.configureWithGoogleImage(self.images[indexPath.row])
        if let selectedIndexPath = self.selectedIndexPath, cell.isSelected != (indexPath == selectedIndexPath) {
            cell.isSelected = (indexPath == selectedIndexPath)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        self.selectedIndexPath = nil
        self.selectedImage = nil
        self.confirmActionButton.title = NSLocalizedString("Cancel", comment: "Cancel")
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedIndexPath = indexPath
        self.selectedImage = self.images[indexPath.row]
        self.confirmActionButton.title = NSLocalizedString("OK", comment: "OK")
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        return CGSize(width: floor(self.collectionView.bounds.width/3), height: floor(self.collectionView.bounds.width/3))
    }
}

// MARK: - UIScrollViewDelegate
extension GoogleImagesCollectionViewController : UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let delta = scrollView.contentSize.height - (scrollView.contentOffset.y + scrollView.bounds.height)
        
        if delta < 180 || scrollView.contentSize.height < scrollView.bounds.height {
            self.fetchNextPage()
        }
    }
    
}

extension UIViewController {
    
    func promiseGoogleImageForSearchTerm(_ term: String) throws -> Promise<GoogleImage> {
        guard let selectViewController = UIStoryboard(name: "GoogleImages", bundle: Bundle.main).instantiateInitialViewController() as? GoogleImagesCollectionViewController else {
            throw ImageSelectError.cannotCreateSelectionView
        }
        
        return Promise<GoogleImage>(resolvers: { (fulfill, reject) in
            selectViewController.searchTerm = term
            selectViewController.fullfillHandler = fulfill
            selectViewController.rejectHandler = reject
            
            self.present(selectViewController, animated: true, completion: nil)
        })
    }
    
    func selectGoogleImage(_ query: String) -> Promise<UIImage> {
        return try! self.promiseGoogleImageForSearchTerm(query).then{ (image) -> Promise<UIImage> in
            print(image.imageUrl)
            return image.promiseImage()
        }
    }
    
}
