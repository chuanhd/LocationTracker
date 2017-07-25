//
//  AppController.swift
//  LocationTracker
//
//  Created by chuanhd on 7/23/17.
//  Copyright © 2017 tranght. All rights reserved.
//

import Foundation


class AppController {
    
//    var mOwnProfile : UserProfile
    var mUniqueToken = Utils.getDeviceId()
    
    class var sharedInstance: AppController {
        struct Static {
            static let instance = AppController()
        }
        return Static.instance
    }
    
    private init() {}
    
    
}
