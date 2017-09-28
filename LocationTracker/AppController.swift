//
//  AppController.swift
//  LocationTracker
//
//  Created by chuanhd on 7/23/17.
//  Copyright © 2017 tranght. All rights reserved.
//

import Foundation

class AppController {
    
    var mOwnProfile : UserProfile?
    var mUniqueToken = Utils.getDeviceId()
    
    class var sharedInstance: AppController {
        struct Static {
            static let instance = AppController()
        }
        return Static.instance
    }
    
    private init() {}
    
    func fetchOwnProfile(completion: @escaping (_ response : ServerResponse, _ error : Error?) -> ()) {
        ConnectionService.load(UserProfile.getUserInfo(AppController.sharedInstance.mUniqueToken)) { (_response, _result, _error) in
            switch _response.code {
            case .SUCCESS:
                
                guard let _users = _result as? [UserProfile], _users.count > 0 else {
                    return
                }
                
                AppController.sharedInstance.mOwnProfile = _users.first
                
                break
            case .FAILURE:
                print("Fail to get my profile")
                break
            default:
                break
            }
            
            completion(_response, _error)
        }
    }
    
}

extension AppController {

}
