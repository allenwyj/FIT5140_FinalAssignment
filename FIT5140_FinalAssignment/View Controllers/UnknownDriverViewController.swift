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
    enum Mode {
        case view
        case select
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var items = [Item]()
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

        // Do any additional setup after loading the view.
        setupBarButtonItems()
        setupCollectionView()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getImageFromFireStorage()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        items.removeAll()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        // we need to assign the size once the subview is loaded
        setupCollectionViewItemSize()
    }
    
    /**
     This method is to set the right bar button.
     **/
    func setupBarButtonItems() {
        navigationItem.rightBarButtonItem = selectBarButton
    }
    
    func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        
        let nib = UINib(nibName: "ItemCollectionViewCell", bundle: nil)
        
        collectionView.register(nib, forCellWithReuseIdentifier: cellIdentifier)
    }
    
    /**
     This method is to set the item size.
     **/
    func setupCollectionViewItemSize() {
        if collectionViewFlowLayout == nil {
            let numberOfItemForRow: CGFloat = 3
            let lineSpacing: CGFloat = 10
            let interItemSpacing: CGFloat = 10
            
            // Based on the device width
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
    
    /**
     This method is to change the view when the select button is clicked.
     When the select button is clicked, if the current mode is view mode, it will change to select mode.
     Otherwise, it will change back to the view mode
     **/
    @objc func didSelectButtonClicked(_ sender: UIBarButtonItem) {
        mMode = mMode == .view ? .select: .view
    }
    
    /**
     This method is to perform the deletion on the collection view.
     It also does the deletion the firebase and firestorage as well.
     **/
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
        cell.imageView.image = items[indexPath.item].image
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if items.count != 0 {
            // switch view, if the view is in the view mode, it will just perform the segue
            // if the mode is in the select, it will allow the app to record which item is clicked, and note it's true.
            switch mMode {
            case .view:
                collectionView.deselectItem(at: indexPath, animated: true)
                let image = items[indexPath.item]
                performSegue(withIdentifier: imageListToDetailSegue, sender: image)
            case .select:
                dictionarySelectedIndexPath[indexPath] = true
            }
        }
    }
    
    /**
     This method is to change the value when the item is not clicked.
     **/
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if mMode == .select {
            dictionarySelectedIndexPath[indexPath] = false
        }
    }
    
    /**
     This method is to get the image from the firestorage by checking the image name in the firebase.
     Fetch all images in the field 'unknownDrivers' and add to the list.
     **/
    func getImageFromFireStorage() {
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        let database = Firestore.firestore()
        let ref = database.collection("raspberryPiData").document("raspberryPi1")
        var imageURL = [String]()
        
        ref.getDocument { (document, error) in
            if let document = document, document.exists {
                // Get the imagesURL array from the field "unknowDrivers"
                imageURL = document.data()!["unknownDrivers"] as! [String]
            }

            for i in imageURL {
                Storage.storage().reference(withPath: i).getData(maxSize: 4 * 1024 * 1024) { (data, error) in
                    if let error = error {
                        self.activityIndicator.stopAnimating()
                        print("Error: \(error.localizedDescription)")
                        return
                    } else {
                        let pic = UIImage(data: data!)
                        let itemImage = Item(imageName: i, image: pic!)
                        print(itemImage.imageName)
                        self.items.append(itemImage)
                    }
                    
                    // sort the items Array based on the timeStamp
                    self.items = self.items.sorted(by: { (($0.imageName.split(separator: " "))[0], $0.imageName.suffix(1)) < (($1.imageName.split(separator: " "))[0], $1.imageName.suffix(1)) })
                    
                    self.collectionView.reloadData()
                    self.activityIndicator.stopAnimating()
                    UIApplication.shared.endIgnoringInteractionEvents()
                }
            }
            
            if imageURL.count == 0 {
                self.activityIndicator.stopAnimating()
                UIApplication.shared.endIgnoringInteractionEvents()
            }
        }
    }
}
