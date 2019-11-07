//
//  UnknownDriverViewController.swift
//  FIT5140_FinalAssignment
//
//  Created by Yujie Wu on 7/11/19.
//  Reference From Real Life Swift https://www.youtube.com/watch?v=jQ8EUsQZJ5g
//  Copyright © 2019 Yujie Wu. All rights reserved.
//

import UIKit
import Firebase

struct Item {
    var imageName: String
    var image: UIImage
}

class UnknownDriverViewController: UIViewController {

   // @IBOutlet weak var iv: UIImageView!
    // different modes
    enum Mode {
        case view
        case select
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    //var items: [Item] = [Item(imageName: "map.jpg"), Item(imageName: "binoculars.png"), Item(imageName: "monitoring.jpg"), Item(imageName: "icon-clock.png"), Item(imageName: "map.jpg"), Item(imageName: "binoculars.png"), Item(imageName: "monitoring.jpg"), Item(imageName: "icon-clock.png")]
    var items = [Item]()
    //var items = [UIImage]()
    //var imageURL = [String]()
    // Create the Activity Indicator
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    var collectionViewFlowLayout: UICollectionViewFlowLayout!
    let cellIdentifier = "ItemCollectionViewCell"
    let imageListToDetailSegue = "ImageListToDetailSegue"
    
    var mMode: Mode = .view {
        didSet {
            switch mMode {
            case .view: // set the view when its in the select mode, delete button should be hidden
                
                // if the view come back to view mode, all items should be deselected
                for (key, value) in dictionarySelectedIndexPath {
                    if value {
                        collectionView.deselectItem(at: key, animated: true)
                    }
                }
                
                dictionarySelectedIndexPath.removeAll()
                
                selectBarButton.title = "Select"
                navigationItem.leftBarButtonItem = nil
                collectionView.allowsMultipleSelection = false
                
            case .select:
                selectBarButton.title = "Cancel"
                navigationItem.leftBarButtonItem = deleteBarButton
                collectionView.allowsMultipleSelection = true 
            }
        }
    }
    
    lazy var selectBarButton: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(title: "Select", style: .plain, target: self, action: #selector(didSelectButtonClicked(_:)))
        return barButtonItem
    }()
    
    lazy var deleteBarButton: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(didDeleteButtonClicked(_:)))
        return barButtonItem
    }()
    
    // save the index numbers for the selections
    // Bool will indicate the indexPath is selected or not
    var dictionarySelectedIndexPath: [IndexPath: Bool] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = UIActivityIndicatorView.Style.gray
        self.view.addSubview(activityIndicator)

        getImageFromFireStorage()
        print("000000000000000000000")
        // Do any additional setup after loading the view.
        setupBarButtonItems()
        setupCollectionView()
        
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        // we need to assign the size once the subview is loaded
        setupCollectionViewItemSize()
    }
    
    func setupBarButtonItems() {
        navigationItem.rightBarButtonItem = selectBarButton
        
    }
    
    func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        
        let nib = UINib(nibName: "ItemCollectionViewCell", bundle: nil)
        
        print("******\(items.count)")
        collectionView.register(nib, forCellWithReuseIdentifier: cellIdentifier)
    }
    
    func setupCollectionViewItemSize() {
        if collectionViewFlowLayout == nil {
            let numberOfItemForRow: CGFloat = 2
            let lineSpacing: CGFloat = 10
            let interItemSpacing: CGFloat = 10
            
            let width = (collectionView.frame.width - (numberOfItemForRow - 1) * interItemSpacing) / numberOfItemForRow
            
            // make the collection view as square
            let height = width
            
            collectionViewFlowLayout = UICollectionViewFlowLayout()
            
            collectionViewFlowLayout.itemSize = CGSize(width: width, height: height)
            
            collectionViewFlowLayout.sectionInset = UIEdgeInsets.zero
            collectionViewFlowLayout.scrollDirection = .vertical
            collectionViewFlowLayout.minimumLineSpacing = lineSpacing
            collectionViewFlowLayout.minimumInteritemSpacing = interItemSpacing
            
            collectionView.setCollectionViewLayout(collectionViewFlowLayout, animated: true)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let image = sender as! Item
        //let image = sender as! UIImage
        if segue.identifier == imageListToDetailSegue {
            if let vc = segue.destination as? ImageDetailViewController {
                vc.image = image.image
                vc.imageName = image.imageName
                
            }
        }
    }
    
    @objc func didSelectButtonClicked(_ sender: UIBarButtonItem) {
        // When the select button is clicked,
        // if the current mode is view mode, it will change to select mode.
        // Otherwise, it will change back to the view mode
        mMode = mMode == .view ? .select: .view
    }
    
    @objc func didDeleteButtonClicked(_ sender: UIBarButtonItem) {
        activityIndicator.startAnimating()
        
        var deleteNeededIndexPaths: [IndexPath] = []
        let ref = Firestore.firestore().collection("raspberryPiData").document("raspberryPi1")
        let storageRef = Storage.storage()
        
        for (key, value) in dictionarySelectedIndexPath {
            if value {
                deleteNeededIndexPaths.append(key)
            }
        }
        
        for item in deleteNeededIndexPaths.sorted(by: { $0.item > $1.item}) {
            
            // Delete image from firebase storage
            let deleteImage = items[item.item].imageName
            storageRef.reference(withPath: deleteImage).delete { (error) in
                if let error = error {
                    print("Error:\(error.localizedDescription)")
                } else {
                    print("Successfully deleted \(deleteImage)")
                }
            }
            
            items.remove(at: item.item)
        }
        
        // remove imageURL from the firestore
        var itemName = [String]()
        for item in items {
            itemName.append(item.imageName)
        }
        
        ref.setData(["unknownDrivers" : itemName], merge: true)
        
        collectionView.deleteItems(at: deleteNeededIndexPaths)
        dictionarySelectedIndexPath.removeAll()
        activityIndicator.stopAnimating()
    }
}

extension UnknownDriverViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! ItemCollectionViewCell
        
        
        //cell.imageView.image = UIImage(named: items[indexPath.item].imageName)
        cell.imageView.image = items[indexPath.item].image
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("didSelectItemAt: \(indexPath)")
        
        switch mMode {
        case .view:
            collectionView.deselectItem(at: indexPath, animated: true)
            let image = items[indexPath.item]
            performSegue(withIdentifier: imageListToDetailSegue, sender: image)
        case .select:
            dictionarySelectedIndexPath[indexPath] = true
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if mMode == .select {
            dictionarySelectedIndexPath[indexPath] = false
        }
    }
    
    func getImageFromFireStorage() {
        activityIndicator.startAnimating()
        //let storageRef = Storage.storage().reference(withPath: "1572760723.61057 Unkown 0.jpg")
        
        let storageRef = Storage.storage().reference()
        print(storageRef.name)
//        storageRef.listAll { (storageListResult, error) in
//            for i in storageListResult.items {
//                i.value(forKey: "name")
//                print(i.value(forKey: "name"))
//
//                i.getData(maxSize: 4 * 1024 * 1024) { (data, error) in
//                    if let error = error {
//                        self.activityIndicator.stopAnimating()
//                        print("Error: \(error.localizedDescription)")
//                        return
//                    } else {
//                        //self?.iv.image = UIImage(data: data)
//
//                        let pic = UIImage(data: data!)
//                        self.items.append(pic!)
//                        print("inside appending is finished")
//                        print("Loading...\(self.items.count)")
//
//
//                        self.collectionView.reloadData()
//                        self.activityIndicator.stopAnimating()
//                    }
//                }
//            }
//        }
        
        // NOTE: Need to save the file name in the firestore as well
        let database = Firestore.firestore()
        let ref = database.collection("raspberryPiData").document("raspberryPi1")
        var imageURL = [String]()
        
        ref.getDocument { (document, error) in
            if let document = document, document.exists {
                imageURL = document.data()!["unknownDrivers"] as! [String]
                print(imageURL)
            }

            for i in imageURL {
                //print(i)
                Storage.storage().reference(withPath: i).getData(maxSize: 4 * 1024 * 1024) { (data, error) in
                    if let error = error {
                        self.activityIndicator.stopAnimating()
                        print("Error: \(error.localizedDescription)")
                        return
                    } else {
                        //self?.iv.image = UIImage(data: data)
                        
                        let pic = UIImage(data: data!)
                        let itemImage = Item(imageName: i, image: pic!)
                        //self.items.append(pic!)
                        self.items.append(itemImage)
                        print("inside appending is finished")
                        print("Loading...\(self.items.count)")
                        
                        self.collectionView.reloadData()
                        //self.activityIndicator.stopAnimating()
                    }
                    self.activityIndicator.stopAnimating()
                }
            }
        }
    }
}
