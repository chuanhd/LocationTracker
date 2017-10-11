//
//  GroupNameTitleView.swift
//  LocationTracker
//
//  Created by chuanhd on 8/14/17.
//  Copyright © 2017 tranght. All rights reserved.
//

import UIKit

protocol GroupNameTitleViewDelegate : class {
    func didTapOnGroupName()
}

class GroupNameTitleView: UIView {

    @IBOutlet weak var btnGroupName: UIButton!
    weak var m_Delegate : GroupNameTitleViewDelegate?
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    func setGroupName(_ _groupName : String) {
        btnGroupName.setTitle(_groupName, for: .normal)
    }
    
    @IBAction func btnGroupnamePressed(_ sender: Any) {
        guard let _delegateMethod = m_Delegate?.didTapOnGroupName else {
            return
        }
        
        _delegateMethod()
    }
}
