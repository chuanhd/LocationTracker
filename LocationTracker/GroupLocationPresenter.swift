//
//  GroupLocationPresenter.swift
//  LocationTracker
//
//  Created by chuanhd on 7/23/17.
//  Copyright © 2017 tranght. All rights reserved.
//

import Foundation
import CoreLocation

protocol GroupLocationPresenterDelegate : class {
    func locationDidUpdate(_newLocation : CLLocation)
}

class GroupLocationPresenter : NSObject {
    
    internal let mLocationService = LocationService.shared
    public weak var delegate : GroupLocationPresenterDelegate?
    
    override init() {
        
    }
    
    public func startLocationUpdates() {
        mLocationService.delegate = self
        mLocationService.activityType = .other
        mLocationService.distanceFilter = 10
        mLocationService.startUpdatingLocation()
    }
}

extension GroupLocationPresenter : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for newLocation in locations {
            let howRecent = newLocation.timestamp.timeIntervalSinceNow
            
            print("New Location fetched with horizontal accuracy: \(newLocation.horizontalAccuracy)")
            
            guard newLocation.horizontalAccuracy < 200 && abs(howRecent) < 10 else { continue }
            
            delegate?.locationDidUpdate(_newLocation: newLocation)
            
        }
    }
}
