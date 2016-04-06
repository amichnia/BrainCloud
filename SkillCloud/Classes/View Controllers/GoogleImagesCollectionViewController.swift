//
//  GoogleImagesCollectionViewController.swift
//  SkillCloud
//
//  Created by Andrzej Michnia on 06/04/16.
//  Copyright © 2016 amichnia. All rights reserved.
//

import UIKit

class GoogleImagesCollectionViewController: UICollectionViewController {

    // MARK: - Outlets
    
    // MARK: - Properties
    var searchTerm : String = "swift icon"
    var lastPage : GoogleImagePage?
    var images: [GoogleImage] = []
    var isFetching = false
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.fetchNextPage()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
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
            }
            return
        }
        
        page.promiseNextPage?
        .then { [weak self] page -> Void in
            self?.addPage(page)
        }
        .always {
            self.isFetching = false
        }
    }

    func addPage(page: GoogleImagePage) {
        self.lastPage = page
        self.images += page.images
        self.collectionView?.reloadData()
    }
}

// MARK: - UICollectionViewDataSource
extension GoogleImagesCollectionViewController {
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.images.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(GoogleImageCellIdentifier, forIndexPath: indexPath) as! GoogleImageCollectionViewCell
        
        cell.configureWithGoogleImage(self.images[indexPath.row])
        
        return cell
    }
    
}

extension GoogleImagesCollectionViewController {
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        let delta = scrollView.contentSize.height - (scrollView.contentOffset.y + scrollView.bounds.height)
        
        if delta < 80 || scrollView.contentSize.height < scrollView.bounds.height {
            self.fetchNextPage()
        }
    }
    
}