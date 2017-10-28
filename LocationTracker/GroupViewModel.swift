//
//  GroupViewModel.swift
//  LocationTracker
//
//  Created by Chuan Ho Danh on 9/28/17.
//  Copyright © 2017 tranght. All rights reserved.
//

import UIKit
import GoogleMaps
import Lightbox

class GroupViewModel : NSObject {
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
            _marker.zIndex = Constants.ZIndex.ZERO.rawValue;
            
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
        
        self.m_DestinationMarker!.zIndex = Constants.ZIndex.TWO.rawValue;
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
    
    func createOrUpdateImageMarker(withUserId userId : String, withLat lat : Double, withLong lon: Double, withImageUrl url : URL, onMap _mapView : GMSMapView) {
        let _dictKey = "\(userId)_\(lat)_\(lon)"
        if let _marker = m_ImageMarkerDict[_dictKey] {
            _marker.position = CLLocationCoordinate2D(latitude: lat, longitude: lat)
        } else {
            
            let position = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            let _marker = GMSMarker(position: position)
            _marker.map = _mapView
            let _customMarkerIconView = CustomImageMarkerIconView(frame: CGRect(x: 0, y: 0, width: 40, height: 60))
            _customMarkerIconView.loadImage(fromURL: url)
            
            _marker.iconView = _customMarkerIconView
            m_ImageMarkerDict[userId] = _marker
            
            _marker.zIndex = Constants.ZIndex.ONE.rawValue;
        }
    }
    
    func createOrUpdateImageMarker(withGroupImage _groupImage : GroupImage, onMap _mapView : GMSMapView) {
        self.createOrUpdateImageMarker(withUserId: _groupImage.m_OwnerID, withLat: _groupImage.m_Lat, withLong: _groupImage.m_Lon, withImageUrl: _groupImage.m_Url, onMap: _mapView)
    }
    
    func getMarkerForUser(withUserId _userId : String) -> GMSMarker? {
        return m_MarkerDict[_userId]
    }
    
    func getDestinationMarker() -> GMSMarker? {
        return m_DestinationMarker
    }
    
    func clearGroupMarkersAndRouteOnMap() {
        let _notMyself = m_MarkerDict.filter { (_userId, _marker) -> Bool in
            return _userId != AppController.sharedInstance.mUniqueToken
        }
        
        _notMyself.forEach { (_, _marker) in
            _marker.map = nil
        }
        
        clearRouteOnMap()
    }
    
    func clearRouteOnMap() {
        if let _polyline = self.m_Polyline {
            _polyline.map = nil
        }
    }
    
    func isImageMarker(_ _marker : GMSMarker) -> Bool {
        return m_ImageMarkerDict.values.contains(_marker)
    }
}

extension GroupViewModel : GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        
//        if self.isImageMarker(marker) {
//            if let _customMarkerIconView = marker.iconView as? CustomImageMarkerIconView {
//
//            }
//        }
        
        return false
    }
}
