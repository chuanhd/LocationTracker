//
//  ListGroupsViewController.swift
//  LocationTracker
//
//  Created by Chuan Ho Danh on 8/14/17.
//  Copyright © 2017 tranght. All rights reserved.
//

import UIKit

protocol ListGroupViewControllerDelegate : class {
    func didTapRequestJoinGroup()
    func didTapCreateGroup()
    func didSelectGroup(_ _group : Group)
    func didConfigureGroup(_ _group : Group)
}

class ListGroupsViewController: UIViewController {

    @IBOutlet weak var tblListGroups: UITableView!
    @IBOutlet weak var btnJoinGroup: UIButton!
    @IBOutlet weak var btnCreateGroup: UIButton!
    @IBOutlet weak var constraintTableHeight : NSLayoutConstraint!
    
    weak var delegate : ListGroupViewControllerDelegate? = nil
    
    var mGroups = [Group]() {
        didSet {
            let _numOfItems = mGroups.count
            var _tableHeight : CGFloat = CGFloat(_numOfItems) * CGFloat(60.0)
            if _tableHeight == 0 {
                _tableHeight = 60
            } else if (_tableHeight > self.view.frame.size.height * 0.5) {
                _tableHeight = self.view.frame.size.height * 0.5
            }
            
            self.constraintTableHeight.constant = _tableHeight
            
            DispatchQueue.main.async {
                self.view.setNeedsLayout()
                self.view.layoutIfNeeded()
            }
            
        }
    }
    
    override func loadView() {
        super.loadView()
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
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
//        self.tblListGroups.reloadData()
        
        if #available(iOS 11.0, *) {
            btnJoinGroup.addTarget(self, action: #selector(ListGroupsViewController.btnJoinGroupPressed), for: .touchUpInside)
            btnCreateGroup.addTarget(self, action: #selector(ListGroupsViewController.btnCreateGroupPressed), for: .touchUpInside)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        
//        self.tblListGroups.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

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
    
    internal func promptRequestCreateNewGroupAlert() {
        let _newGroupRequestAlert = UIAlertController(title: "New Group", message: "You are not in any group. You could join or create a new group", preferredStyle: UIAlertControllerStyle.alert)
        
        let _joinAGroupAction = UIAlertAction(title: "Join", style: UIAlertActionStyle.default) { ( action ) in
            guard let delegateMethod = self.delegate?.didTapRequestJoinGroup else {
                return
            }
            
            delegateMethod()
        }
        _newGroupRequestAlert.addAction(_joinAGroupAction)
        
        let _createNewGroupAction = UIAlertAction(title: "Create", style: UIAlertActionStyle.default) { ( action ) in
            guard let delegateMethod = self.delegate?.didTapCreateGroup else {
                return
            }
            
            delegateMethod()
        }
        _newGroupRequestAlert.addAction(_createNewGroupAction)
        
        self.present(_newGroupRequestAlert, animated: true, completion: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        for _touch in touches {
            let p = _touch.location(in: self.view)
            let view = self.view.hitTest(p, with: event)
            print("touched view: %@", view)
        }
//        for (UITouch *t in touches) {
//            CGPoint p = [t locationInView:self.view];
//            UIView *v = [self.view hitTest:p withEvent:event];
//            NSLog(@"touched view %@", v);
//        }
    }
    
}

extension ListGroupsViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let delegateMethod = self.delegate?.didSelectGroup else {
            return
        }
        
        let _group = mGroups[indexPath.row]
        
        delegateMethod(_group)
    }
}

extension ListGroupsViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
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

extension ListGroupsViewController : GroupTableViewCellDelegate {
    func didTapConfigureGroup(atIndex _index: Int) {
        guard let delegateMethod = self.delegate?.didConfigureGroup else {
            return
        }
        
        let _group = mGroups[_index]
        
        delegateMethod(_group)
    }
}

