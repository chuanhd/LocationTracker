//
//  UserProfileTableViewCell.swift
//  LocationTracker
//
//  Created by chuanhd on 9/22/17.
//  Copyright © 2017 tranght. All rights reserved.
//

import UIKit
import SDWebImage

protocol UserProfileTableViewCellDelegate : class {
    func didTapInviteUser(atIndex _index : Int)
}

class UserProfileTableViewCell: UITableViewCell {

    internal var m_Index : Int = -1;
    
    @IBOutlet weak var imgAvatar: UIImageView!
    @IBOutlet weak var lblUsername: UILabel!
    @IBOutlet weak var btnInvite : UIButton!
    weak var m_Delegate : UserProfileTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.imgAvatar.clipsToBounds = true
        self.imgAvatar.layer.cornerRadius = self.imgAvatar.frame.size.width/2.0
        let _borderColor = UIColor(red: 46/255.0, green: 177/255.0, blue: 135/255.0, alpha: 1)
        self.imgAvatar.layer.borderColor = _borderColor.cgColor
        self.imgAvatar.layer.borderWidth = 4.0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func bindDataToView(_ user : UserProfile, atIndex _index : Int) {
        m_Index = _index
        
        self.imgAvatar.sd_setImage(with: URL(string: user.mAvatarURLStr), placeholderImage: UIImage(named: "default_avatar"), options: SDWebImageOptions.continueInBackground) { (image, error, type, url) in
            
        }
        self.lblUsername.text = user.mUsername
    }

    @IBAction func btnInvitePressed(_ sender: Any) {
        guard let _delegateMethod = self.m_Delegate?.didTapInviteUser else {
            return
        }
        
        _delegateMethod(m_Index)
    }
    
}
