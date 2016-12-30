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
    @IBOutlet weak var searchButon: UIButton!
    @IBOutlet weak var searchTextField: UITextField!
    
    // MARK: - Properties
    var fullfillHandler: ((GoogleImage)->())?
    var rejectHandler: ((Error)->())?
    var searchTerm : String?
    var lastPage : GoogleImagePage?
    var images: [GoogleImage] = []
    var selectedIndexPath : IndexPath?
    var selectedImage : GoogleImage?
    var isFetching = false {
        didSet {
            searchButon.isEnabled = !isFetching
        }
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        confirmActionButton.title = NSLocalizedString("Cancel", comment: "Cancel")
        searchTextField.text = searchTerm
        
        fetchNextPage()
    }
    
    // MARK: - Actions
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
    
    @IBAction func searchAction(_ sender: AnyObject) {
        guard let term = searchTextField.text, term != searchTerm else {
            return
        }
        
        reloadSearch(with: term)
        _ = searchTextField.resignFirstResponder()
    }
    
    // MARK: - Fetching Images
    func fetchNextPage(){
        guard !self.isFetching else {
            return
        }
        
        guard let searchTerm = self.searchTerm, searchTerm.characters.count > 0 else {
            return
        }
        
        self.isFetching = true
        
        guard let page = lastPage else {
            _ = ImagesAPI.search(query: searchTerm, page: 1).promiseImages()
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
        .catch { error in
            print("error \(error)")
        }
        .always {
            self.isFetching = false
        }
        .then { [weak self] page -> Void in
            if let sself = self {
                sself.scrollViewDidScroll(sself.collectionView as UIScrollView)
            }
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
    
    func reloadSearch(with term: String?) {
        searchTerm = term
        searchTextField.text = searchTerm
        lastPage = nil
        images = []
        selectedIndexPath = nil
        selectedImage = nil
        confirmActionButton.title = NSLocalizedString("Cancel", comment: "Cancel")
        collectionView.reloadData()
        
        fetchNextPage()
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
        if let selectedIndexPath = self.selectedIndexPath {
            if indexPath.row == selectedIndexPath.row {
                cell.isSelected = true
                cell.overlay.isHidden = false
            }
            else {
                cell.isSelected = false
                cell.overlay.isHidden = true
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        selectedIndexPath = nil
        selectedImage = nil
        confirmActionButton.title = NSLocalizedString("Cancel", comment: "Cancel")
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndexPath = indexPath
        selectedImage = self.images[indexPath.row]
        confirmActionButton.title = NSLocalizedString("OK", comment: "OK")
        collectionView.reloadData()
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
        
        if delta < 180 || scrollView.contentSize.height < scrollView.bounds.height, images.count < 40 {
            self.fetchNextPage()
        }
    }
    
}

extension UIViewController {
    
    func promiseGoogleImageForSearchTerm(_ term: String?) throws -> Promise<GoogleImage> {
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
    
    func selectGoogleImage(_ query: String?) -> Promise<UIImage> {
        return try! self.promiseGoogleImageForSearchTerm(query)
        .then{ (image) -> Promise<UIImage> in
            print(image.imageUrl)
            return image.promiseImage()
        }
    }
    
}
