//
//  SignUpViewController.swift
//  FIT5140_FinalAssignment
//
//  Created by Yujie Wu on 31/10/19.
//  Copyright © 2019 Yujie Wu. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

class SignUpViewController: UIViewController {

    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    
    // Create the Activity Indicator
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUpElements()
        tapToHideKeyboard()
        
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = UIActivityIndicatorView.Style.gray
        self.view.addSubview(activityIndicator)
    }
    
    func setUpElements(){
        // Hide the error label if there is no error message
        errorLabel.alpha = 0
        
        // Style the elements
        Styles.styleTextField(firstNameTextField)
        Styles.styleTextField(lastNameTextField)
        Styles.styleTextField(emailTextField)
        Styles.styleTextField(passwordTextField)
        Styles.styleFilledButton(signUpButton)
    }
    
    // tap anywhere to hide keyboard
    func tapToHideKeyboard() {
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    // Validate the fields data. If validation check is passed, returns nil. Otherwise, returns
    // error message.
    func validateFields() -> String? {
        // Fields cannot remain empty
        if firstNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            lastNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            
            return "Please fill all the information."
        }
        
        let cleanedPassword = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Check the complexity of password
        if Styles.isPasswordValid(cleanedPassword) == false {
            // Password is not complex enough
            return "Please enter your password with at least 8 characters, a special character and a number"
        }
        
        return nil
    }
    
    @IBAction func signupTapped(_ sender: Any) {
        
        // Start loading
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        // Valdate the fields
        let error = validateFields()
        
        if error != nil {
            activityIndicator.stopAnimating()
            UIApplication.shared.endIgnoringInteractionEvents()
            
            errorLabel.text = error!
            showError(error!)
        } else {
            let firstName = firstNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let lastName = lastNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Create the user
            Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
                
                if error != nil {
                    self.activityIndicator.stopAnimating()
                    UIApplication.shared.endIgnoringInteractionEvents()
                    
                    // Error exists while creating user
                    self.showError("Creating user unsuccessfully")
                } else {
                    
                    // User created successfully
                    let db = Firestore.firestore()
                    
                    // use uid as document id when creates user's document
                    let newUserReference = db.collection("users").document(result!.user.uid)
                    newUserReference.setData(["firstName": firstName, "lastName" : lastName, "uid" : result!.user.uid], completion: { (error) in
                        if error != nil {
                            self.activityIndicator.stopAnimating()
                            UIApplication.shared.endIgnoringInteractionEvents()
                            // Show error message
                            self.showError("Error! Please try to sign up again.")
                        }
                        self.login(email: email, password: password)
                    })
                }
            }
        }
    }
    
    func login(email: String, password: String) {
        // Signing in
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if error != nil {
                self.activityIndicator.stopAnimating()
                UIApplication.shared.endIgnoringInteractionEvents()
                
                // login failed
                self.errorLabel.text = error!.localizedDescription
                self.errorLabel.alpha = 1
            } else {
                
                self.activityIndicator.stopAnimating()
                UIApplication.shared.endIgnoringInteractionEvents()
                
                // Transition to the home screen
                self.transitionToHomeScreen()
                
            }
        }
    }
    
    func transitionToHomeScreen() {
        
        let tabBarController = storyboard?.instantiateViewController(withIdentifier: Constants.Storyboard.tabBarController) as? MainTabBarController
        
        // kill view
        self.dismiss(animated: true, completion: nil)
        
        view.window?.rootViewController = tabBarController
        view.window?.makeKeyAndVisible()
        
        
    }
    
    func showError(_ message:String) {
        errorLabel.text = message
        errorLabel.alpha = 1
    }
    
}
