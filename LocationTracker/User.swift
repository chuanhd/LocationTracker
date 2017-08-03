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
    public var mId : Int = -1
    public var mAvatarURLStr : String = ""
    public var mLatitude : Float = -1
    public var mLongtitude : Float = -1
        
    init(withId _id : Int, withAvatar _avatarURLStr : String, withLat _lat : Float, withLong _long : Float) {
        mId = _id
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
                                             withParams : [ConnectionService.SERVER_REQ_KEY.DEVICE_ID : AppController.sharedInstance.mUniqueToken]) { data in
                                                
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
        var params : [String : Any] = [ConnectionService.SERVER_REQ_KEY.DEVICE_ID : AppController.sharedInstance.mUniqueToken,
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
        let params : [String : Any] = [ConnectionService.SERVER_REQ_KEY.DEVICE_ID : AppController.sharedInstance.mUniqueToken,
                                       ConnectionService.SERVER_REQ_KEY.LATITUDE : lat,
                                       ConnectionService.SERVER_REQ_KEY.LONGTITUDE : lon]
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
}
