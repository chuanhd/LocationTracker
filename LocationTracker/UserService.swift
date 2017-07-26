//
//  UserService.swift
//  LocationTracker
//
//  Created by chuanhd on 7/23/17.
//  Copyright © 2017 tranght. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class UserService {
    class func login(withDeviceId deviceId : String, completionHandler completion: (_ result: JSON, _ error: NSError?) -> Void) {
        ConnectionService.load(UserProfile.login) { (myProfile : UserProfile?, error : Error?) in
            
        }
    }
}
