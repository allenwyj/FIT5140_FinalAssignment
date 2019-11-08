//
//  SettingViewController.swift
//  FIT5140_FinalAssignment
//
//  Created by Yujie Wu on 2/11/19.
//  Copyright © 2019 Yujie Wu. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth

class SettingViewController: UIViewController {

    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var distanceButton: UIButton!
    @IBOutlet weak var saveDriverButton: UIButton!
    @IBOutlet weak var clearDriverButton: UIButton!
    @IBOutlet weak var editProfileButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    
    // Create the Activity Indicator
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var timer = Timer()
    let database = Firestore.firestore()
    let userAuth = Auth.auth().currentUser
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUpElements()
        setupActivityIndicator()
        
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
        getUserName()
        UIApplication.shared.endIgnoringInteractionEvents()
    }
    
    func setupActivityIndicator() {
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = UIActivityIndicatorView.Style.gray
        self.view.addSubview(activityIndicator)
    }
    
    func setUpElements(){
        // Style the elements
        Styles.styleFilledButton(logoutButton)
    }
    
    func getUserName() {
       
        let uid = userAuth?.uid
        let currentUserRef = database.collection("users").document(uid!)
        
        currentUserRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let userName = document.data()!["firstName"] as! String
                self.nameLabel.text = "Welcome, \(userName)"
                self.activityIndicator.stopAnimating()
            } else {
                print("Document does not exist")
            }
        }
    }
    
//    @IBAction func setUpDistance(_ sender: Any) {
//        activityIndicator.startAnimating()
//        let dbRef = database.collection("raspberryPiData").document("raspberryPi1")
//
//        // setDistance: 0 => default value, 1 => start raspberry pi to setup distance
//        dbRef.setData(["setDistance" : "2"], merge: true) { err in
//            if let err = err {
//                print("Error writing document: \(err)")
//                self.activityIndicator.stopAnimating()
//                self.displayMessage(err as! String, "Error")
//            } else {
//                print("Document successfully written!")
//                // self.activityIndicator.stopAnimating()
//                self.setDistanceIsDefault()
//
//            }
//        }
//    }
    
    @IBAction func setUpDistance(_ sender: Any) {
        getDocumentBasedOnClicked(fieldName: "setDistance")
    }
    
    func getDocumentBasedOnClicked(fieldName: String) {
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
        let dbRef = database.collection("raspberryPiData").document("raspberryPi1")
        
        // setDistance: 0 => default value, 1 => start raspberry pi to setup distance
        dbRef.setData([fieldName : "2"], merge: true) { err in
            if let err = err {
                print("Error writing document: \(err)")
                self.activityIndicator.stopAnimating()
                UIApplication.shared.endIgnoringInteractionEvents()
                self.displayMessage(err as! String, "Error")
            } else {
                print("Document successfully written!")
                // self.activityIndicator.stopAnimating()
                self.setDistanceIsDefault(fieldName: fieldName)
                
            }
        }
    }
    
    @IBAction func setUpDriver(_ sender: Any) {
        getDocumentBasedOnClicked(fieldName: "takePictures")
    }
    
//    @IBAction func setUpDriver(_ sender: Any) {
//        activityIndicator.startAnimating()
//        let dbRef = database.collection("raspberryPiData").document("raspberryPi1")
//
//        // setDistance: 0 => default value, 1 => start raspberry pi to setup distance
//        dbRef.setData(["takePictures" : "2"], merge: true) { err in
//            if let err = err {
//                print("Error writing document: \(err)")
//                self.activityIndicator.stopAnimating()
//                self.displayMessage(err as! String, "Error")
//            } else {
//                print("Document successfully written!")
//                // self.activityIndicator.stopAnimating()
//                self.setDistanceIsDefault()
//
//            }
//        }
//    }
    
    @IBAction func clearAllDriver(_ sender: Any) {
        getDocumentBasedOnClicked(fieldName: "deleteDrivers")
    }
    
    func setDistanceIsDefault(fieldName: String) {
        // 0 is default, 1 is setting
        // Scheduling timer to Call the function "updateCounting" with the interval of 1 seconds
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(checkDistance), userInfo: fieldName, repeats: true)
        
    }
    
    @objc func checkDistance(sender: Timer) {
        let fieldName = sender.userInfo as! String
        print(fieldName)
        let dbRef = database.collection("raspberryPiData").document("raspberryPi1")
        
        dbRef.getDocument { (document, error) in
            if let document = document, document.exists {
                if document.data()![fieldName] as! String == "0" {
                    self.timer.invalidate()
                    self.activityIndicator.stopAnimating()
                    UIApplication.shared.endIgnoringInteractionEvents()
                    self.displayMessage("Updated successfully!", "Success")
                }
                
            } else {
                print("Document does not exist")
            }
        }
    }
    
    @IBAction func userLogout(_ sender: Any) {
        
        activityIndicator.startAnimating()
        
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
    
    func displayMessage(_ message: String, _ title: String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
}
