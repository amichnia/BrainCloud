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

/// API error
///
/// - unknownError: Unknown error - something went wrong
/// - other: Other oerror (of NSError type - used to pass external here)
/// - unauthorized: Authorization error
/// - serverError: Server error - usually for 500 codes
/// - timeout: Timeout error - operation took too long
/// - notFound: Wrong endpoint - 404
/// - serializationError: Request was successfull, but response could not be parsed
enum APIError : Error {
    case unknownError
    case other(NSError)
    case unauthorized
    case serverError
    case timeout
    case notFound
    case serializationError
}

/// Adopting JSONMappable allows to initialize instance with json object
protocol JSONMappable {
    init?(json: JSON)
}

/// Extends URLConvertible protocol - adopting requires to specify enough information
/// for Alamofire to process AnyAPI instance into request. Most of the requirements
/// has default implementations in protocl extension.
/// By default, only __URLString__ is required to be specified.
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

// MARK: - Extends AnyAPI with default implementations
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

// MARK: - Invoke request
extension AnyAPI {
    /// Invokes request based on api instance. Tries to parse it to provided JSONMappable
    /// object.
    ///
    /// - Returns: Promise of future serialized object
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

// MARK: - JSON extensions
extension JSON {
    /// Initializes new JSON object with given Data, if possible
    ///
    /// - Parameter data: Data
    /// - Returns: JSON or nil
    static func json(_ data: AnyObject?) -> JSON? {
        if data == nil {
            return nil
        }
        return JSON(data!)
    }
}

