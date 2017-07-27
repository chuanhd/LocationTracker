//
//  CreateUserViewController.swift
//  LocationTracker
//
//  Created by Chuan Ho Danh on 7/26/17.
//  Copyright © 2017 tranght. All rights reserved.
//

import UIKit

class CreateUserViewController: UIViewController {

    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtName : UITextField!
    @IBOutlet weak var txtPhoneNumber : UITextField!
    
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    @IBAction func doneBtnPressed(_ sender: Any) {
        ConnectionService.load(UserProfile.createUpdateMyInfoResource(txtEmail.text, txtName.text, txtPhoneNumber.text)) { (_ response : ServerResponse, _ myProfile : UserProfile?, _ error : Error?) in
        }
    }
}
