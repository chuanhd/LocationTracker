//
//  Group.swift
//  LocationTracker
//
//  Created by Chuan Ho Danh on 8/7/17.
//  Copyright © 2017 tranght. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire

class Group {
    public var mId : Int = -1
    public var mName : String = ""
}

extension Group {
    static let getAllGroups = Resource<Group>(withURL : App.Group.all.url,
                                             withMethod : HTTPMethod.get,
                                             withParams : [ConnectionService.SERVER_REQ_KEY.DEVICE_ID : AppController.sharedInstance.mUniqueToken]) { data in
                                                
                                                let _json = JSON(data : data)
                                                
                                                print("JSON: \(_json)") // serialized json response
                                                
                                                
                                                if let _codeStr = _json["code"].string,
                                                    let _code = SERVER_RESPONSE_CODE(rawValue: _codeStr),
                                                    let _status = _json["status"].string{
                                                    switch _code {
                                                    case .SUCCESS:
                                                        return (ServerResponse(withCode : .SUCCESS, withStatus : _status), nil)
                                                    case .GROUP_NOT_EXISTS:
                                                        return (ServerResponse(withCode : .GROUP_NOT_EXISTS, withStatus : _status), nil)
                                                    default:
                                                        break
                                                    }
                                                }
                                                
                                                return (ServerResponse(), nil)
    }
    
    static func createNewGroupResource(_ name : String!, _ desc : String!, _ colorHex : String!) -> Resource<Int> {
        let params : [String : Any] = [ConnectionService.SERVER_REQ_KEY.DEVICE_ID : AppController.sharedInstance.mUniqueToken,
                                       ConnectionService.SERVER_REQ_KEY.GROUP_NAME : name,
                                       ConnectionService.SERVER_REQ_KEY.DESCRIPTION : desc]
        
        return Resource<Int>(withURL : App.Group.createGroup.url,
                                     withMethod : HTTPMethod.post,
                                     withParams : params) { data in
                                        
                                        let _json = JSON(data : data)
                                        
                                        print("JSON: \(_json)") // serialized json response
                                        
                                        
                                        if let _codeStr = _json["code"].string,
                                            let _code = SERVER_RESPONSE_CODE(rawValue: _codeStr),
                                            let _status = _json["status"].string{
                                            switch _code {
                                            case .SUCCESS:
                                                
                                                let groupId = _json["data"][0]["groupid"].intValue
                                                
                                                return (ServerResponse(withCode : .SUCCESS, withStatus : _status), [groupId])
                                            case .FAILURE:
                                                return (ServerResponse(withCode : .FAILURE, withStatus : _status), nil)
                                            default:
                                                break
                                            }
                                        }
                                        
                                        return (ServerResponse(), nil)
        }
    }
    
    static func createGetGroupDetailResource(_ groupId : Int!) -> Resource<Group> {
        
        return Resource<Group>(withURL : App.Group.get(id: groupId).url,
                               withMethod : HTTPMethod.get,
                               withParams : nil) { data in
                                
                                let _json = JSON(data : data)
                                
                                print("JSON: \(_json)") // serialized json response
                                
                                
                                if let _codeStr = _json["code"].string,
                                    let _code = SERVER_RESPONSE_CODE(rawValue: _codeStr),
                                    let _status = _json["status"].string{
                                    switch _code {
                                    case .SUCCESS:
                                        return (ServerResponse(withCode : .SUCCESS, withStatus : _status), nil)
                                    case .FAILURE:
                                        return (ServerResponse(withCode : .FAILURE, withStatus : _status), nil)
                                    default:
                                        break
                                    }
                                }
                                
                                return (ServerResponse(), nil)
        }
    }
}
