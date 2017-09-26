//
//  AddressViewModel.swift
//  LocationTracker
//
//  Created by chuanhd on 9/26/17.
//  Copyright © 2017 tranght. All rights reserved.
//

import Foundation
import GoogleMaps

class AddressViewModel {
    
    internal var m_Coordinate : CLLocationCoordinate2D
    var m_FormattedAddress : String!
    
    init(withCoordinate _coordinate : CLLocationCoordinate2D) {
        m_Coordinate = _coordinate
    }
    
    func reverseCoordinate(completion: @escaping () -> ()) {

        GMSGeocoder().reverseGeocodeCoordinate(self.m_Coordinate) { (_response : GMSReverseGeocodeResponse?, _error : Error?) in
            if _error != nil {
                print("Reverse address fail with error: \(String(describing: _error))")
                return
            }
            
            self.m_FormattedAddress = self.formattedAddress(_response?.firstResult())
            completion()
        }
    }
    
    func formattedAddress(_ _address : GMSAddress?) -> String? {
        guard let _address = _address else {
            return "Unspecified"
        }
        
        guard let _formattedAddress = _address.lines?.first else {
            return "Unspecified"
        }
        
        return _formattedAddress
    }
    
    func getCoordinate() -> CLLocationCoordinate2D {
        return m_Coordinate
    }
}
