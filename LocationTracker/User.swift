//
//  User.swift
//  LocationTracker
//
//  Created by chuanhd on 7/23/17.
//  Copyright © 2017 tranght. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire

class UserProfile {
    public var mId : String = ""
    public var mUsername : String = ""
    public var mAvatarURLStr : String = ""
    public var mLatitude : Float = -1
    public var mLongtitude : Float = -1
        
    init(withId _id : String, withAvatar _avatarURLStr : String, withName _name : String, withLat _lat : Float, withLong _long : Float) {
        mId = _id
        mUsername = _name
        mAvatarURLStr = _avatarURLStr
        mLatitude = _lat
        mLongtitude = _long
    }
    
    func updateUserLocation(withNewLat _lat : Float, withNewLong _long : Float) {
        mLatitude = _lat
        mLongtitude = _long
    }
}


extension UserProfile {
    static let login = Resource<UserProfile>(withURL : App.Myself.login.url,
                                             withMethod : HTTPMethod.post,
                                             withParams : [ConnectionService.SERVER_REQ_KEY.USER_ID : AppController.sharedInstance.mUniqueToken]) { data in
                                                
                                                let _json = JSON(data : data)
                                                
                                                print("JSON: \(_json)") // serialized json response

                                                
                                                if let _codeStr = _json["code"].string,
                                                    let _code = SERVER_RESPONSE_CODE(rawValue: _codeStr),
                                                let _status = _json["status"].string{
                                                    switch _code {
                                                    case .SUCCESS:
                                                        return (ServerResponse(withCode : .SUCCESS, withStatus : _status), nil)
                                                    case .USER_NOT_EXIST:
                                                        return (ServerResponse(withCode : .USER_NOT_EXIST, withStatus : _status), nil)
                                                    default:
                                                        break
                                                    }
                                                }
      
                                                return (ServerResponse(), nil)
                                            }

    
    static func createUpdateMyInfoResource(_ email : String!, _ name : String!, _ phone : String!, _ avatarURL : String?) -> Resource<UserProfile> {
        var params : [String : Any] = [ConnectionService.SERVER_REQ_KEY.USER_ID : AppController.sharedInstance.mUniqueToken,
                     ConnectionService.SERVER_REQ_KEY.EMAIL : email,
                     ConnectionService.SERVER_REQ_KEY.USERNAME : name,
                     ConnectionService.SERVER_REQ_KEY.PHONE_NUMBER : phone]
        
        if let avatarURL = avatarURL {
            params[ConnectionService.SERVER_REQ_KEY.AVATAR] = avatarURL
        }
        
        return Resource<UserProfile>(withURL : App.Myself.updateMyInfo.url,
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
    
    static func createUpdateMyLocationResource(_ lat : Float, _ lon : Float) -> Resource<UserProfile> {
        let params : [String : Any] = [ConnectionService.SERVER_REQ_KEY.USER_ID : AppController.sharedInstance.mUniqueToken,
                                       ConnectionService.SERVER_REQ_KEY.LATITUDE : lat,
                                       ConnectionService.SERVER_REQ_KEY.LONGTITUDE : lon]
        return Resource<UserProfile>(withURL : App.Myself.updateMyLocation.url,
                                     withMethod : HTTPMethod.post,
                                     withParams : params) { data in
                                        
                                        let _json = JSON(data : data)
                                        
                                        print("JSON: \(_json)") // serialized json response
                                        
                                        
                                        if let _codeStr = _json["code"].string,
                                            let _code = SERVER_RESPONSE_CODE(rawValue: _codeStr),
                                            let _status = _json["status"].string{
                                            switch _code {
                                            case .SUCCESS:
                                                break
                                            case .FAILURE:
                                                return (ServerResponse(withCode : .FAILURE, withStatus : _status), nil)
                                            default:
                                                break
                                            }
                                        }
                                        
                                        return (ServerResponse(), nil)
        }
    }
    
    static func getUserLocation(_ _groupId : Int, _ _userId: String) -> Resource<UserProfile> {
        let params : [String : Any] = [ConnectionService.SERVER_REQ_KEY.USER_ID : _userId,
                                       ConnectionService.SERVER_REQ_KEY.GROUP_ID : _groupId]
        
        return Resource<UserProfile>(withURL : App.User.getLocation.url,
                                     withMethod : HTTPMethod.get,
                                     withParams : params) { data in
                                        
                                        let _json = JSON(data : data)
                                        
                                        print("JSON: \(_json)") // serialized json response
                                        
                                        if let _codeStr = _json["code"].string,
                                            let _code = SERVER_RESPONSE_CODE(rawValue: _codeStr),
                                            let _status = _json["status"].string{
                                            switch _code {
                                            case .SUCCESS:
                                                let _locationJSON = _json["data"]
                                                let _userLat = _locationJSON["lat"].floatValue
                                                let _userLong = _locationJSON["lon"].floatValue
                                                    
                                                return (ServerResponse(withCode : .SUCCESS, withStatus : _status), [["lat" : _userLat, "lon" : _userLong]])
                                                    
                                            case .FAILURE:
                                                return (ServerResponse(withCode : .FAILURE, withStatus : _status), nil)
                                            default:
                                                break
                                            }
                                        }
                                        
                                        return (ServerResponse(), nil)
        }
    }
    
    static func searchUsers(_ searchParam : String) -> Resource<UserProfile> {
        
        let params : [String : Any] = [ConnectionService.SERVER_REQ_KEY.SEARCH_STRING : searchParam]
        
        return Resource<UserProfile>(withURL : App.User.getLocation.url,
                                     withMethod : HTTPMethod.get,
                                     withParams : params) { data in
                                        
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
//                                                        let _userLat = _userJSON["lat"].floatValue
//                                                        let _userLong = _userJSON["lon"].floatValue
                                                        let _userImage = _userJSON["userimage"].stringValue
                                                        
                                                        let _user = UserProfile(withId: _userId, withAvatar: _userImage, withName: _userName, withLat: 0, withLong: 0)
                                                        
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
