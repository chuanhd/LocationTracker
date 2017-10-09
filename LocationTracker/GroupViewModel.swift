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
    private var m_ImageMarkerDict = Dictionary<String, GMSMarker>()
    private var m_DestinationMarker : GMSMarker?
    private var m_Polyline : GMSPolyline?
    
    init(withGroup _group : Group) {
        self.m_Group = _group
    }
    
    func createOrUpdateMarkerForUser(withId userId : String, withLat lat : Double, withLong lon: Double, onMap _mapView : GMSMapView) {
        if let _marker = m_MarkerDict[userId] {
            _marker.position = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        } else {
            
            let position = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            let _marker = GMSMarker(position: position)
            _marker.map = _mapView
            let _customMarkerIconView = CustomMarkerIconView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
            if let _selectedGroup = self.m_Group {
                if let _userProfile = (_selectedGroup.mUsers.filter { $0.mId == userId}).first {
                    _customMarkerIconView.loadImage(fromURL: URL(string: _userProfile.mAvatarURLStr)!)
                }
            }
            
            _marker.iconView = _customMarkerIconView
            m_MarkerDict[userId] = _marker
            
        }
    }
    
    func createOrUpdateDestinationMarker(onMap _mapView : GMSMapView) {
        
        guard let _lat = self.m_Group?.m_DestLat, let _lon = self.m_Group?.m_DestLon else {
            return
        }
        
        if let _destinationMarker = self.m_DestinationMarker {
            _destinationMarker.position = CLLocationCoordinate2D(latitude: _lat, longitude: _lon)
        } else {
            let position = CLLocationCoordinate2D(latitude: _lon, longitude: _lon)
            self.m_DestinationMarker = GMSMarker(position: position)
            self.m_DestinationMarker!.map = _mapView
        }
    }
    
    func createOrUpdateRouteToGroupDestination(onMap _mapView : GMSMapView, completion: @escaping (_ error : Error?) -> ()) {
        guard let _lat = self.m_Group?.m_DestLat, let _lon = self.m_Group?.m_DestLon else {
            return
        }
        
        let _updateRouteClosure : (_ _polyline : GMSPolyline) -> () = {[unowned self] (_polyline) in
            if let _routeLines = self.m_Polyline {
                _routeLines.map = nil
            }
            self.m_Polyline = _polyline
            self.m_Polyline?.map = _mapView
        }
        
        if let _myProfile = AppController.sharedInstance.mOwnProfile {
            let _origin = CLLocationCoordinate2D(latitude: _myProfile.mLatitude, longitude: _myProfile.mLongtitude)
            let _destination = CLLocationCoordinate2D(latitude: _lat, longitude: _lon)
            GoogleMapsDirectionsHelper.getDirection(from: _origin, to: _destination,
                                                    completion: { ( _response, _polyline, _error) in
                                                    
                                                        switch _response.code {
                                                        case .SUCCESS:
                                                        
                                                            _updateRouteClosure(_polyline!)
                                                            completion(nil)
                                                            
                                                            break
                                                        case .FAILURE:
                                                            
                                                            completion(_error)
                                                            
                                                            break
                                                        default:
                                                            break
                                                        }
                                                        
                                                        
            })
        }
    }
    
    func createOrUpdateImageMarker(withId userId : String, withLat lat : Double, withLong lon: Double, onMap _mapView : GMSMapView) {
        let _dictKey = "\(userId)_\(lat)_\(lon)"
        if let _marker = m_ImageMarkerDict[_dictKey] {
            _marker.position = CLLocationCoordinate2D(latitude: lat, longitude: lat)
        } else {
            
            let position = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            let _marker = GMSMarker(position: position)
            _marker.map = _mapView
            let _customMarkerIconView = CustomImageMarkerIconView(frame: CGRect(x: 0, y: 0, width: 40, height: 60))
//            if let _selectedGroup = self.m_Group {
//                if let _userProfile = (_selectedGroup.mUsers.filter { $0.mId == userId}).first {
//                    _customMarkerIconView.loadImage(fromURL: URL(string: _userProfile.mAvatarURLStr)!)
//                }
//            }
            
            _marker.iconView = _customMarkerIconView
            m_ImageMarkerDict[userId] = _marker
            
        }
    }
    
    func getMarkerForUser(withUserId _userId : String) -> GMSMarker? {
        return m_MarkerDict[_userId]
    }
    
    func getDestinationMarker() -> GMSMarker? {
        return m_DestinationMarker
    }
    
    
    
    
    
}
