//
//  GoogleImagesCollectionViewController.swift
//  SkillCloud
//
//  Created by Andrzej Michnia on 06/04/16.
//  Copyright © 2016 amichnia. All rights reserved.
//

import UIKit

class GoogleImagesCollectionViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - Properties
    var searchTerm : String = "swift icon"
    var lastPage : GoogleImagePage?
    var images: [GoogleImage] = []
    var selectedIndexPath : NSIndexPath?
    var isFetching = false
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.selectedIndexPath = indexPath
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

