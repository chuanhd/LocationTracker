//
//  CreateGroupViewController.swift
//  LocationTracker
//
//  Created by Chuan Ho Danh on 8/14/17.
//  Copyright © 2017 tranght. All rights reserved.
//

import UIKit

protocol CreateGroupViewControllerDelegate : class {
    func createNewGroupSuccessful()
}

class CreateGroupViewController: UIViewController {

    @IBOutlet weak var txtGroupName: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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

    @IBAction func btnCreateNewGroupPressed(_ sender: Any) {
        print("btnCreateNewGroupPressed")
        
        createNewGroup()
        
    }
    
    internal func createNewGroup() {
        ConnectionService.load(Group.createNewGroupResource(txtGroupName.text, "FFFFFF"), true) {(_ response : ServerResponse, _ _groups : [Group]?, _ error : Error?) in
            switch response.code {
            case .SUCCESS:
                break
            case .FAILURE:
                break
            default:
                break
            }
        }
    }
}
