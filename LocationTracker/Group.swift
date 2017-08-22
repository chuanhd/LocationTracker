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
    public var mId : String = ""
    public var mName : String = ""
    public var mUsers = [UserProfile]()
    
    init(withID _id : String, withName _name : String) {
        self.mId = _id;
        self.mName = _name;
    }
    
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
                                                        
                                                        var groups = [Group]()
                                                        
                                                        if let _groupJSONs = _json["data"].array {
                                                            for _groupJSON in _groupJSONs {
                                                                let _groupId = _groupJSON["groupid"].stringValue
                                                                let _groupName = _groupJSON["groupname"].stringValue
                                                                
                                                                let _group = Group(withID: _groupId, withName: _groupName)
                                                                
                                                                groups.append(_group)
                                                                
                                                            }
                                                        }
                                            
                                                        
                                                        return (ServerResponse(withCode : .SUCCESS, withStatus : _status), groups)
                                                    case .GROUP_NOT_EXISTS:
                                                        return (ServerResponse(withCode : .GROUP_NOT_EXISTS, withStatus : _status), nil)
                                                    default:
                                                        break
                                                    }
                                                }
                                                
                                                return (ServerResponse(), nil)
    }
    
    static func createNewGroupResource(_ name : String!, _ desc : String!, _ colorHex : String!) -> Resource<String> {
        let params : [String : Any] = [ConnectionService.SERVER_REQ_KEY.DEVICE_ID : AppController.sharedInstance.mUniqueToken,
                                       ConnectionService.SERVER_REQ_KEY.GROUP_NAME : name,
                                       ConnectionService.SERVER_REQ_KEY.DESCRIPTION : desc]
        
        return Resource<String>(withURL : App.Group.createGroup.url,
                                     withMethod : HTTPMethod.post,
                                     withParams : params) { data in
                                        
                                        let _json = JSON(data : data)
                                        
                                        print("JSON: \(_json)") // serialized json response
                                        
                                        
                                        if let _codeStr = _json["code"].string,
                                            let _code = SERVER_RESPONSE_CODE(rawValue: _codeStr),
                                            let _status = _json["status"].string{
                                            switch _code {
                                            case .SUCCESS:
                                                
                                                let groupId = _json["data"][0]["groupid"].stringValue
                                                
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
    
    static func createGetGroupDetailResource(_ groupId : String!) -> Resource<UserProfile> {
        
        return Resource<UserProfile>(withURL : App.Group.get.url,
                               withMethod : HTTPMethod.get,
                               withParams : [ConnectionService.SERVER_REQ_KEY.GROUP_ID : groupId]) { data in
                                
                                let _json = JSON(data : data)
                                
                                print("JSON: \(_json)") // serialized json response
                                
                                if let _codeStr = _json["code"].string,
                                    let _code = SERVER_RESPONSE_CODE(rawValue: _codeStr),
                                    let _status = _json["status"].string{
                                    switch _code {
                                    case .SUCCESS:
                                        
                                        var users = [UserProfile]()
                                        
                                        if let _userJSONs = _json["data"].array {
                                            for _userJSON in _userJSONs {
                                                let _userId = _userJSON["userid"].stringValue
                                                let _userName = _userJSON["username"].stringValue
                                                let _userLat = _userJSON["lat"].floatValue
                                                let _userLong = _userJSON["lon"].floatValue
                                                let _userImage = _userJSON["userimage"].stringValue
                                                
                                                let _user = UserProfile(withId: _userId, withAvatar: _userImage, withName: _userName, withLat: _userLat, withLong: _userLong)
                                                
                                                users.append(_user)
                                                
                                                
                                            }
                                        }
                                        
                                        return (ServerResponse(withCode : .SUCCESS, withStatus : _status), users)
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
