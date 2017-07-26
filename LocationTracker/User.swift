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
                                             withParams : ["deviceid" : AppController.sharedInstance.mUniqueToken]) { data in
                                                
                                                let _json = JSON(data : data)
                                                
                                                print("JSON: \(_json)") // serialized json response

                                                
                                                if let _codeStr = _json["code"].string,
                                                    let _code = SERVER_RESPONSE_CODE(rawValue: _codeStr),
                                                let _status = _json["status"].string{
                                                    switch _code {
                                                    case .SUCCESS:
                                                        break
                                                    case .USER_NOT_EXIST:
                                                        return (ServerResponse(withCode : .USER_NOT_EXIST, withStatus : _status), nil)
                                                    default:
                                                        break
                                                    }
                                                }
      
                                                return (ServerResponse(), nil)
    }
}
