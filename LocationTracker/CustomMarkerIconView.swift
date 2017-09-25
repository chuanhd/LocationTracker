//
//  CustomMarkerIconView.swift
//  LocationTracker
//
//  Created by chuanhd on 9/25/17.
//  Copyright © 2017 tranght. All rights reserved.
//

import UIKit
import SDWebImage

class CustomMarkerIconView: UIImageView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.setupView()
    }
    
    internal func setupView() {
        self.clipsToBounds = true
        self.layer.cornerRadius = self.frame.size.width/2.0
        let _borderColor = UIColor(red: 46/255.0, green: 177/255.0, blue: 135/255.0, alpha: 1)
        self.layer.borderColor = _borderColor.cgColor
        self.layer.borderWidth = 4.0
    }
    
    func loadImage(fromURL _url : URL) {
        self.sd_setImage(with: _url, placeholderImage: UIImage(named: "default_avatar.png"), options: SDWebImageOptions.continueInBackground) { (_image, _error, _cacheType, _otherUrl) in
            
        }
    }
}
