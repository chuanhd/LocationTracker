//
//  GroupMemberCollectionViewCell.swift
//  LocationTracker
//
//  Created by chuanhd on 7/23/17.
//  Copyright © 2017 tranght. All rights reserved.
//

import UIKit
import SDWebImage

class GroupMemberCollectionViewCell: UICollectionViewCell {

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
    
    func bindDataToView(_ _data : UserProfile!) {
        imgAvatar.sd_setImage(with: URL(string: _data.mAvatarURLStr), placeholderImage: UIImage(named: "default_avatar"), options: SDWebImageOptions.continueInBackground) { (image, error, type, url) in
            if let _error = error {
                print("Load image failed with error \(_error)")
            }
        }
        self.lblUsername.text = _data.mUsername
    }

}
