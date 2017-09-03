//
//  GoogleImage.swift
//  SkillCloud
//
//  Created by Andrzej Michnia on 06/04/16.
//  Copyright © 2016 amichnia. All rights reserved.
//

import UIKit
import SwiftyJSON
import PromiseKit
import Alamofire

class GoogleImage : JSONMappable {
    
    var imageUrl : String!
    var thumbnailUrl : String!
    var mime : String!
    
    var image : UIImage?
    var thumbnail : UIImage?
    
    required init?(json: JSON){
        guard let link = json["link"].string, let thumbnailLink = json["image"]["thumbnailLink"].string else {
            return nil
        }
        
        self.imageUrl = link
        self.thumbnailUrl = thumbnailLink
    }
    
    func promiseThumbnail() -> Promise<UIImage> {
        guard self.thumbnail == nil else {
            return Promise<UIImage> { (fulfill, reject) in
                fulfill(self.thumbnail!)
            }
        }
        
        return UIImage.promiseImageWithUrl(self.thumbnailUrl).then { image -> UIImage in
            self.thumbnail = image
            return image
        }
    }
    
    func promiseImage() -> Promise<UIImage> {
        guard self.image == nil else {
            return Promise<UIImage> { (fulfill, reject) in
                fulfill(self.image!)
            }
        }
        
        return UIImage.promiseImageWithUrl(self.imageUrl).then { image -> UIImage in
            self.image = image
            return image
        }
    }
}

class GoogleImagePage : JSONMappable, PageablePromise {
    
    var images : [GoogleImage] = []
    
    lazy var promiseNextPage : Promise<GoogleImagePage>? = {
        guard let startIndex = self.nextPageStart, let terms = self.terms else {
            return nil
        }
        
        return ImagesAPI.search(query: terms, page: startIndex).promiseImages()
    }()
    var nextPageStart : Int?
    var terms : String?
    
    required init?(json: JSON){
        guard let items = json["items"].array else {
            return nil
        }
        
        self.images = items.mapExisting{ return GoogleImage(json: $0) }
        
        // If next page exists
        if let startIndex = json["queries"]["nextPage"][0]["startIndex"].int, let terms = json["queries"]["nextPage"][0]["searchTerms"].string {
            DDLogInfo("NEXT PAGE: \(startIndex)")
            self.nextPageStart = startIndex
            self.terms = terms
        }
    }
}

protocol PageablePromise {
    associatedtype T
    var promiseNextPage : Promise<T>? { get }
    
}

extension UIImage {
    
    static func promiseImageWithUrl(_ url: URLConvertible) -> Promise<UIImage> {
        return Promise<UIImage> { (fulfill, reject) in
            Alamofire.request(url).responseData { response in
                if let data = response.data, let image = UIImage(data: data) {
                    fulfill(image)
                }
                else {
                    reject(APIError.serializationError)
                }
            }
        }
    }
    
}
