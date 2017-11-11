//
//  GroupMembersViewController.swift
//  LocationTracker
//
//  Created by chuanhd on 8/24/17.
//  Copyright © 2017 tranght. All rights reserved.
//

import UIKit
import RMessage

protocol GroupMembersViewControllerDelegate : class {
    func memberDidLeaveGroup(_ groupId : Int)
}

class GroupMembersViewController: UIViewController, SegueHandler {
    
    enum SegueIdentifier : String {
        case PresentInviteMembersView  = "PresentInviteMembersView"
    }

    @IBOutlet weak var tblGroupMembers: UITableView!
    @IBOutlet weak var viewInviteMember : UIView!
    @IBOutlet weak var constraintInviteMemberViewHeight: NSLayoutConstraint!
    @IBOutlet weak var btnLeaveOrManageGroup: UIBarButtonItem!
    
    weak var delegate : GroupMembersViewControllerDelegate?
    
    private let m_constraintInviteMemberViewHeightValue : CGFloat = 48
    
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
                DispatchQueue.main.async {
                    self.syncUIBasedOnMasterStatus(AppController.sharedInstance.isMasterOfGroup(_group))
                    self.tblGroupMembers.reloadData()
                }

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
        
        guard let _group = self.m_Group else {
            return
        }
        
        if AppController.sharedInstance.isMasterOfGroup(_group) {
            
        } else {
            self.leaveGroup(withGroupId: _group.mId)
        }
    }
    
    private func syncUIBasedOnMasterStatus(_ isMaster : Bool) {
        if isMaster {
            self.constraintInviteMemberViewHeight.constant = m_constraintInviteMemberViewHeightValue
            self.btnLeaveOrManageGroup.title = "Manage"
            self.btnLeaveOrManageGroup.setTitleTextAttributes([NSForegroundColorAttributeName : UIColor.blue], for: UIControlState.normal)
        } else {
            self.constraintInviteMemberViewHeight.constant = 0
            self.btnLeaveOrManageGroup.title = "Leave"
            self.btnLeaveOrManageGroup.setTitleTextAttributes([NSForegroundColorAttributeName : UIColor.red], for: UIControlState.normal)
        }
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
    }
    
    private func leaveGroup(withGroupId _groupId : Int) {
        ConnectionService.load(UserProfile.leaveGroup(AppController.sharedInstance.mUniqueToken, _groupId)) { (_serverResponse, _data, _error) in
            switch _serverResponse.code {
            case .SUCCESS:
                
                RMessage.showNotification(withTitle: "Success", subtitle: "You have left '\(self.m_Group!.mName)' group", type: RMessageType.success, customTypeName: nil, callback: {
                })
                
                DispatchQueue.main.async {
                    
                    guard let delegateMethod = self.delegate?.memberDidLeaveGroup else {
                        return
                    }
                    
                    delegateMethod(_groupId)
                    
                    self.navigationController?.popViewController(animated: true)
                }
                
                break
            case .FAILURE:
                
                RMessage.showNotification(withTitle: "Failed", subtitle: "Failed to leave group", type: RMessageType.error, customTypeName: nil, duration: TimeInterval(RMessageDuration.automatic.rawValue), callback: nil)
                
                break
            default:
                break
            }
        }
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


