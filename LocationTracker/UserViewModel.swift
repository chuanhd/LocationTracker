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
        
        guard let _profile = self.m_UserProfile else {
            return
        }
        
        if let _marker = self.m_Marker {
            _marker.position = CLLocationCoordinate2D(latitude: _profile.mLatitude, longitude: _profile.mLongtitude)
        } else {
            self.m_Marker = GMSMarker(position: CLLocationCoordinate2D(latitude: _profile.mLatitude, longitude: _profile.mLongtitude))
            self.m_Marker!.map = _map
            
            let _customMarkerIconView = CustomMarkerIconView(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
            _customMarkerIconView.loadImage(fromURL: URL(string: _profile.mAvatarURLStr)!)
            
            self.m_Marker!.iconView = _customMarkerIconView
        }
    }
    
}
