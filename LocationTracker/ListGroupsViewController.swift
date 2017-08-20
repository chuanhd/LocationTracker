//
//  ListGroupsViewController.swift
//  LocationTracker
//
//  Created by Chuan Ho Danh on 8/14/17.
//  Copyright © 2017 tranght. All rights reserved.
//

import UIKit

protocol ListGroupViewControllerDelegate : class {
    func didTapRequestJoinGroup();
    func didTapCreateGroup();
}

class ListGroupsViewController: UIViewController {

    @IBOutlet weak var tblListGroups: UITableView!
    @IBOutlet weak var btnJoinGroup: UIButton!
    @IBOutlet weak var btnCreateGroup: UIButton!
    
    weak var delegate : ListGroupViewControllerDelegate? = nil
    
    var mGroups = [Group]()
    
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
        
        self.tblListGroups.register(GroupTableViewCell.self, forCellReuseIdentifier: Constants.CellIdentifier.GroupTableViewCellIdentifier)
        self.tblListGroups.delegate = self
        self.tblListGroups.dataSource = self
//        self.tblListGroups.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        
        self.tblListGroups.reloadData()
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
        ConnectionService.load(Group.getAllGroups, true) {(_ response : ServerResponse, _ _groups : [Group]?, _ error : Error?) in
            switch response.code {
            case .SUCCESS:
                self.mGroups = _groups!
                self.reflectDataOnView()
                break
            case .GROUP_NOT_EXISTS:
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
}

extension ListGroupsViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

extension ListGroupsViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.mGroups.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.CellIdentifier.GroupTableViewCellIdentifier, for: indexPath) as? GroupTableViewCell else {
            return UITableViewCell()
        }
        
        let _group = mGroups[indexPath.row]
        
        cell.bindView(withData: _group)
        
        return cell
    }
}

