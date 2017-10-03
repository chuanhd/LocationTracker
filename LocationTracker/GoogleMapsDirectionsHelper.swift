//
//  GoogleMapsDirectionsHelper.swift
//  LocationTracker
//
//  Created by chuanhd on 10/3/17.
//  Copyright © 2017 tranght. All rights reserved.
//

import Foundation
import GoogleMaps
import Alamofire
import SwiftyJSON

class GoogleMapsDirectionsHelper {
    
    static let m_GoogleMapsDirectionsAPIEndPoint = "https://maps.googleapis.com/maps/api/directions/json"
    
    static func getDirection(from _coordinate : CLLocationCoordinate2D, to _destCoordinate : CLLocationCoordinate2D) {
        
        let params : [String : Any] = ["origin" : "\(_coordinate.latitude),\(_coordinate.longitude)",
                                       "destination" : "\(_destCoordinate.latitude),\(_destCoordinate.longitude)",
                                       "key" : Constants.Google_Maps_API_Key]
        
        let endPointURL = URL(string: m_GoogleMapsDirectionsAPIEndPoint)!;
        
        Alamofire.request(endPointURL, method: Alamofire.HTTPMethod.get, parameters : params).validate().responseJSON { response in
            print("Request: \(String(describing: response.request))")   // original url request
            print("Response: \(String(describing: response.response))") // http url response
            print("Result: \(response.result)")                         // response serialization result
            
            let _json = JSON(data : response.data!)
            
            print("JSON: \(_json)") // serialized json response
            
        }
    }
}
