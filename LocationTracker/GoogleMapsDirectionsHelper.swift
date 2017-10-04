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
    
    static func getDirection(from _coordinate : CLLocationCoordinate2D, to _destCoordinate : CLLocationCoordinate2D,
                             completion: @escaping (_ status : ServerResponse, _ polyline : GMSPolyline?, _ error : Error?) -> ()) {
        
        let params : [String : Any] = ["origin" : "\(_coordinate.latitude),\(_coordinate.longitude)",
                                       "destination" : "\(_destCoordinate.latitude),\(_destCoordinate.longitude)",
                                       "key" : Constants.Google_Maps_API_Key]
        
        let endPointURL = URL(string: m_GoogleMapsDirectionsAPIEndPoint)!;
        
        Alamofire.request(endPointURL, method: Alamofire.HTTPMethod.get, parameters : params).validate().responseJSON { response in
            print("Request: \(String(describing: response.request))")   // original url request
            print("Response: \(String(describing: response.response))") // http url response
            print("Result: \(response.result)")                         // response serialization result
            
            guard let _data = response.data else {
                return
            }
            
            let _json = JSON(data : _data)
            
            print("JSON: \(_json)") // serialized json response
            
            let _status = _json["status"].stringValue == "OK"
            
            if _status {
                if let _routeJSONs = _json["routes"].array {
                    if let _routeOverviewPolylines = _routeJSONs.first?["overview_polyline"] {
                        let _gmsPath = GMSPath(fromEncodedPath: _routeOverviewPolylines["points"].stringValue)
                        let _gmsPolyline = GMSPolyline(path: _gmsPath)
                        _gmsPolyline.strokeWidth = 4.0
                        _gmsPolyline.strokeColor = UIColor.red
                        completion(ServerResponse(code: SERVER_RESPONSE_CODE.SUCCESS, status: _json["status"].stringValue), _gmsPolyline, nil)
                    } else {
                        completion(ServerResponse(code: SERVER_RESPONSE_CODE.FAILURE, status: "Lack of neccessary data"), nil, UserFriendlyError(withDescription: "Missing overview_polylines in JSON response", withCode: Constants.ErrorCode.INVALID_DATA));
                    }
                } else {
                    completion(ServerResponse(code: SERVER_RESPONSE_CODE.FAILURE, status: "Lack of neccessary data"), nil, UserFriendlyError(withDescription: "Missing routes in JSON response", withCode: Constants.ErrorCode.INVALID_DATA));
                }
            } else {
                completion(ServerResponse(code: SERVER_RESPONSE_CODE.FAILURE, status: _json["status"].stringValue), nil, UserFriendlyError(withDescription: "Something wrong with Google Maps API", withCode: Constants.ErrorCode.EXTERNAL_LIB_ERROR));
            }
            
        }
    }
}
