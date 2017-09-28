//
//  GroupMembersViewController.swift
//  LocationTracker
//
//  Created by chuanhd on 8/24/17.
//  Copyright © 2017 tranght. All rights reserved.
//

import UIKit

class GroupMembersViewController: UIViewController, SegueHandler {
    
    enum SegueIdentifier : String {
        case PresentInviteMembersView  = "PresentInviteMembersView"
    }

    @IBOutlet weak var tblGroupMembers: UITableView!
    var m_Group : Group?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tblGroupMembers.dataSource = self
        tblGroupMembers.delegate = self
        fetchGroupDetails()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        switch (segueIdentifier(for: segue)) {
        case .PresentInviteMembersView:
            guard let _dest = segue.destination as? InviteMembersViewController else {
                fatalError("InviteMembersViewController not found");
            }
            
            _dest.m_Delegate = self
            _dest.m_GroupId = m_Group!.mId
            
            break
        
        }
    }
    
    
    internal func fetchGroupDetails() {
        
        guard let _group = m_Group else {
            return
        }
        
        ConnectionService.load(Group.createGetGroupDetailResource(_group.mId), true) { (_ response : ServerResponse, _ users : [Any]?, _ error : Error?) in
            switch response.code {
            case .SUCCESS:
                
                guard let users = users as? [UserProfile] else {
                    return
                }
                
                _group.mUsers = users
                self.tblGroupMembers.reloadData()

                break
            case .FAILURE:
                print("Fail to get group details")
                break
            default:
                break
            }
        }
    }

    @IBAction func inviteMemberBtnPressed(_ sender: Any) {
        self.performSegue(withIdentifier: SegueIdentifier.PresentInviteMembersView.rawValue, sender: nil)
    }
    
    @IBAction func manageGroupBtnPressed(_ sender: Any) {
        
    }
    
}

extension GroupMembersViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let _group = self.m_Group else {
            return 0
        }
        
        return _group.mUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let _group = self.m_Group else {
            return UITableViewCell()
        }
        
        guard let _cell = tableView.dequeueReusableCell(withIdentifier: Constants.CellIdentifier.GroupMemberTableViewCellIdentifier, for: indexPath) as? GroupMemberTableViewCell else {
            return UITableViewCell()
        }
        
        _cell.bindDataToView(_group.mUsers[indexPath.row])
        
        return _cell
        
    }
    
}

extension GroupMembersViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
}

extension GroupMembersViewController : InviteMemberViewControllerDelegate {
    func didInviteUserSuccessful(_ _userProfile: UserProfile) {
        guard let _group = self.m_Group else {
            return
        }
        
        _group.mUsers.append(_userProfile)
        self.tblGroupMembers.reloadData()
    }
}


