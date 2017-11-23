//
//  SetDestinationView.swift
//  LocationTracker
//
//  Created by chuanhd on 9/25/17.
//  Copyright © 2017 tranght. All rights reserved.
//

import UIKit
import GooglePlaces

protocol SetDestinationViewDelegate : class {
    func didSetDestination(at _coordinate : CLLocationCoordinate2D)
}

class SetDestinationView: UIView {
    
    @IBOutlet weak var lblAddress : UILabel!

    weak var delegate : SetDestinationViewDelegate?
    var m_AddressViewModel : AddressViewModel! {
        didSet {
            m_AddressViewModel.reverseCoordinate(completion: { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.lblAddress.text = strongSelf.m_AddressViewModel.m_FormattedAddress
            })
        }
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    @IBAction func btnSetPressed(_ sender: Any) {
        guard let _delegateMethod = self.delegate?.didSetDestination else {
            return
        }
        
        _delegateMethod(m_AddressViewModel.m_Coordinate)
    }
    
    @IBAction func btnCancelPressed(_ sender: Any) {
        self.removeFromSuperview()
    }
    
}
