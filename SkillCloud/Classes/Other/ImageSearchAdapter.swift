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

enum ImagesAPI {
    
    static let alamofireManager = Alamofire.Manager(configuration: NSURLSessionConfiguration.ephemeralSessionConfiguration())
    
    static let baseUrl : String = "https://www.googleapis.com/customsearch/"
    static let APIKey = "AIzaSyB4lSM9rrY6flfWtEhcEzgK1I5IVLSFvdQ"
    static let CSEIdentifier = "014471330025575907481:wg54zrvhcla"
    static let apiVersion : String = "v1"
    
    
    case Search(query: String, page: Int)
    
    
    
}
