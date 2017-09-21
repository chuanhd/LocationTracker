//
//  GroupMembersViewController.swift
//  LocationTracker
//
//  Created by chuanhd on 8/24/17.
//  Copyright © 2017 tranght. All rights reserved.
//

import UIKit

class GroupMembersViewController: UIViewController {

    @IBOutlet weak var tblGroupMembers: UITableView!
    var m_Group : Group?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tblGroupMembers.dataSource = self
        fetchGroupDetails()
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


