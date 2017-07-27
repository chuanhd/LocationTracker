//
//  ConnectionService.swift
//  LocationTracker
//
//  Created by chuanhd on 7/23/17.
//  Copyright © 2017 tranght. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

private let BASE_URL = URL(string:"http://localhost:3000")

struct Resource<T> {
    let url : URL!
    var params : Dictionary<String, Any>?
    var method : HTTPMethod = HTTPMethod.get
    let parse:(Data) -> (ServerResponse, T?)
}

extension Resource {
    init(withURL url : URL,
         withMethod httpMethod : HTTPMethod = .get,
         withParams params : Dictionary<String, Any>?,
         withParseBlock parse : @escaping (Data) -> (ServerResponse, T?)) {
        self.url = url
        self.method = httpMethod
        self.parse = parse
        self.params = params
    }
}

protocol Url {
    var url : URL { get }
}

enum App {
    enum Group {
        case all
        case get(id : Int)
        case addMember(id : Int)
        case removeMember(id : Int)
    }
    
    enum User {
        case getInfo (id : Int)
        case getLocation(id : Int)
    }
    
    enum Myself {
        case login
        case updateMyLocation
        case updateMyInfo
    }
}

extension App.User : Url {
    var url : URL {
        switch self {
        case .getInfo(let id):
            return URL(string: "\(id)", relativeTo: BASE_URL)!
        case .getLocation(let id):
            return URL(string: "\(id)", relativeTo: BASE_URL)!
        }
    }
}

enum SERVER_RESPONSE_CODE : String {
    case SUCCESS = "SUCCESS"
    case FAILURE = "FAILURE"
    case USER_NOT_EXIST = "USER_NOT_EXISTS"
}

struct ServerResponse {
    let code : SERVER_RESPONSE_CODE
    let status : String?
}

extension ServerResponse {
    
    init() {
        self.code = .FAILURE
        self.status = "Unknown error"
    }
    
    init(withCode _code : SERVER_RESPONSE_CODE,
         withStatus _status : String?) {
        self.code = _code
        self.status = _status
    }
}

extension App.Myself : Url {
    var url : URL {
        switch self {
        case .login:
            return URL(string: "api/user", relativeTo: BASE_URL)!
        case .updateMyLocation:
            return URL(string: "", relativeTo: BASE_URL)!
        case .updateMyInfo:
            return URL(string: "", relativeTo: BASE_URL)!
        }
    }
}

class ConnectionService {
    
    struct SERVER_REQ_KEY {
        static let DEVICE_ID = "deviceid"
        static let USERNAME = "username"
        static let EMAIL = "email"
        static let PHONE_NUMBER = "phonenumber"
        static let LATITUDE = "lat"
        static let LONGTITUDE = "lon"
    }
    
    class func load<T>(_ resource : Resource<T>, completion: @escaping (_ response : ServerResponse, _ result : T?, _ error : Error?) -> ()) {
        
        print("Unique token id: \(AppController.sharedInstance.mUniqueToken)")
        
        Alamofire.request(resource.url, method: resource.method, parameters : params).validate().responseJSON { response in
            print("Request: \(String(describing: response.request))")   // original url request
            print("Response: \(String(describing: response.response))") // http url response
            print("Result: \(response.result)")                         // response serialization result
            
            /*
             if let json = response.result.value {
             print("JSON: \(json)") // serialized json response
             }
             
             if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
             print("Data: \(utf8Text)") // original server data as UTF8 string
             }
             */
            
            switch response.result {
            case .success:
                print("Validation Successful")
                if let data = response.data {
                    let parsed = resource.parse(data)
                    completion(parsed.0, parsed.1, nil)
                }
            case .failure(let error):
                print(error)
                completion(ServerResponse(), nil, error)
            }
        }
    }
    
}
