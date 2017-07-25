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
    func login(withDeviceId deviceId : String, completionHandler completion: (_ result: JSON, _ error: NSError?) -> Void) {
        Alamofire.request("http://localhost:3000/api/user/", method: .post).validate().responseJSON { response in
            print("Request: \(String(describing: response.request))")   // original url request
            print("Response: \(String(describing: response.response))") // http url response
            print("Result: \(response.result)")                         // response serialization result
            
            /*
            if let json = response.result.value {
                print("JSON: \(json)") // serialized json response
            }
            
            if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                print("Data: \(utf8Text)") // original server data as UTF8 string
            }
 */
            
            switch response.result {
            case .success:
                print("Validation Successful")
                if let json = response.result.value {
                    print("JSON: \(json)") // serialized json response
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}
