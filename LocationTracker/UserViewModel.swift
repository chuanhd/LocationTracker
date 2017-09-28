//
//  UserViewModel.swift
//  LocationTracker
//
//  Created by Chuan Ho Danh on 9/28/17.
//  Copyright © 2017 tranght. All rights reserved.
//

import Foundation
import GoogleMaps

class UserViewModel {
    var m_UserProfile : UserProfile?
    var m_Marker : GMSMarker?
    
    init(withProfile _user : UserProfile) {
        m_UserProfile = _user
    }
    
    func createOrUpdateMarker(onMap _map : GMSMapView) {
        
    }
    
}
