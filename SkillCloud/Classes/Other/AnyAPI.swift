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


protocol AnyAPI: URLConvertible {
    var URLString   : String { get }
    var method      : Alamofire.HTTPMethod { get }
    var parameters  : [String:AnyObject]? { get }
    var headers     : [String:String]? { get }
    var encoding    : Alamofire.ParameterEncoding { get }
    var uploadFiles : [String:URL]? { get }
    var uploadData  : [String : Data]? { get }
    
    var request     : Alamofire.DataRequest { get }
}

extension AnyAPI {
    var method      : Alamofire.HTTPMethod { return Alamofire.HTTPMethod.get }
    var parameters  : [String:AnyObject]? { return nil }
    var headers     : [String:String]? { return nil }
    var encoding    : Alamofire.ParameterEncoding { return Alamofire.URLEncoding() }
    var uploadFiles : [String:URL]? { return nil }
    var uploadData  : [String : Data]? { return nil }
    
    var request : Alamofire.DataRequest {
        return Alamofire.request(self, method: self.method, parameters: self.parameters, encoding: self.encoding, headers: self.headers)
    }
    public func asURL() throws -> URL { return URL(string: self.URLString)! }
}

// MARK: - Static instance
extension AnyAPI {
    var staticSelf : Self.Type {
        return Self.self
    }
}

extension AnyAPI {
    
    func invoke<T:JSONMappable>() -> Promise<T> {
        return Promise<T> { (fulfill, reject) in
            Alamofire.request(self, method: self.method, parameters: self.parameters, encoding: self.encoding, headers: self.headers).responseSwiftyJSON { response in
                if response.result.isSuccess && response.result.error == nil, let json = response.result.value {
                    if let model = T(json: json) {
                        fulfill(model)
                    }
                    else {
                        reject(APIError.serializationError)
                    }
                }
                else {
                    reject(APIError.unknownError)
                }
            }
        }
    }
    
}

extension JSON {
    
    static func json(_ data: AnyObject?) -> JSON? {
        if data == nil {
            return nil
        }
        return JSON(data!)
    }
    
}

enum APIError : Error {
    case unknownError
    case other(NSError)
    case unauthorized
    case serverError
    case timeout
    case notFound
    case serializationError
}
