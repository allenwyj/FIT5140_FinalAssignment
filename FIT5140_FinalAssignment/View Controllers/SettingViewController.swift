//
//  SettingViewController.swift
//  FIT5140_FinalAssignment
//
//  Created by Yujie Wu on 2/11/19.
//  Copyright © 2019 Yujie Wu. All rights reserved.
//

import UIKit
import FirebaseAuth

class SettingViewController: UIViewController {

    @IBOutlet weak var editProfileButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUpElements()
    }
    
    func setUpElements(){
        // Style the elements
        Styles.styleHollowButton(logoutButton)
    }
    
    @IBAction func userLogout(_ sender: Any) {
        do
        {
            try Auth.auth().signOut()
            transitionToLoginScreen()
        }
        catch let error as NSError
        {
            print (error.localizedDescription)
        }
    }
    
    func transitionToLoginScreen() {
        let viewController = storyboard?.instantiateViewController(withIdentifier: Constants.Storyboard.viewController)
        
        // kill view
        self.dismiss(animated: true, completion: nil)
        
        view.window?.rootViewController = viewController
        view.window?.makeKeyAndVisible()
    }
    
}
