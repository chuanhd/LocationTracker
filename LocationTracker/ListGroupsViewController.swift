//
//  ListGroupsViewController.swift
//  LocationTracker
//
//  Created by Chuan Ho Danh on 8/14/17.
//  Copyright © 2017 tranght. All rights reserved.
//

import UIKit

class ListGroupsViewController: UIViewController {

    @IBOutlet weak var tblListGroups: UITableView!
    @IBOutlet weak var btnJoinGroup: UIButton!
    @IBOutlet weak var btnCreateGroup: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.btnJoinGroup.layer.masksToBounds = true
        self.btnJoinGroup.layer.borderWidth = 2.0
        self.btnJoinGroup.layer.borderColor = UIColor(colorLiteralRed: 83, green: 181, blue: 169, alpha: 1.0).cgColor
        self.btnJoinGroup.layer.cornerRadius = 10.0
        
        self.btnCreateGroup.layer.masksToBounds = true
        self.btnCreateGroup.layer.borderWidth = 2.0
        self.btnCreateGroup.layer.borderColor = UIColor.white.cgColor
        self.btnCreateGroup.layer.cornerRadius = 10.0
        
        
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

}
