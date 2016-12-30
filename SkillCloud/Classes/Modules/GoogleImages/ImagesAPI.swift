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
    
    static let baseUrl : String = "https://www.googleapis.com/customsearch/"
//    static let APIKey = "AIzaSyB4lSM9rrY6flfWtEhcEzgK1I5IVLSFvdQ"
    static let APIKey = "AIzaSyAk5iFp1jM0-xp6adKdxBgIUkl5-a74Yac"
    static let CustomSearchEngineIdentifier = "014471330025575907481:wg54zrvhcla"
    static let apiVersion : String = "v1"
    
    case search(query: String, page: Int)
 
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
    var method: Alamofire.HTTPMethod { return Alamofire.HTTPMethod.get }
    var parameters: [String : AnyObject]? {
        switch self {
        case .search(query: let query, page: let page) where page > 0:
            return [
                Key.EngineIdentifier    : staticSelf.CustomSearchEngineIdentifier as AnyObject,
                Key.APIKey              : staticSelf.APIKey as AnyObject,
                Key.SearchType          : "image" as AnyObject,
                Key.Query               : query as AnyObject,
                Key.StartPage           : page as AnyObject
            ]
        default:
            return nil
        }
    }
    
}

