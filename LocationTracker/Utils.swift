//
//  Utils.swift
//  LocationTracker
//
//  Created by chuanhd on 7/23/17.
//  Copyright © 2017 tranght. All rights reserved.
//

import Foundation
import Locksmith
import UIKit

class Utils {
    static func getDeviceId() -> String {
        let appName = Bundle.main.infoDictionary![String(kCFBundleNameKey)] as! String
        var strAppUUID : String?
        if let data = Locksmith.loadDataForUserAccount(userAccount: "tranght", inService: appName) {
            strAppUUID = data["deviceId"] as? String
        }
        if strAppUUID == nil {
            strAppUUID = UIDevice.current.identifierForVendor?.uuidString
            //try Locksmith.saveData(["some key": "some value"], forUserAccount: "myUserAccount")
            do {
                try Locksmith.saveData(data: ["deviceId" : strAppUUID!], forUserAccount: "tranght", inService: appName)
            } catch {
                print("error in get deviceID: \(error)")
            }
        }
        //print(strAppUUID)
        return strAppUUID!
    }
    
    static func createAlertViewController(withTitle _title : String?, withMessage _message : String) -> UIAlertController {
        let _alertViewController = UIAlertController(title: _title, message: _message, preferredStyle: UIAlertControllerStyle.alert)
        let _cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (_action) in
            
        }
        _alertViewController.addAction(_cancelAction)
        return _alertViewController
    }
}
