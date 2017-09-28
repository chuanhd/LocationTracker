//
//  ListGroupsView.swift
//  LocationTracker
//
//  Created by chuanhd on 9/24/17.
//  Copyright © 2017 tranght. All rights reserved.
//

import UIKit
import SnapKit

protocol ListGroupViewDelegate : class {
    func didTapRequestJoinGroup()
    func didTapCreateGroup()
    func didSelectGroup(_ _group : Group)
    func didConfigureGroup(_ _group : Group)
}

class ListGroupsView: UIView {

    @IBOutlet weak var btnJoinGroup : UIButton!
    @IBOutlet weak var btnCreateGroup : UIButton!
    @IBOutlet weak var tblListGroups : UITableView!
    var m_TableCellHeight : CGFloat = 80.0
    
    weak var delegate : ListGroupViewDelegate? = nil
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    
        setupView()
    }
    
    internal func setupView() {
        guard let _contentView = self.viewFromNibClass() else {
            return
        }
        _contentView.frame = self.bounds
        self.addSubview(_contentView)
        _contentView.snp.makeConstraints({ (make) in
            make.edges.equalTo(self).inset(UIEdgeInsetsMake(0, 0, 0, 0))
        })
    }
    
    internal func viewFromNibClass() -> UIView? {
        guard let _view = Bundle.main.loadNibNamed("ListGroupsView", owner: self, options: nil)?.first as? UIView else {
            return nil
        }
        
        return _view
    }
    
    var mGroups = [Group]() {
        didSet {
//            let _numOfItems = mGroups.count
//            var _tableHeight : CGFloat = CGFloat(_numOfItems) * CGFloat(60.0)
//            if _tableHeight == 0 {
//                _tableHeight = 60
//            } else if (_tableHeight > self.view.frame.size.height * 0.5) {
//                _tableHeight = self.view.frame.size.height * 0.5
//            }
//
//            self.constraintTableHeight.constant = _tableHeight
//
//            DispatchQueue.main.async {
//                self.view.setNeedsLayout()
//                self.view.layoutIfNeeded()
//            }
            
        }
    }
        
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.btnJoinGroup.layer.masksToBounds = true
        self.btnJoinGroup.layer.borderWidth = 2.0
        self.btnJoinGroup.layer.borderColor = UIColor(red: 83/255.0, green: 181/255.0, blue: 169/255.0, alpha: 1).cgColor
        self.btnJoinGroup.layer.cornerRadius = 10.0
        
        self.btnCreateGroup.layer.masksToBounds = true
        self.btnCreateGroup.layer.borderWidth = 2.0
        self.btnCreateGroup.layer.borderColor = UIColor.white.cgColor
        self.btnCreateGroup.layer.cornerRadius = 10.0
        
        self.tblListGroups.register(UINib(nibName: "GroupTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: Constants.CellIdentifier.GroupTableViewCellIdentifier)
        self.tblListGroups.delegate = self
        self.tblListGroups.dataSource = self
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    func getAllGroups() {
        ConnectionService.load(Group.getAllGroups, true) {(_ response : ServerResponse, _ _groups : [Any]?, _ error : Error?) in
            switch response.code {
            case .SUCCESS:
                guard let _groups = _groups as? [Group] else {
                    return
                }
                self.mGroups = _groups
                self.reflectDataOnView()
                break
            case .GROUP_NOT_EXISTS:
                self.promptRequestCreateNewGroupAlert()
                break
            case .FAILURE:
                break
            default:
                break
            }
        }
    }
    
    internal func reflectDataOnView() {
        self.tblListGroups.reloadData()
    }
    
    @IBAction func btnJoinGroupPressed(_ sender: Any) {
        guard let delegateMethod = self.delegate?.didTapRequestJoinGroup else {
            return
        }
        
        delegateMethod()
    }
    
    @IBAction func btnCreateGroupPressed(_ sender: Any) {
        guard let delegateMethod = self.delegate?.didTapCreateGroup else {
            return
        }
        
        delegateMethod()
    }
    
    
    
    internal func promptRequestCreateNewGroupAlert() {
//        let _newGroupRequestAlert = UIAlertController(title: "New Group", message: "You are not in any group. You could join or create a new group", preferredStyle: UIAlertControllerStyle.alert)
//        
//        let _joinAGroupAction = UIAlertAction(title: "Join", style: UIAlertActionStyle.default) { ( action ) in
//            guard let delegateMethod = self.delegate?.didTapRequestJoinGroup else {
//                return
//            }
//            
//            delegateMethod()
//        }
//        _newGroupRequestAlert.addAction(_joinAGroupAction)
//        
//        let _createNewGroupAction = UIAlertAction(title: "Create", style: UIAlertActionStyle.default) { ( action ) in
//            guard let delegateMethod = self.delegate?.didTapCreateGroup else {
//                return
//            }
//            
//            delegateMethod()
//        }
//        _newGroupRequestAlert.addAction(_createNewGroupAction)
//        
//        self.present(_newGroupRequestAlert, animated: true, completion: nil)
    }

}

extension ListGroupsView : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let delegateMethod = self.delegate?.didSelectGroup else {
            return
        }
        
        let _group = mGroups[indexPath.row]
        
        delegateMethod(_group)
    }
}

extension ListGroupsView : UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return m_TableCellHeight
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.mGroups.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.CellIdentifier.GroupTableViewCellIdentifier, for: indexPath) as? GroupTableViewCell else {
            return UITableViewCell()
        }
        
        let _group = mGroups[indexPath.row]
        cell.bindView(withData: _group, withIndex:  indexPath.row)
        cell.m_Delegate = self
        
        return cell
    }
}

extension ListGroupsView : GroupTableViewCellDelegate {
    func didTapConfigureGroup(atIndex _index: Int) {
        guard let delegateMethod = self.delegate?.didConfigureGroup else {
            return
        }
        
        let _group = mGroups[_index]
        
        delegateMethod(_group)
    }
}


