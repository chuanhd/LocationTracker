//
//  GroupTableViewCell.swift
//  LocationTracker
//
//  Created by Chuan Ho Danh on 8/14/17.
//  Copyright © 2017 tranght. All rights reserved.
//

import UIKit

protocol GroupTableViewCellDelegate : class {
    func didTapConfigureGroup(atIndex _index : Int)
}

class GroupTableViewCell: UITableViewCell {

    @IBOutlet weak var lblGroupName: UILabel!
    @IBOutlet weak var lblGroupID: UILabel!
    @IBOutlet weak var imgGroupColor: UIImageView!
    private var m_Index : Int = -1
    weak var m_Delegate : GroupTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.imgGroupColor.layer.masksToBounds = true
        self.imgGroupColor.layer.cornerRadius = self.imgGroupColor.frame.size.width/2.0
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func btnConfigurePressed(_ sender: Any) {
        guard let _delegateMethod = self.m_Delegate?.didTapConfigureGroup else {
            return
        }
        
        _delegateMethod(self.m_Index)
    }
    
    func bindView(withData _group: Group, withIndex _index : Int) {
        self.lblGroupName.text = _group.mName
        self.lblGroupID.text = "\(_group.mId)"
        self.m_Index = _index
    }
}
