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

struct GroupImage {
    var m_Lat : Double
    var m_Lon : Double
    var m_OwnerID : String
    var m_Url : URL
}

class Group {
    public var mId : Int = -1
    public var mName : String = ""
    public var mUsers = [UserProfile]()
    public var m_DestLat : Double?
    public var m_DestLon : Double?
    public var m_ArrGroupImages : [GroupImage]?
    public var m_Description : String?
//    public var m_GroupMasterUserId : String = ""
    
    init(withID _id : Int, withName _name : String) {
        self.mId = _id;
        self.mName = _name;
    }
    
    func groupMasterUserId() -> String {
        guard let _masterProfile = (self.mUsers.filter { (_profile) -> Bool in
            return _profile.m_IsMaster == true
        }).first else {
            return ""
        }
        
        return _masterProfile.mId
    }
    
}

extension Group {
    static let getAllGroups = Resource<Group>(withURL : App.Group.all.url,
                                             withMethod : HTTPMethod.get,
                                             withParams : [ConnectionService.SERVER_REQ_KEY.USER_ID : AppController.sharedInstance.mUniqueToken]) { data in
                                                
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
                                                                let _groupId = _groupJSON["groupid"].intValue
                                                                let _groupName = _groupJSON["groupname"].stringValue
                                                                let _groupLat = _groupJSON["lat"].double
                                                                let _groupLon = _groupJSON["lon"].double
                                                                
                                                                let _group = Group(withID: _groupId, withName: _groupName)
                                                                _group.m_DestLat = _groupLat
                                                                _group.m_DestLon = _groupLon
                                                                
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
    
    static func createNewGroupResource(_ name : String!, _ desc : String!, _ colorHex : String!) -> Resource<Int> {
        let params : [String : Any] = [ConnectionService.SERVER_REQ_KEY.USER_ID : AppController.sharedInstance.mUniqueToken,
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
    
    static func createGetGroupDetailResource(_ groupId : Int!) -> Resource<UserProfile> {
        
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
                                                let _userLat = _userJSON["lat"].doubleValue
                                                let _userLong = _userJSON["lon"].doubleValue
                                                let _userImage = _userJSON["userimage"].stringValue
                                                let _email = _userJSON["email"].stringValue
                                                let _phoneNumber = _userJSON["phoneNumber"].stringValue
                                                
                                                let _user = UserProfile(withId: _userId, withAvatar: _userImage, withEmail: _email, withName: _userName, withPhoneNumber: _phoneNumber, withLat: _userLat, withLong: _userLong)
                                                _user.m_IsMaster = _userJSON["master"].boolValue
                                                
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
    
    static func inviteUser(_ _groupId : Int, _ _userId : String) -> Resource<UserProfile> {
        
        let params : [String : Any] = [ConnectionService.SERVER_REQ_KEY.USER_ID : _userId,
                                       ConnectionService.SERVER_REQ_KEY.GROUP_ID : _groupId]
        
        return Resource<UserProfile>(withURL : App.Group.addMember.url,
                                     withMethod : HTTPMethod.post,
                                     withParams : params) { data in
                                        
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
    
    static func setDestination(_ _groupId : Int, _ _userId : String, _ lat : Float, _ lon : Float) -> Resource<Group> {
        
        let params : [String : Any] = [ConnectionService.SERVER_REQ_KEY.USER_ID : _userId,
                                       ConnectionService.SERVER_REQ_KEY.GROUP_ID : _groupId,
                                       ConnectionService.SERVER_REQ_KEY.LATITUDE : lat,
                                       ConnectionService.SERVER_REQ_KEY.LONGTITUDE : lon]
        
        return Resource<Group>(withURL : App.Group.setDestination.url,
                                     withMethod : HTTPMethod.post,
                                     withParams : params) { data in
                                        
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
    
    static func createGetGroupImagesResource(_ groupId : Int!) -> Resource<Dictionary<String, Any>> {
        
        return Resource<Dictionary<String, Any>>(withURL : App.Group.getImages.url,
                                     withMethod : HTTPMethod.get,
                                     withParams : [ConnectionService.SERVER_REQ_KEY.GROUP_ID : groupId]) { data in
                                        
                                        let _json = JSON(data : data)
                                        
                                        print("JSON: \(_json)") // serialized json response
                                        
                                        if let _codeStr = _json["code"].string,
                                            let _code = SERVER_RESPONSE_CODE(rawValue: _codeStr),
                                            let _status = _json["status"].string{
                                            switch _code {
                                            case .SUCCESS:
                                                
                                                var _dicts = [Dictionary<String, Any>]()
                                                
                                                if let _imageJSONs = _json["data"].array {
                                                    for _imageJSON in _imageJSONs {
                                                        _dicts.append(_imageJSON.dictionaryObject!)
                                                    }
                                                }
                                                
                                                return (ServerResponse(withCode : .SUCCESS, withStatus : _status), _dicts)
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
