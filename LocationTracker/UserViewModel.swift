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
    
    var m_Username : String? {
        return m_UserProfile?.mUsername
    }
    
    var m_Email : String? {
        return m_UserProfile?.mEmail
    }
    
    var m_PhoneNumber : String? {
        return m_UserProfile?.mPhoneNumber
    }
    
    var m_AvatarURL : URL? {
        return URL(string: (m_UserProfile?.mAvatarURLStr)!)
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
    
    public func updateUserProfileModel(_ _email : String?, _ _phoneNumber : String?,_ _avatarURL : String?) {
        guard let _profile = self.m_UserProfile else {
            return
        }
        
        if let _email = _email {
            _profile.mEmail = _email
        }
        
        if let _phoneNumber = _phoneNumber {
            _profile.mPhoneNumber = _phoneNumber
        }
        
        if let _avatarURL = _avatarURL {
            _profile.mAvatarURLStr = _avatarURL
        }
        
        if _profile.mId == AppController.sharedInstance.mOwnProfile?.mId {
            AppController.sharedInstance.mOwnProfile = _profile
        }
        
    }
    
}
