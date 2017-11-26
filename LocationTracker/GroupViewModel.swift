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
    
    deinit {
        if let _destinationMarker = self.m_DestinationMarker {
            _destinationMarker.map = nil
        }

        if let _route = self.m_Polyline {
            _route.map = nil
        }

        m_MarkerDict.forEach { (_, _marker) in
            _marker.map = nil
        }

        m_ImageMarkerDict.forEach { (_, _marker) in
            _marker.map = nil
        }
    }
    
    init(withGroup _group : Group) {
        self.m_Group = _group
    }
    
    func createOrUpdateMarkerForUser(withId userId : String, withLat lat : Double?, withLong lon: Double?, onMap _mapView : GMSMapView) {
        
        if let _lat = lat, let _lon = lon {
            if let _marker = m_MarkerDict[userId] {
                _marker.position = CLLocationCoordinate2D(latitude: _lat, longitude: _lon)
            } else {
                
                let position = CLLocationCoordinate2D(latitude: _lat, longitude: _lon)
                let _marker = GMSMarker(position: position)
                _marker.map = _mapView
                _marker.zIndex = Constants.ZIndex.ZERO.rawValue;
                m_MarkerDict[userId] = _marker
            }
        }
        
        if let _marker = m_MarkerDict[userId] {
            if let _customMarkerIconView = _marker.iconView as? CustomMarkerIconView {
                if let _selectedGroup = self.m_Group {
                    if let _userProfile = (_selectedGroup.mUsers.filter { $0.mId == userId}).first {
                        _customMarkerIconView.loadImage(fromURL: URL(string: _userProfile.mAvatarURLStr))
                    }
                }
            } else {
                let _customMarkerIconView = CustomMarkerIconView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
                if let _selectedGroup = self.m_Group {
                    if let _userProfile = (_selectedGroup.mUsers.filter { $0.mId == userId}).first {
                        _customMarkerIconView.loadImage(fromURL: URL(string: _userProfile.mAvatarURLStr))
                    }
                }
                _marker.iconView = _customMarkerIconView
            }
        }
    }
    
    func updateMarkerImageForUsers() {
        guard let _group = self.m_Group else {
            return
        }
        for _userInfo in _group.mUsers {
            self.updateMarkerImageForUser(withID: _userInfo.mId)
        }
    }
    
    func updateMarkerImageForUser(withID _userId : String) {
        if let _marker = m_MarkerDict[_userId], let _imgViewAvatar = _marker.iconView as? CustomMarkerIconView {
            if let _selectedGroup = self.m_Group {
                if let _userProfile = (_selectedGroup.mUsers.filter { $0.mId == _userId}).first {
                    _imgViewAvatar.loadImage(fromURL: URL(string: _userProfile.mAvatarURLStr))
                }
            }
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

    func createOrUpdateImageMarker(withGroupImage _groupImage : GroupImage, onMap _mapView : GMSMapView) {
        
        let userId =  _groupImage.m_OwnerID;
        let lat = _groupImage.m_Lat;
        let lon = _groupImage.m_Lon;
        let url = _groupImage.m_Url
        let _dictKey = "\(userId)_\(lat)_\(lon)"
        if let _marker = m_ImageMarkerDict[_dictKey] {
            _marker.position = CLLocationCoordinate2D(latitude: lat, longitude: lat)
        } else {
            
            let position = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            let _marker = GMSMarker(position: position)
            _marker.map = _mapView
            let _customMarkerIconView = CustomImageMarkerIconView(frame: CGRect(x: 0, y: 0, width: 40, height: 60))
            _customMarkerIconView.loadImage(fromURL: url)
            _customMarkerIconView.m_Obj = _groupImage
            _marker.iconView = _customMarkerIconView
            m_ImageMarkerDict[_dictKey] = _marker
            
            _marker.zIndex = Constants.ZIndex.ONE.rawValue;
        }
    }
    
    func getMarkerForUser(withUserId _userId : String) -> GMSMarker? {
        return m_MarkerDict[_userId]
    }
    
    func getDestinationMarker() -> GMSMarker? {
        return m_DestinationMarker
    }
    
    func deleteUserMarkerAndImageMarkers(ofUser _userId : String) {
        if let _marker = m_MarkerDict[_userId] as? GMSMarker{
            _marker.map = nil
        }
        
        m_MarkerDict.removeValue(forKey: _userId)
        
        m_ImageMarkerDict.filter { (_markerId, _) -> Bool in
            return _markerId.contains(_userId)
            }.forEach { (_markerId, _imageMarker) in
                _imageMarker.map = nil
                m_ImageMarkerDict.removeValue(forKey: _markerId)
            }
        
        
    }
    
    func clearGroupMarkersAndRouteOnMap() {
        print("Before clear location marker: ", m_MarkerDict.count)
        
//        let _notMyself = m_MarkerDict.filter { (_userId, _marker) -> Bool in
//            return _userId != AppController.sharedInstance.mUniqueToken
//        }
//
//        var _removedIds = [String]()
//        _notMyself.forEach { (_userId, _marker) in
//            _marker.map = nil
//            _removedIds.append(_userId)
//        }
//
//        _removedIds.forEach { (_userId) in
//            m_MarkerDict.removeValue(forKey: _userId)
//        }
        
        m_MarkerDict.forEach { (_, _marker) in
            _marker.map = nil
        }
        
        clearRouteOnMap()
        m_MarkerDict.removeAll()

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
