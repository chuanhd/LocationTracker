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
    @IBOutlet weak var viewLoadingIndicator: UIActivityIndicatorView!
    
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
        var _placeHolderImage = self.imgAvatar.image
        if _placeHolderImage == nil {
            _placeHolderImage = UIImage(named: "default_avatar")
        }
        imgAvatar.sd_setImage(with: URL(string: _data.mAvatarURLStr), placeholderImage: _placeHolderImage, options: SDWebImageOptions.continueInBackground, progress: { (receivedSize, expectedSize, targetURL) in
            DispatchQueue.main.async {
                self.viewLoadingIndicator.startAnimating()
                self.viewLoadingIndicator.isHidden = false
            }
        }) { (image, error, type, url) in
            DispatchQueue.main.async {
                self.viewLoadingIndicator.stopAnimating()
                self.viewLoadingIndicator.isHidden = true
                if let _error = error {
                    print("Load image failed with error \(_error)")
//                    self.imgAvatar.image = UIImage(named: "default_avatar")
                }
            }
        }
        self.lblUsername.text = _data.mUsername
    }

}
