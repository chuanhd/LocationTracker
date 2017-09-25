//
//  InviteMembersViewController.swift
//  LocationTracker
//
//  Created by chuanhd on 9/21/17.
//  Copyright © 2017 tranght. All rights reserved.
//

import UIKit

class InviteMembersViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tblSearchResults: UITableView!
    
    var m_UserResults : [UserProfile]?
    var m_GroupId : Int = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.searchBar.delegate = self
        self.tblSearchResults.dataSource = self
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
    
    func requestSearchResult(_ searchString : String) {
        ConnectionService.load(UserProfile.searchUsers(searchString), true) { (_serverResponse, _users, error) in
            switch _serverResponse.code {
            case .SUCCESS:
                
                guard let users = _users as? [UserProfile] else {
                    return
                }
                
                self.m_UserResults = users
                self.tblSearchResults.reloadData()
                
                break
            case .FAILURE:
                print("Fail to get group details")
                break
            default:
                break
            }
        }
    }
}

extension InviteMembersViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let _userProfiles = self.m_UserResults else {
            return 0
        }
        
        return _userProfiles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let _userProfiles = self.m_UserResults else {
            return UITableViewCell()
        }
        
        guard let _cell = tableView.dequeueReusableCell(withIdentifier: Constants.CellIdentifier.UserProfileTableViewCell, for: indexPath) as? UserProfileTableViewCell else {
            return UITableViewCell()
        }
        
        _cell.m_Delegate = self
        _cell.bindDataToView(_userProfiles[indexPath.row], atIndex: indexPath.row)
        
        return _cell
    }
}

extension InviteMembersViewController : UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let _searchString = searchBar.text else {
            return
        }
        requestSearchResult(_searchString)
    }
}

extension InviteMembersViewController : UserProfileTableViewCellDelegate {
    
    func didTapInviteUser(atIndex _index: Int) {
        
        guard let _userProfiles = self.m_UserResults else {
            return
        }
        
        guard _index >= 0 && _index < _userProfiles.count else {
            return
        }
        
        let _userProfile = _userProfiles[_index]
        
        ConnectionService.load(Group.inviteUser(m_GroupId, _userProfile.mId), true) { (_serverResponse, _data, _error) in
            switch _serverResponse.code {
            case .SUCCESS:
                
                let _cell = self.tblSearchResults.cellForRow(at: IndexPath(item: _index, section: 0)) as! UserProfileTableViewCell
                _cell.btnInvite.isHidden = true
                
                break
            case .FAILURE:
                print("Fail to add member to group")
                break
            default:
                break
            }
        }
    }
}
