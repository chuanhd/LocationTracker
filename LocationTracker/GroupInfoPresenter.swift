//
//  GroupInfoPresenter.swift
//  LocationTracker
//
//  Created by chuanhd on 7/23/17.
//  Copyright © 2017 tranght. All rights reserved.
//

import Foundation
import SwiftyJSON

protocol GroupInfoPresenterDelegate : class {
    
}

class GroupInfoPresenter {
    internal lazy var mUserService = UserService()
    
    var mUserList : [UserProfile] = []
    
    func doLogin() {
        mUserService.login(withDeviceId: AppController.sharedInstance.mUniqueToken) { (result : JSON, error : NSError?) in
            if let _error = error {
                print(_error)
            } else {
                
            }
        }
    }
    
    
    
}
