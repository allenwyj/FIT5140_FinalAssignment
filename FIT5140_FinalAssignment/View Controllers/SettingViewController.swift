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
    @IBOutlet weak var registerSwitch: UISwitch!
    
    // Create the Activity Indicator
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var timer = Timer()
    let database = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUpElements()
        setupActivityIndicator()
        
        // Check whether the login user is the monitoring list.
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
        getUserName()
        checkLoginUserIsRegister()
        
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
    
    /**
     This method is to fetch the user name from the firebase.
     **/
    func getUserName() {
        let userAuth = Auth.auth().currentUser
        let uid = userAuth!.uid
        let currentUserRef = database.collection("users").document(uid)

        currentUserRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let userName = document.data()!["firstName"] as! String
                self.nameLabel.text = userName
                self.activityIndicator.stopAnimating()
            } else {
                print("Document does not exist")
            }
        }
    }
    
    /**
     This method is to start the Pi by changing values in the firebase.
     After the start, it will check the database if the value is changed back to the default value.
     **/
    func getDocumentBasedOnClicked(fieldName: String) {
        let dbRef = database.collection("raspberryPiData").document("raspberryPi1")
        // setDistance: 0 => default value, 1 => start raspberry pi to setup distance
        dbRef.setData([fieldName : "1"], merge: true) { err in
            if let err = err {
                print("Error writing document: \(err)")
                self.displayMessage(err as! String, "Error")
            } else {
                print("Document successfully written!")
                self.setTimerToCheckFirestore(fieldName: fieldName)
            }
        }
    }
    
    /**
     This method is to perform activities when the distance button is clicked.
     **/
    @IBAction func setUpDistance(_ sender: Any) {
        UIApplication.shared.beginIgnoringInteractionEvents()
        activityIndicator.startAnimating()
        getDocumentBasedOnClicked(fieldName: "setDistance")
    }
    
    /**
     This method is to perform activities when the setup driver button is clicked.
     **/
    @IBAction func setUpDriver(_ sender: Any) {
        UIApplication.shared.beginIgnoringInteractionEvents()
        activityIndicator.startAnimating()
        getDocumentBasedOnClicked(fieldName: "takePictures")
    }
    
    /**
     This method is to perform activities when the delete drivers button is clicked.
     **/
    @IBAction func clearAllDriver(_ sender: Any) {
        UIApplication.shared.beginIgnoringInteractionEvents()
        activityIndicator.startAnimating()
        getDocumentBasedOnClicked(fieldName: "deleteDrivers")
    }
    
    /**
     This method is to check the login user is in the list of registration.
     And it will control the switch.
     If the current user is in the list, the switch will be set into On, otherwise off.
     **/
    func checkLoginUserIsRegister() {
        let userAuth = Auth.auth().currentUser
        let uid = userAuth!.uid
        let dbRef = database.collection("raspberryPiData")
        let fieldName = "loginUsers"
        let query = dbRef.whereField(fieldName, arrayContains: uid)
        
        query.getDocuments { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                let noOfDocument = querySnapshot!.documents.count
                if noOfDocument == 0 {
                    self.registerSwitch.setOn(false, animated: true)
                } else {
                    self.registerSwitch.setOn(true, animated: true)
                }
            }
        }
    }
    
    /**
     This method is to change the database when the user uses the switch.
     If user turns it On, the current user ID will be saved into the list, otherwise, it will be deleted.
     **/
    func editRegisterStatus(isTurnOff: Bool) {
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        let userAuth = Auth.auth().currentUser
        let uid = userAuth!.uid
        let dbRef = database.collection("raspberryPiData").document("raspberryPi1")
        let fieldName = "loginUsers"
        
        if isTurnOff {
            dbRef.updateData([
                fieldName : FieldValue.arrayRemove([uid])
                ])
        } else {
            // add the uid to the firestore if it doesn't exist in the array
            dbRef.updateData([
                fieldName : FieldValue.arrayUnion([uid])
                ])
        }
        
        activityIndicator.stopAnimating()
        UIApplication.shared.endIgnoringInteractionEvents()
        displayMessage("Updated successfully!", "Success")
    }
    
    @IBAction func registerStatus(_ sender: Any) {
        if registerSwitch.isOn == true {
            editRegisterStatus(isTurnOff: false)
            print("Switch is on")
        }
        if registerSwitch.isOn == false {
            editRegisterStatus(isTurnOff: true)
            print("Switch turns off")
        }
    }
    
    func setTimerToCheckFirestore(fieldName: String) {
        // 0 is default, 1 is setting
        // Scheduling timer to Call the function "checkDefaultValue" with the interval of 1 seconds
        
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(checkDefaultValue), userInfo: fieldName, repeats: true)
    }
    
    @objc func checkDefaultValue(sender: Timer) {
        
        let fieldName = sender.userInfo as! String
        let dbRef = database.collection("raspberryPiData").document("raspberryPi1")

        dbRef.getDocument { (document, error) in
            if let document = document, document.exists {
                if document.data()![fieldName] as! String == "0" {
                    self.timer.invalidate()
                    UIApplication.shared.endIgnoringInteractionEvents()
                    self.activityIndicator.stopAnimating()
                    self.displayMessage("Updated successfully!", "Success")
                }
                
            } else {
                print("Document does not exist")
            }
        }
    }
    
    /**
     This method is to perform user logout, it will change to the welcome screen.
     **/
    @IBAction func userLogout(_ sender: Any) {
        activityIndicator.startAnimating()
        
        do
        {
            try Auth.auth().signOut()
            transitionToLoginScreen()
        }
        catch let error as NSError
        {
            print(error.localizedDescription)
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
