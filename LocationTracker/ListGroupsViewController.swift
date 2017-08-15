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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.btnJoinGroup.layer.masksToBounds = true
        self.btnJoinGroup.layer.borderWidth = 2.0
        self.btnJoinGroup.layer.borderColor = UIColor(red: 83, green: 181, blue: 169, alpha: 1.0).cgColor
        self.btnJoinGroup.layer.cornerRadius = 10.0
        
        self.btnCreateGroup.layer.masksToBounds = true
        self.btnCreateGroup.layer.borderWidth = 2.0
        self.btnCreateGroup.layer.borderColor = UIColor.white.cgColor
        self.btnCreateGroup.layer.cornerRadius = 10.0
        
        self.tblListGroups.register(GroupTableViewCell.self, forCellReuseIdentifier: Constants.CellIdentifier.GroupTableViewCellIdentifier)
        self.tblListGroups.delegate = self
        self.tblListGroups.dataSource = self
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
