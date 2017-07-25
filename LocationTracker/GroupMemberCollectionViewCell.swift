//
//  GroupMemberCollectionViewCell.swift
//  LocationTracker
//
//  Created by chuanhd on 7/23/17.
//  Copyright © 2017 tranght. All rights reserved.
//

import UIKit

class GroupMemberCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imgAvatar: UIImageView!
    @IBOutlet weak var lblUsername: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.imgAvatar.clipsToBounds = true
        self.imgAvatar.layer.cornerRadius = self.imgAvatar.frame.size.width/2.0
        self.imgAvatar.layer.borderColor = UIColor.white.cgColor
        self.imgAvatar.layer.borderWidth = 4.0
    }

}
