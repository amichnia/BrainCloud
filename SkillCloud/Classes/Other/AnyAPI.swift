//
//  AnyAPI.swift
//  SkillCloud
//
//  Created by Andrzej Michnia on 05/04/16.
//  Copyright © 2016 amichnia. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import AlamofireSwiftyJSON
import PromiseKit

protocol JSONMappable {
    init?(json: JSON)
}

protocol AnyAPI: URLStringConvertible {
    var method      : Alamofire.Method { get }
    var parameters  : [String:AnyObject]? { get }
    var headers     : [String:String]? { get }
    var encoding    : Alamofire.ParameterEncoding { get }
    
    func resolveErrorWith(nserror: NSError?) -> ErrorType
}

extension AnyAPI {
    var method      : Alamofire.Method { return Alamofire.Method.GET }
    var parameters  : [String:AnyObject]? { return nil }
    var headers     : [String:String]? { return nil }
    var encoding    : Alamofire.ParameterEncoding { return Alamofire.ParameterEncoding.URL }
    
    func resolveErrorWith(nserror: NSError?) -> ErrorType {
        return nserror ?? APIError.UnknownError
    }
}

extension AnyAPI {
    var staticSelf : Self.Type {
        return Self.self
    }
}

extension AnyAPI {
    
    func invoke<T:JSONMappable>() -> Promise<T> {
        return Promise<T> { (fulfill, reject) in
            Alamofire.request(self.method, self, parameters: self.parameters, encoding: self.encoding, headers: self.headers).responseSwiftyJSON { response in
                if response.result.isSuccess && response.result.error == nil, let json = response.result.value {
                    if let model = T(json: json) {
                        fulfill(model)
                    }
                    else {
                        reject(APIError.SerializationError)
                    }
                }
                else {
                    reject(self.resolveErrorWith(response.result.error))
                }
            }
        }
    }
    
}

extension JSON {
    
    static func json(data: AnyObject?) -> JSON? {
        if data == nil {
            return nil
        }
        return JSON(data!)
    }
    
}

enum APIError : ErrorType {
    case UnknownError
    case Other(NSError)
    case Unauthorized
    case ServerError
    case Timeout
    case NotFound
    case SerializationError
}