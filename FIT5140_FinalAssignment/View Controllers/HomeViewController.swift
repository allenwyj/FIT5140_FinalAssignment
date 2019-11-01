//
//  HomeViewController.swift
//  FIT5140_FinalAssignment
//
//  Created by Yujie Wu on 31/10/19.
//  Copyright © 2019 Yujie Wu. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

class HomeViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var user = User()
    var menuItems: [String] = ["Record Videos", "Edite Videos", "Reply Comments"]

    var images: [String] = ["map.jpg","monitoring.jpg","map.jpg"]
    let cellSpacingHeight: CGFloat = 10
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        let currentUser = Auth.auth().currentUser
//        let currentUserRef = Firestore.firestore().collection("users").document(currentUser!.uid)
//        let user = User()
//
//        currentUserRef.getDocument { (document, error) in
//            if let document = document, document.exists {
//                let firstnName = document.data()!["firstName"]
//                let lastName = document.data()!["lastName"]
//                let uid = currentUser!.uid
//
//                user.firstName = firstnName as! String
//                user.lastName = lastName as! String
//                user.uid = uid
//                print(user.firstName)
//            } else {
//                print("Document does not exist")
//            }
//        }
//
//        menuItems.append(user.firstName)
//        menuItems.append(user.firstName)
//        menuItems.append(user.firstName)
//        menuItems.append(user.firstName)
        setupTableView()
        // Do any additional setup after loading the view.
    }
    
    private func setupTableView() {
        let nib = UINib(nibName: "ItemTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "itemCellIdentifier")
    }
}

extension HomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemCellIdentifier", for: indexPath) as! ItemTableViewCell
        
        cell.itemImageView.image = UIImage(named: images[indexPath.row])
        
        cell.itemTitleLabel.text = menuItems[indexPath.row]
        
        cell.backgroundColor = UIColor.white
        cell.layer.borderColor = UIColor.black.cgColor
        cell.layer.borderWidth = 1
        cell.layer.cornerRadius = 8
        cell.clipsToBounds = false
        
        return cell
    }
}

extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.height / 3
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Did select row at: \(indexPath)")
    }
}

