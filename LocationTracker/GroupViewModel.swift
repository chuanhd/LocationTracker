//
//  GroupViewModel.swift
//  LocationTracker
//
//  Created by Chuan Ho Danh on 9/28/17.
//  Copyright © 2017 tranght. All rights reserved.
//

import UIKit
import GoogleMaps

class GroupViewModel {
    var m_Group : Group?
    
    private var m_MarkerDict = Dictionary<String, GMSMarker>()
    private var m_DestinationMarker : GMSMarker?
    
    init(withGroup _group : Group) {
        self.m_Group = _group
    }
    
    func createOrUpdateMarkerForUsers() {
        
    }
    
    func createOrUpdateMarkerForUser(withId userId : String, withLat lat : Double, withLong lon: Double, onMap _mapView : GMSMapView) {
        if let _marker = m_MarkerDict[userId] {
            let _newLocation = CLLocation(latitude: lat, longitude: lon)
            _marker.position = _newLocation.coordinate
        } else {
            
            let position = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            let _marker = GMSMarker(position: position)
            _marker.map = _mapView
            let _customMarkerIconView = CustomMarkerIconView(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
            if let _selectedGroup = self.m_Group {
                if let _userProfile = (_selectedGroup.mUsers.filter { $0.mId == userId}).first {
                    _customMarkerIconView.loadImage(fromURL: URL(string: _userProfile.mAvatarURLStr)!)
                }
            }
            
            _marker.iconView = _customMarkerIconView
            m_MarkerDict[userId] = _marker
            
        }
    }
    
    func createOrUpdateDestinationMarker(withLat lat : Double, withLong lon: Double, onMap _mapView : GMSMapView) {
        if let _destinationMarker = self.m_DestinationMarker {
            let _newLocation = CLLocation(latitude: lat, longitude: lon)
            _destinationMarker.position = _newLocation.coordinate
        } else {
            let position = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            m_DestinationMarker = GMSMarker(position: position)
            m_DestinationMarker?.map = _mapView
        }
    }
    
    func getMarkerForUser(withUserId _userId : String) -> GMSMarker? {
        return m_MarkerDict[_userId]
    }
    
    func getDestinationMarker() -> GMSMarker? {
        return m_DestinationMarker
    }
    
}
