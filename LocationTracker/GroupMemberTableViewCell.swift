//
//  GroupMemberTableViewCell.swift
//  LocationTracker
//
//  Created by chuanhd on 8/27/17.
//  Copyright © 2017 tranght. All rights reserved.
//

import UIKit
import SDWebImage

class GroupMemberTableViewCell: UITableViewCell {

    @IBOutlet weak var imgAvatar: UIImageView!
    @IBOutlet weak var lblUsername: UILabel!
    
    
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
    
    func bindDataToView(_ user : UserProfile) {
        self.imgAvatar.sd_setImage(with: URL(string: user.mAvatarURLStr), placeholderImage: UIImage(named: "default_avatar"), options: SDWebImageOptions.continueInBackground) { (image, error, type, url) in
            
        }
        self.lblUsername.text = user.mUsername
    }
}
