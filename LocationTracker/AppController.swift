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
    
    public func fetchOwnProfile(showLoading _show : Bool = false, completion: @escaping (_ response : ServerResponse, _ error : Error?) -> ()) {
        ConnectionService.load(UserProfile.getUserInfo(AppController.sharedInstance.mUniqueToken), _show) { (_response, _result, _error) in
            switch _response.code {
            case .SUCCESS:
                
                guard let _users = _result as? [UserProfile], _users.count > 0 else {
                    return
                }
                
                AppController.sharedInstance.mOwnProfile = _users.first
                AppController.sharedInstance.mOwnProfile!.mId = AppController.sharedInstance.mUniqueToken
                
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
    
    public func isMasterOfGroup(_ group : Group?) -> Bool {
        guard let _group = group else {
            return false
        }
        
        return _group.groupMasterUserId() == AppController.sharedInstance.mUniqueToken
    }
    
}

extension AppController {

}
