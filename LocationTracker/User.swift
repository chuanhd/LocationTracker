//
//  User.swift
//  LocationTracker
//
//  Created by chuanhd on 7/23/17.
//  Copyright © 2017 tranght. All rights reserved.
//

import Foundation

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
