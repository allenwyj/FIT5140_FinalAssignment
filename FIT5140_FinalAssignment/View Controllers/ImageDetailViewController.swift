//
//  ImageDetailViewController.swift
//  FIT5140_FinalAssignment
//
//  Created by Yujie Wu on 7/11/19.
//  Copyright © 2019 Yujie Wu. All rights reserved.
//

import UIKit

class ImageDetailViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageLabel: UILabel!
    //var imageName: String!
    var image: UIImage!
    var imageName: String!
    
    lazy var downloadBarButton: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(title: "Download", style: .plain, target: self, action: #selector(didDownloadButtonClicked(_:)))
        return barButtonItem
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupBarButtonItems()
        setUpImageView()
        
    }
    
    func setUpImageView() {
        guard let image = image else { return }
        
        imageView.image = image
        imageLabel.text = imageName
    }
    
    func setupBarButtonItems() {
        navigationItem.rightBarButtonItem = downloadBarButton
    }
    
    // Save image to the photo library when the download button clicked
    // Reference From https://www.hackingwithswift.com/example-code/media/uiimagewritetosavedphotosalbum-how-to-write-to-the-ios-photo-album
    @objc func didDownloadButtonClicked(_ sender: UIBarButtonItem) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Saved!", message: "Image has been saved to your photo library.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
}
