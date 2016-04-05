//
//  ImageSearchAdapter.swift
//  SkillCloud
//
//  Created by Andrzej Michnia on 18/03/16.
//  Copyright © 2016 amichnia. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import AlamofireSwiftyJSON
import PromiseKit

enum ImagesAPI {
    
    static let alamofireManager = Alamofire.Manager(configuration: NSURLSessionConfiguration.ephemeralSessionConfiguration())
    
    static let baseUrl : String = "https://www.googleapis.com/customsearch/"
    static let APIKey = "AIzaSyB4lSM9rrY6flfWtEhcEzgK1I5IVLSFvdQ"
    static let CustomSearchEngineIdentifier = "014471330025575907481:wg54zrvhcla"
    static let apiVersion : String = "v1"
    
    case Search(query: String, page: Int)
 
    struct Key {
        static let EngineIdentifier = "cx"
        static let APIKey = "key"
        static let SearchType = "searchType"
        static let Query = "q"
        static let StartPage = "start"
    }
 
    func promiseImages() -> Promise<GoogleImagePage> {
        return self.invoke()
    }
}

extension ImagesAPI : AnyAPI {
    
    var URLString : String { return "https://www.googleapis.com/customsearch/v1" }
    var method: Alamofire.Method { return Alamofire.Method.GET }
    var parameters: [String : AnyObject]? {
        switch self {
        case .Search(query: let query, page: let page) where page > 0:
            return [
                Key.EngineIdentifier    : staticSelf.CustomSearchEngineIdentifier,
                Key.APIKey              : staticSelf.APIKey,
                Key.SearchType          : "image",
                Key.Query               : query,
                Key.StartPage           : page
            ]
        default:
            return nil
        }
    }
    
}


class GoogleImagePage : JSONMappable {
    
    var images : [GoogleImage]?
 
    required init?(json: JSON){
        guard let items = json["items"].array else {
            return nil
        }
        
        self.images = items.mapExisting{ return GoogleImage(json: $0) }
    }
}

class GoogleImage : JSONMappable {
    
    var imageUrl : String!
    var thumbnailUrl : String!
    var mime : String!
    
    var image : UIImage?
    var thumbnail : UIImage?
    
    required init?(json: JSON){
        guard let link = json["link"].string, thumbnailLink = json["image"]["thumbnailLink"].string else {
            return nil
        }
        
        self.imageUrl = link
        self.thumbnailUrl = thumbnailLink
    }
    
}
