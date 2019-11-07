//
//  LoginViewController.swift
//  FIT5140_FinalAssignment
//
//  Created by Yujie Wu on 31/10/19.
//  Copyright © 2019 Yujie Wu. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    
    // Create the Activity Indicator
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUpElements()
        
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = UIActivityIndicatorView.Style.gray
        self.view.addSubview(activityIndicator)
    }
    
    func setUpElements() {
        
        // Hide the error label if there is no error message
        errorLabel.alpha = 0
        
        // Style the elements
        Styles.styleTextField(emailTextField)
        Styles.styleTextField(passwordTextField)
        Styles.styleFilledButton(loginButton)
    }
    
    func validateFields() -> String? {
        
        // Fields cannot remain empty
        if emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            
            return "Please fill all the information."
        }
        
        return nil
    }
    
    func showError(_ message:String) {
        errorLabel.text = message
        errorLabel.alpha = 1
    }

    @IBAction func loginTapped(_ sender: Any) {
        
        // Start Animating
        activityIndicator.startAnimating()
        
        // Inputs validation
        let error = validateFields()
        
        if error != nil {
            activityIndicator.stopAnimating()
            
            errorLabel.text = error!
            showError(error!)
        } else {
            // Removing whitespace
            let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Signing in
            Auth.auth().signIn(withEmail: email!, password: password!) { (result, error) in
                if error != nil {
                    self.activityIndicator.stopAnimating()
                    
                    // login failed
                    self.errorLabel.text = error!.localizedDescription
                    self.errorLabel.alpha = 1
                } else {
                    
                    let tabBarController = self.storyboard?.instantiateViewController(withIdentifier: Constants.Storyboard.tabBarController) as? MainTabBarController
                    
                    // kill view
                    self.dismiss(animated: true, completion: nil)
                    
                    self.view.window?.rootViewController = tabBarController
                    self.view.window?.makeKeyAndVisible()
                    
                }
            }
        }
    }
}
