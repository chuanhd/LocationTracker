//
//  JoinGroupViewController.swift
//  LocationTracker
//
//  Created by chuanhd on 8/21/17.
//  Copyright © 2017 tranght. All rights reserved.
//

import UIKit

class JoinGroupViewController: UIViewController {
    
    @IBOutlet weak var m_ContentView: UIView!
    @IBOutlet weak var m_txtGroupID: UITextField!
    @IBOutlet weak var m_btnJoinGroup: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.isOpaque = false
        
        // Do any additional setup after loading the view.
        self.m_btnJoinGroup.layer.masksToBounds = true
        self.m_btnJoinGroup.layer.cornerRadius = 4.0
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
        
    }
    
    internal func handleTapOnRestOfView(_ gestureRecognizer : UITapGestureRecognizer) {
        
    }
}
