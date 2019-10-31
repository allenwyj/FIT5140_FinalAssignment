//
//  LoginViewController.swift
//  FIT5140_FinalAssignment
//
//  Created by Yujie Wu on 31/10/19.
//  Copyright © 2019 Yujie Wu. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setUpElements()
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
        
        // Inputs validation
        let error = validateFields()
        
        if error != nil {
            errorLabel.text = error!
            showError(error!)
        } else {
            // Removing whitespace
            let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Signing in
            Auth.auth().signIn(withEmail: email!, password: password!) { (result, error) in
                if error != nil {
                    // login failed
                    self.errorLabel.text = error!.localizedDescription
                    self.errorLabel.alpha = 1
                } else {
                    let homeViewController = self.storyboard?.instantiateViewController(withIdentifier: Constants.Storyboard.homeViewController) as? HomeViewController
                    
                    // kill view
                    self.dismiss(animated: true, completion: nil)
                    
                    self.view.window?.rootViewController = homeViewController
                    self.view.window?.makeKeyAndVisible()
                    
                }
            }
        }
        
    }
}
